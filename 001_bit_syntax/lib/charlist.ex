defmodule Charlist do
  def charlist_to_binary(list) when is_list(list) do
    ""
  end

  def binary_to_charlist(<<bin::binary>>) do
    ''
  end
end
