defmodule LearnDistTest do
  use ExUnit.Case
  doctest LearnDist

  test "greets the world" do
    assert LearnDist.hello() == :world
  end
end
