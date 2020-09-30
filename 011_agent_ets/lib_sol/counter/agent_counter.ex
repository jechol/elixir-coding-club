defmodule AgentCounter do
  @behaviour Counter

  def start_link() do
    Agent.start_link(fn -> %{} end)
  end

  def value(pid, key) do
    Agent.get(pid, &Map.get(&1, key, 0))
  end

  def increment(pid, key) do
    caller = self()
    ref = make_ref()

    Agent.update(pid, fn map ->
      new_map = %{^key => new_value} = Map.update(map, key, 1, &(&1 + 1))
      send(caller, {pid, ref, new_value})
      new_map
    end)

    receive do
      {^pid, ^ref, new_value} -> new_value
    end
  end
end
