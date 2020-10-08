defmodule ObservingTest do
  use ExUnit.Case
  doctest Observing

  test "greets the world" do
    assert Observing.hello() == :world
  end
end
