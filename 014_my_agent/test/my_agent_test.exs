defmodule MyAgentTest do
  use ExUnit.Case
  doctest MyAgent

  test "Agent for reference" do
    {:ok, pid} = Agent.start_link(fn -> %{} end)
    assert Agent.get(pid, fn x -> x end) == %{}

    Agent.update(pid, fn map -> Map.put(map, :foo, :bar) end)
    assert Agent.get(pid, fn map -> Map.get(map, :foo) end) == :bar
  end

  test "MyAgent for reference" do
    {:ok, pid} = MyAgent.start_link(fn -> %{} end)
    assert MyAgent.get(pid, fn x -> x end) == %{}

    MyAgent.update(pid, fn map -> Map.put(map, :foo, :bar) end)
    assert MyAgent.get(pid, fn map -> Map.get(map, :foo) end) == :bar
  end
end
