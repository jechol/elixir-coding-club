defmodule AgentCounterTest do
  use ExUnit.Case, async: false

  @max 100_000
  @buckets 1000
  @bucket_size @max / @buckets

  setup do
    {:ok, pid} = AgentCounter.start_link()
    {:ok, %{pid: pid}}
  end

  test "count", %{pid: pid} do
    AgentCounter.value(pid, 0)
    AgentCounter.increment(pid, 0)
    AgentCounter.increment(pid, 0)

    assert AgentCounter.value(pid, 0) == 2
    assert AgentCounter.value(pid, 1) == 0
  end

  test "bench", %{pid: pid} do
    {time, :ok} =
      :timer.tc(fn ->
        1..@max
        |> Task.async_stream(fn c -> AgentCounter.increment(pid, rem(c, @buckets)) end)
        |> Stream.run()
      end)

    assert AgentCounter.value(pid, 0) == @bucket_size

    IO.puts("Agent #{time / 1000}ms taken.")
  end
end
