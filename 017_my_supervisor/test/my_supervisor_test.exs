defmodule MySupervisorTest do
  use ExUnit.Case

  test "Restarts after termination" do
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

    # Supervisor tries 3 restarts for 5 seconds, and exit itself.
    Process.sleep(700)
    refute Process.alive?(sup)
  end
end
