defmodule EtsCounter do
  def start_link(opts \\ []) do
    :ets.new(:ets_private, [:public] ++ opts)
  end

  def value(counter) do
    counter
    |> :ets.match({{:counter, :_}, :"$0"})
    |> Enum.map(fn [c] -> c end)
    # |> IO.inspect()
    |> Enum.sum()
  end

  def increment(counter, partition) do
    counter |> :ets.update_counter({:counter, partition}, 1, {{:counter, partition}, 0})
  end
end
