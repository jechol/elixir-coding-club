defmodule EtsCache do
  @behaviour Cache

  def start_link() do
    {:ok, :ets.new(:ets_cache, [:public, write_concurrency: true, read_concurrency: true])}
  end

  def get(cache, key) do
    cache
    |> :ets.lookup(key)
    |> case do
      [{^key, value}] -> {:ok, value}
      [] -> :error
    end
  end

  def set(cache, key, value) do
    true = cache |> :ets.insert({key, value})
    :ok
  end
end
