defmodule DistributionTest do
  use ExUnit.Case
  doctest Distribution

  test "greets the world" do
    assert Distribution.hello() == :world
  end
end
