defimpl Collectable, for: Tuple do
  def into(init) do
    fun = fn
      acc, {:cont, x} -> [x | acc]
      acc, :done -> acc |> Enum.reverse() |> List.to_tuple()
    end

    {init |> Tuple.to_list() |> Enum.reverse(), fun}
  end
end
