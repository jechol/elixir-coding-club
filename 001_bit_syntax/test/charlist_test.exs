defmodule CharlistTest do
  use ExUnit.Case

  @moduletag :pending

  test "charlist_to_string" do
    assert Charlist.charlist_to_string('엘릭서 Elixir') == "엘릭서 Elixir"
  end

  test "string_to_charlist" do
    assert Charlist.string_to_charlist("엘릭서 Elixir") == '엘릭서 Elixir'
  end
end
