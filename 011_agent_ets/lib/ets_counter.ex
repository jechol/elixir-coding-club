defmodule EtsCounter do
  def start_link() do
    {:ok, :ets.new(:ets_private, [:public, write_concurrency: true, read_concurrency: true])}
  end

  def value(counter, key) do
    [[c]] =
      counter
      |> :ets.match({{:counter, key}, :"$0"})

    c
  end

  def increment(counter, key) do
    counter |> :ets.update_counter({:counter, key}, 1, {{:counter, key}, 0})
  end
end
