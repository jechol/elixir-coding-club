defmodule AgentCounter do
  def start_link() do
    Agent.start_link(fn -> 0 end)
  end

  def value(pid) do
    Agent.get(pid, & &1)
  end

  def increment(pid) do
    Agent.update(pid, &(&1 + 1))
  end
end
