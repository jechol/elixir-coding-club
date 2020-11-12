defmodule Rpg.MultiNodesTest do
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

    test "#{pg} join, leave, get_members, get_local_members", %{
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
      assert pg.get_local_members(scope, :group1) == [local]
      assert Cluster.rpc_other_node(pg, :get_local_members, [scope, :group1]) == [remote]

      # Leave from local
      :ok = pg.leave(scope, :group1, local)
      # Leave from remote
      :ok = Cluster.rpc_other_node(pg, :leave, [scope, :group1, remote])

      # Check members are synced
      Process.sleep(200)
      assert pg.get_members(scope, :group1) == []
      assert pg.get_local_members(scope, :group1) == []
      assert Cluster.rpc_other_node(pg, :get_local_members, [scope, :group1]) == []
    end

    test "#{pg} restart remote", %{pg: pg, scope: scope, local: local} do
      # Join from local
      :ok = pg.join(scope, :group1, local)

      # Check remote is synced
      Process.sleep(200)
      assert Cluster.rpc_other_node(pg, :get_members, [scope, :group1]) == [local]

      # Kill remote scope
      # remote_scope_pid = Cluster.rpc_other_node(Process, :whereis, [scope])
      # true = Cluster.rpc_other_node(Process, :exit, [remote_scope_pid, :kill])

      scope_pid = Cluster.rpc_other_node(Process, :whereis, [scope])
      ref = Process.monitor(scope_pid)

      true = Process.exit(scope_pid, :kill)

      receive do
        {:DOWN, ^ref, :process, ^scope_pid, :killed} -> :ok
      end

      # Restart remote scope and check remote is synced again
      {:ok, _new_scope_pid} = Cluster.rpc_other_node(pg, :start, [scope])
      Process.sleep(200)
      assert Cluster.rpc_other_node(pg, :get_members, [scope, :group1]) == [local]
    end

    test "#{pg} restart local", %{pg: pg, scope: scope, remote: remote} do
      # Join from remote
      :ok = Cluster.rpc_other_node(pg, :join, [scope, :group1, remote])
      assert Cluster.rpc_other_node(pg, :get_members, [scope, :group1]) == [remote]

      # Check local is synced
      Process.sleep(200)
      assert pg.get_members(scope, :group1) == [remote]

      # Kill local scope
      scope_pid = Process.whereis(scope)
      ref = Process.monitor(scope_pid)

      true = Process.exit(scope_pid, :kill)

      receive do
        {:DOWN, ^ref, :process, ^scope_pid, :killed} -> :ok
      end

      # Restart local scope and check local is synced again
      {:ok, _new_scope_pid} = pg.start(scope)
      Process.sleep(200)
      assert pg.get_members(scope, :group1) == [remote]
    end
  end
end
