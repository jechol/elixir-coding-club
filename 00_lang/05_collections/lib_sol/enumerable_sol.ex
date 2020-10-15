defimpl Enumerable, for: BitString do
  def count(bin), do: {:ok, byte_size(bin)}
  def member?(_bin, _element), do: {:error, __MODULE__}

  def reduce(_, {:halt, acc}, _fun), do: {:halted, acc}
  def reduce(bin, {:suspend, acc}, fun), do: {:suspended, acc, &reduce(bin, &1, fun)}
  def reduce(<<>>, {:cont, acc}, _fun), do: {:done, acc}

  def reduce(<<head::8, tail::binary>>, {:cont, acc}, fun),
    do: reduce(tail, fun.(head, acc), fun)

  def slice(bin),
    do:
      {:ok, byte_size(bin),
       fn start, length ->
         <<_::binary-size(start), x::binary-size(length), _::binary>> = bin
         x
       end}
end
