defmodule AgentCounterTest do
  use ExUnit.Case, async: false

  setup do
    {:ok, pid} = AgentCounter.start_link()
    {:ok, %{pid: pid}}
  end

  test "count", %{pid: pid} do
    assert AgentCounter.value(pid) == 0
    AgentCounter.increment(pid)
    AgentCounter.increment(pid)

    assert AgentCounter.value(pid) == 2
  end

  test "bench", %{pid: pid} do
    assert AgentCounter.value(pid) == 0

    {time, :ok} =
      :timer.tc(fn ->
        1..100_000
        |> Task.async_stream(fn c -> AgentCounter.increment(pid) end)
        |> Stream.run()
      end)

    IO.puts("#{time / 1000}ms taken.")
  end
end
