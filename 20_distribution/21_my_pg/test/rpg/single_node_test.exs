defmodule Rpg.SingleNodeTest do
  use ExUnit.Case

  for pg <- [:pg, Rpg] do
    setup %{test: test} do
      pg = unquote(pg)
      scope = :"#{pg}-#{test}"
      {:ok, _pid} = pg.start_link(scope)
      {:ok, %{pg: pg, scope: scope}}
    end

    test "#{pg} which_groups", %{pg: pg, scope: scope} do
      assert pg.which_groups(scope) == []

      pid1 = self()
      :ok = pg.join(scope, :group1, pid1)
      :ok = pg.join(scope, :group2, pid1)

      assert pg.which_groups(scope) |> Enum.member?(:group1)
      assert pg.which_groups(scope) |> Enum.member?(:group2)
    end

    test "#{pg} join group", %{pg: pg, scope: scope} do
      pid1 = self()

      :ok = pg.join(scope, :group1, pid1)
      assert pg.get_members(scope, :group1) == [pid1]
      assert pg.get_local_members(scope, :group1) == [pid1]

      # Join twice
      :ok = pg.join(scope, :group1, pid1)
      assert pg.get_members(scope, :group1) == [pid1, pid1]
      assert pg.get_local_members(scope, :group1) == [pid1, pid1]

      pid2 = spawn_link(Process, :sleep, [:infinity])
      :ok = pg.join(scope, :group1, pid2)
      assert pg.get_members(scope, :group1) == [pid2, pid1, pid1]
      assert pg.get_local_members(scope, :group1) == [pid2, pid1, pid1]
    end

    test "#{pg} leave group", %{pg: pg, scope: scope} do
      pid1 = self()

      # Join twice
      :ok = pg.join(scope, :group1, pid1)
      :ok = pg.join(scope, :group1, pid1)

      # Leave once
      :ok = pg.leave(scope, :group1, pid1)
      assert pg.get_members(scope, :group1) == [pid1]

      # Leave once more
      :ok = pg.leave(scope, :group1, pid1)
      assert pg.get_members(scope, :group1) == []
      assert pg.get_local_members(scope, :group1) == []
    end

    test "#{pg} member dies", %{pg: pg, scope: scope} do
      pid1 =
        spawn_link(fn ->
          receive do
            :exit -> :ok
          end
        end)

      # Join twice
      :ok = pg.join(scope, :group1, pid1)
      :ok = pg.join(scope, :group1, pid1)
      assert pg.get_members(scope, :group1) == [pid1, pid1]

      # Kill pid1
      send(pid1, :exit)

      # Wait for pg to catch DOWN
      Process.sleep(100)
      assert pg.get_members(scope, :group1) == []
    end
  end
end
