defmodule Rpg.NodeDownTest do
  use ExUnit.Case

  for pg <- [:pg, Rpg] do
    setup %{test: test} do
      pg = unquote(pg)
      scope = :"#{pg}-#{test}"
      Cluster.ensure_other_node_started()

      {:ok, _pid} = pg.start(scope)
      {:ok, _pid} = Cluster.rpc_other_node(pg, :start, [scope])
      local = self()
      remote = Node.spawn(Cluster.other_node(), Process, :sleep, [:infinity])

      {:ok, %{pg: pg, scope: scope, local: local, remote: remote}}
    end

    test "#{pg} remote members are removed when remote node is down", %{
      pg: pg,
      scope: scope,
      local: local,
      remote: remote
    } do
      # Join from local
      :ok = pg.join(scope, :group1, local)
      # Join from remote
      :ok = Cluster.rpc_other_node(pg, :join, [scope, :group1, remote])

      # Check members are synced
      Process.sleep(200)
      assert pg.get_members(scope, :group1) == [remote, local]

      # BOOM! Stop other node
      other_node = Cluster.other_node()
      Node.monitor(other_node, true)
      :ok = :slave.stop(other_node)

      receive do
        {:nodedown, ^other_node} ->
          :ok
      end

      # Check remote member is removed
      Process.sleep(200)
      assert pg.get_members(scope, :group1) == [local]
    end
  end
end
