defmodule Utf8Test do
  use ExUnit.Case

  # Examples from https://en.wikipedia.org/wiki/UTF-8

  @unicode_to_utf8 [
    {0x24, <<0x24::8>>},
    {0xA2, <<0xC2A2::16>>},
    {0x0939, <<0xE0A4B9::24>>},
    {0x20AC, <<0xE282AC::24>>},
    {0xD55C, <<0xED959C::24>>},
    {0x10348, <<0xF0908D88::32>>}
  ]

  describe "Utf8" do
    @describetag :pending

    test "encode" do
      for {unicode, utf8} <- @unicode_to_utf8 do
        assert Utf8.encode(unicode) == {:ok, utf8}
      end
    end

    test "decode" do
      for {unicode, utf8} <- @unicode_to_utf8 do
        assert Utf8.decode(utf8) == {:ok, unicode}
      end
    end
  end
end
