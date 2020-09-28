defmodule MyRegistryTest do
  use ExUnit.Case
  doctest MyRegistry

  test "greets the world" do
    assert MyRegistry.hello() == :world
  end
end
