defmodule MyEnumTest do
  use ExUnit.Case
  doctest MyEnum

  test "greets the world" do
    assert MyEnum.hello() == :world
  end
end
