defmodule Cluster do
  @this_name :foo
  @other_name :bar

  def ensure_other_node_started() do
    if other_node() == nil do
      start_other_node()
    end
  end

  def rpc_other_node(m, f, a) do
    :rpc.block_call(other_node(), m, f, a)
  end

  def stop_other_node() do
    case other_node() do
      nil ->
        :ok

      other ->
        Node.monitor(other, true)
        :ok = :slave.stop(other)

        receive do
          {:nodedown, ^other} ->
            :ok
        end
    end
  end

  def other_node do
    case Node.list() do
      [] -> nil
      [other] -> other
    end
  end

  # Private

  defp start_other_node() do
    ensure_epmd_started()

    # Turn node into a distributed node
    Node.start(@this_name, :shortnames)

    # Allow other nodes to fetch code from this node
    allow_boot()

    # Spawn other node
    spawn_other_node()
  end

  defp ensure_epmd_started() do
    case :erl_epmd.names() do
      {:error, _} ->
        :os.cmd('epmd -daemon')
        :ok

      {:ok, _} ->
        :ok
    end
  end

  defp spawn_other_node() do
    {:ok, node} = :slave.start(:net_adm.localhost(), @other_name, inet_loader_args())

    :ok = add_code_paths(node)
    :ok = transfer_configuration(node)
    :ok = ensure_applications_started(node)
    :ok = wait_for_other_node_up(node)
    node
  end

  defp inet_loader_args do
    '-loader inet -hosts 127.0.0.1 -setcookie #{:erlang.get_cookie()}'
  end

  defp allow_boot() do
    localhost = :net_adm.localhost()

    :erl_boot_server.start([localhost])
  end

  defp add_code_paths(node) do
    :ok = :rpc.block_call(node, :code, :add_paths, [:code.get_path()])
  end

  defp transfer_configuration(node) do
    for {app_name, _, _} <- Application.loaded_applications() do
      for {key, val} <- Application.get_all_env(app_name) do
        :ok = :rpc.block_call(node, Application, :put_env, [app_name, key, val])
      end
    end

    :ok
  end

  defp ensure_applications_started(node) do
    {:ok, _} = :rpc.block_call(node, Application, :ensure_all_started, [:mix])
    :ok = :rpc.block_call(node, Mix, :env, [Mix.env()])

    for {app_name, _, _} <- Application.loaded_applications() do
      {:ok, _} = :rpc.block_call(node, Application, :ensure_all_started, [app_name])
    end

    :ok
  end

  defp wait_for_other_node_up(node) do
    case :net_adm.ping(node) do
      :pong ->
        :ok

      :pang ->
        Process.sleep(100)
        wait_for_other_node_up(node)
    end
  end
end
