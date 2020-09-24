defmodule AgentCounter do
  def start_link() do
    Agent.start_link(fn -> %{} end)
  end

  def value(pid, key) do
    Agent.get(pid, &Map.get(&1, key, 0))
  end

  def increment(pid, key) do
    Agent.update(pid, fn map -> Map.update(map, key, 1, &(&1 + 1)) end)
  end
end
