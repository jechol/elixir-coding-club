defmodule Charlist do
  def charlist_to_string(list) when is_list(list) do
    ""
  end

  def string_to_charlist(<<bin::binary>>) do
    ''
  end
end
