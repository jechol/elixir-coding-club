defmodule EtsCounter do
  def start_link(opts \\ []) do
    :ets.new(:ets_private, [:public] ++ opts)
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
