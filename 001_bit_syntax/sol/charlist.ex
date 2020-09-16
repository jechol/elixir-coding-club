defmodule Charlist do
  def charlist_to_string(list) when is_list(list) do
    list
    |> Enum.map(&Utf8.encode/1)
    |> Enum.reduce(<<>>, fn bin, acc -> acc <> bin end)
  end

  def string_to_charlist(<<bin::binary>>) do
    do_string_to_charlist(bin, [])
  end

  defp do_string_to_charlist(<<>>, acc) do
    acc
  end

  defp do_string_to_charlist(<<0b0::1, _::bits>> = bin, acc) do
    <<current::binary-size(1), tail::binary>> = bin
    do_string_to_charlist(tail, acc ++ [Utf8.decode(current)])
  end

  defp do_string_to_charlist(<<0b110::3, _::bits>> = bin, acc) do
    <<current::binary-size(2), tail::binary>> = bin
    do_string_to_charlist(tail, acc ++ [Utf8.decode(current)])
  end

  defp do_string_to_charlist(<<0b1110::4, _::bits>> = bin, acc) do
    <<current::binary-size(3), tail::binary>> = bin
    do_string_to_charlist(tail, acc ++ [Utf8.decode(current)])
  end

  defp do_string_to_charlist(<<0b11110::5, _::bits>> = bin, acc) do
    <<current::binary-size(5), tail::binary>> = bin
    do_string_to_charlist(tail, acc ++ [Utf8.decode(current)])
  end
end
