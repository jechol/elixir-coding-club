defmodule Utf8 do
  # +-------+---------+----------+----------+----------+----------+----------+
  # | Bytes | First   | Last     | Byte 1   | Byte 2   | Byte 3   | Byte 4   |
  # +-------+---------+----------+----------+----------+----------+----------+
  # | 1     | U+0000  | U+007F   | 0xxxxxxx |          |          |          |
  # +-------+---------+----------+----------+----------+----------+----------+
  # | 2     | U+0080  | U+07FF   | 110xxxxx | 10xxxxxx |          |          |
  # +-------+---------+----------+----------+----------+----------+----------+
  # | 3     | U+0800  | U+FFFF   | 1110xxxx | 10xxxxxx | 10xxxxxx |          |
  # +-------+---------+----------+----------+----------+----------+----------+
  # | 4     | U+10000 | U+10FFFF | 11110xxx | 10xxxxxx | 10xxxxxx | 10xxxxxx |
  # +-------+---------+----------+----------+----------+----------+----------+
  def encode(n) when is_integer(n) and n >= 0x0000 and n < 0x0080 do
    {:ok, <<0::1, n::7>>}
  end

  def encode(n) when is_integer(n) and n >= 0x0080 and n < 0x0800 do
    <<0::5, first::5, second::6>> = <<n::16>>
    {:ok, <<0b110::3, first::5, 0b10::2, second::6>>}
  end

  def encode(n) when is_integer(n) and n >= 0x0800 and n < 0x10000 do
    <<first::4, second::6, third::6>> = <<n::16>>
    {:ok, <<0b1110::4, first::4, 0b10::2, second::6, 0b10::2, third::6>>}
  end

  def encode(n) when is_integer(n) and n >= 0x10000 and n < 0x110000 do
    <<first::3, second::6, third::6, fourth::6>> = <<n::21>>
    {:ok, <<0b11110::5, first::3, 0b10::2, second::6, 0b10::2, third::6, 0b10::2, fourth::6>>}
  end

  def encode(_) do
    {:error, :badarg}
  end

  def decode(<<0::1, n::7>>) do
    {:ok, n}
  end

  def decode(<<0b110::3, first::5, 0b10::2, second::6>>) do
    <<n::16>> = <<0::5, first::5, second::6>>
    {:ok, n}
  end

  def decode(<<0b1110::4, first::4, 0b10::2, second::6, 0b10::2, third::6>>) do
    <<n::16>> = <<first::4, second::6, third::6>>
    {:ok, n}
  end

  def decode(<<0b11110::5, first::3, 0b10::2, second::6, 0b10::2, third::6, 0b10::2, fourth::6>>) do
    <<n::21>> = <<first::3, second::6, third::6, fourth::6>>
    {:ok, n}
  end
end
