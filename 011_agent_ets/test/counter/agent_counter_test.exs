defmodule AgentCounterTest do
  use ExUnit.Case, async: false

  test "value return 0 for never counted" do
    {:ok, counter} = AgentCounter.start_link()
    assert AgentCounter.value(counter, :never_counted) == 0
  end

  test "increment" do
    {:ok, counter} = AgentCounter.start_link()

    Task.async(fn ->
      AgentCounter.increment(counter, :a)
      AgentCounter.increment(counter, :a)
      AgentCounter.increment(counter, :b)

      assert AgentCounter.value(counter, :a) == 2
    end)
    |> Task.await()
  end
end
