defmodule MySupervisorTest do
  use ExUnit.Case

  for sup_mod <- [Supervisor, MySupervisor] do
    @sup_mod sup_mod

    test "#{@sup_mod} for permanent restart" do
      Process.flag(:trap_exit, true)

      children = [
        # Terminate every 200ms
        {TimedBomb, 200}
      ]

      {:ok, sup} = Supervisor.start_link(children, strategy: :one_for_one)
      first = Process.whereis(TimedBomb)
      # Wait for first termination
      Process.sleep(300)
      second = Process.whereis(TimedBomb)

      assert first != second
      assert Process.alive?(sup)
    end
  end
end
