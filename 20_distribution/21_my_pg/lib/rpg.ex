defmodule Rpg do
  use GenServer

  def start_link(scope \\ __MODULE__) when is_atom(scope) do
    GenServer.start_link(__MODULE__, [scope], name: scope)
  end

  def start(scope) do
    GenServer.start(__MODULE__, [scope], name: scope)
  end

  # Write

  def join(scope \\ __MODULE__, group, pid) when is_pid(pid) do
    GenServer.call(scope, {:join_local, group, pid})
  end

  def leave(scope \\ __MODULE__, group, pid) when is_pid(pid) do
    GenServer.call(scope, {:leave_local, group, pid})
  end

  # Read

  def get_members(scope \\ __MODULE__, group) do
    GenServer.call(scope, {:get_members, group})
  end

  def get_local_members(scope \\ __MODULE__, group) do
    GenServer.call(scope, {:get_local_members, group})
  end

  def which_groups(scope \\ __MODULE__) do
    GenServer.call(scope, {:which_groups})
  end

  # GenServer Impl.

  defmodule State do
    @type group :: any()
    @type t :: %__MODULE__{
            # scope and also registered process name (self())
            scope: atom(),
            # local processes and local groups they joined
            local_members: %{pid() => {m_ref :: reference(), groups :: [group()]}},
            # groups to all and local processes
            groups: %{group() => {all :: [pid()], local :: [pid()]}},
            # remote peers: scope process monitor and map of groups to pids for fast sync routine
            peers: %{pid() => {reference(), %{group() => [pid()]}}}
          }

    @enforce_keys [:scope]
    defstruct scope: nil,
              local_members: %{},
              groups: %{},
              peers: %{}
  end

  def init([scope]) do
    :ok = :net_kernel.monitor_nodes(true)
    # {registered_name, node} is used for send.
    peers = for(node <- :erlang.nodes(), do: {scope, node})
    broadcast(peers, {:discover, self()})
    {:ok, %State{scope: scope}}
  end

  # Call

  def handle_call(
        {:join_local, group, pid},
        _from,
        %State{local_members: local_members, peers: peers, groups: groups} = state
      ) do
    new_local_members = local_members |> join_local_member(pid, group)
    new_groups = groups |> join_local_group(group, [pid])
    broadcast(Map.keys(peers), {:join, self(), group, pid})
    {:reply, :ok, %State{state | local_members: new_local_members, groups: new_groups}}
  end

  def handle_call(
        {:leave_local, group, pid},
        _from,
        %State{local_members: local_members, peers: peers, groups: groups} = state
      ) do
    new_local_members = local_members |> leave_local_member(pid, group)
    new_groups = groups |> leave_local_group(group, [pid])
    broadcast(Map.keys(peers), {:leave, self(), pid, [group]})
    {:reply, :ok, %State{state | local_members: new_local_members, groups: new_groups}}
  end

  def handle_call({:get_members, group}, _from, %State{groups: groups} = state) do
    {all, _local} = groups |> Map.get(group, {[], []})
    {:reply, all, state}
  end

  def handle_call({:get_local_members, group}, _from, %State{groups: groups} = state) do
    {_all, local} = groups |> Map.get(group, {[], []})
    {:reply, local, state}
  end

  def handle_call({:which_groups}, _from, %State{groups: groups} = state) do
    {:reply, groups |> Map.keys(), state}
  end

  # Info

  def handle_info({:nodeup, node}, state) when node == :erlang.node() do
    {:noreply, state}
  end

  def handle_info({:nodeup, node}, %State{scope: scope} = state) do
    :erlang.send({scope, node}, {:discover, self()})

    {:noreply, state}
  end

  def handle_info({:discover, peer}, %State{groups: groups, peers: peers} = state) do
    # Send local groups
    groups_with_local_procs =
      groups
      |> Enum.reduce(%{}, fn
        {_group, {_all, []}}, groups_with_local_procs ->
          groups_with_local_procs

        {group, {_all, local}}, groups_with_local_procs ->
          groups_with_local_procs |> Map.put(group, local)
      end)

    :erlang.send(peer, {:sync, self(), groups_with_local_procs})

    # Request peer's data if necessary
    case peers |> Map.has_key?(peer) do
      true ->
        {:noreply, state}

      false ->
        :erlang.send(peer, {:discover, self()})

        peer_info = {Process.monitor(peer), %{}}
        {:noreply, %State{state | peers: peers |> Map.put(peer, peer_info)}}
    end
  end

  def handle_info({:sync, peer, peer_groups}, %State{} = state) do
    new_state = apply_sync_data(state, peer, peer_groups)
    {:noreply, new_state}
  end

  def handle_info({:nodedown, _node}, state) do
    # We need only :nodeup. Peer's :DOWN signal will arrive soon.
    {:noreply, state}
  end

  # handle local process exit
  def handle_info(
        {:DOWN, m_ref, :process, pid, _info},
        %State{local_members: local_members, groups: groups, peers: peers} = state
      )
      when node(pid) == :erlang.node() do
    {member_info, new_local_members} = local_members |> Map.pop(pid)

    case member_info do
      nil ->
        # happens when pid exits before 'leave' is processed.
        {:noreply, state}

      {^m_ref, joined_groups} ->
        new_groups =
          joined_groups
          |> Enum.reduce(groups, fn joined_group, groups ->
            groups |> leave_local_group(joined_group, [pid])
          end)

        broadcast(Map.keys(peers), {:leave, self(), pid, joined_groups})

        {:noreply, %State{state | local_members: new_local_members, groups: new_groups}}
    end
  end

  # handle remote peer down or leaving overlay network
  def handle_info(
        {:DOWN, m_ref, :process, peer, _info},
        %State{groups: groups, peers: peers} = state
      ) do
    {^m_ref, peer_groups} = peers |> Map.get(peer)
    new_peers = peers |> Map.delete(peer)

    new_groups =
      peer_groups
      |> Enum.reduce(groups, fn {group, pids}, groups ->
        groups |> leave_remote_group(group, pids)
      end)

    {:noreply, %State{state | groups: new_groups, peers: new_peers}}
  end

  # remote pid is joining the group
  def handle_info({:join, peer, group, pid}, %State{groups: groups, peers: peers} = state) do
    {m_ref, peer_groups} = Map.get(peers, peer)

    new_groups = groups |> join_remote_group(group, [pid])
    new_peer_groups = peer_groups |> Map.update(group, [pid], fn pids -> [pid | pids] end)

    {:noreply,
     %State{state | groups: new_groups, peers: %{peers | peer => {m_ref, new_peer_groups}}}}
  end

  # remote pid is leaving multiple groups at once
  def handle_info(
        {:leave, peer, pid, joined_groups},
        %State{groups: groups, peers: peers} = state
      ) do
    {m_ref, peer_groups} = Map.get(peers, peer)

    new_groups =
      joined_groups
      |> Enum.reduce(groups, fn joined_group, groups ->
        groups |> leave_remote_group(joined_group, [pid])
      end)

    new_peer_groups =
      joined_groups
      |> Enum.reduce(peer_groups, fn joined_group, peer_groups ->
        peer_groups |> Map.update!(joined_group, fn pids -> pids |> List.delete(pid) end)
      end)

    new_peers = peers |> Map.put(peer, {m_ref, new_peer_groups})

    {:noreply, %State{state | groups: new_groups, peers: new_peers}}
  end

  defp apply_sync_data(%State{peers: peers, groups: groups} = state, peer, new_peer_groups)
       when is_pid(peer) do
    {m_ref, old_peer_groups} = peers |> Map.get_lazy(peer, fn -> {Process.monitor(peer), %{}} end)

    new_groups = sync_groups(groups, old_peer_groups, new_peer_groups)
    new_peers = peers |> Map.put(peer, {m_ref, new_peer_groups})

    %State{state | groups: new_groups, peers: new_peers}
  end

  defp sync_groups(groups, %{} = old_peer_groups, %{} = new_peer_groups) do
    (Map.keys(old_peer_groups) ++ Map.keys(new_peer_groups))
    |> Enum.uniq()
    |> Enum.reduce(groups, fn group, groups ->
      new_pids = Map.get(new_peer_groups, group, [])
      old_pids = Map.get(old_peer_groups, group, [])

      groups =
        (new_pids -- old_pids)
        |> Enum.reduce(groups, fn pid, groups -> groups |> join_remote_group(group, [pid]) end)

      groups =
        (old_pids -- new_pids)
        |> Enum.reduce(groups, fn pid, groups -> groups |> leave_remote_group(group, [pid]) end)

      groups
    end)
  end

  # util for groups

  defp join_local_group(%{} = groups, group, pids) when is_list(pids) do
    {all, local} = groups |> Map.get(group, {[], []})
    groups |> Map.put(group, {pids ++ all, pids ++ local})
  end

  defp join_remote_group(%{} = groups, group, pids) when is_list(pids) do
    {all, local} = groups |> Map.get(group, {[], []})
    groups |> Map.put(group, {pids ++ all, local})
  end

  defp leave_local_group(%{} = groups, group, pids) when is_list(pids) do
    # don't handle exception. educational purpose only.
    {all, local} = groups |> Map.get(group)
    groups |> Map.put(group, {all -- pids, local -- pids})
  end

  defp leave_remote_group(%{} = groups, group, pids) when is_list(pids) do
    # don't handle exception. educational purpose only.
    {all, local} = groups |> Map.get(group)
    groups |> Map.put(group, {all -- pids, local})
  end

  # util for local_members (do not need to accept multiple groups)

  defp join_local_member(%{} = local_members, pid, group) do
    {m_ref, old_groups} = local_members |> Map.get_lazy(pid, fn -> {Process.monitor(pid), []} end)
    local_members |> Map.put(pid, {m_ref, [group | old_groups]})
  end

  defp leave_local_member(%{} = local_members, pid, group) do
    # don't handle exception. educational purpose only.
    case local_members |> Map.get(pid) do
      {m_ref, [^group]} ->
        Process.demonitor(m_ref)
        local_members |> Map.delete(pid)

      {m_ref, groups} ->
        new_groups = groups |> List.delete(group)
        local_members |> Map.put(pid, {m_ref, new_groups})
    end
  end

  # util for peers

  defp broadcast(peers, msg) do
    # No implicit connect because we handle :nodeup explicitly.
    peers
    |> Enum.each(fn peer -> Process.send(peer, msg, [:noconnect]) end)

    :ok
  end
end
