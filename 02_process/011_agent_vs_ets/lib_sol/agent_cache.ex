defmodule AgentCache do
  @behaviour Cache

  def start_link() do
    Agent.start_link(fn -> %{} end)
  end

  def get(cache, key) do
    Agent.get(cache, fn map -> map |> Map.fetch(key) end)
  end

  def set(cache, key, value) do
    Agent.update(cache, fn map -> map |> Map.put(key, value) end)
  end
end
