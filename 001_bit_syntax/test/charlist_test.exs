defmodule CharlistTest do
  use ExUnit.Case

  # @moduletag :pending

  test "charlist_to_binary" do
    assert Charlist.charlist_to_binary('엘릭서') == "엘릭서"
  end

  test "binary_to_charlist" do
    assert Charlist.binary_to_charlist("엘릭서") == '엘릭서'
  end
end
