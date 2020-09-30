defmodule LearnCoverageTest do
  use ExUnit.Case
  doctest LearnCoverage

  test "greets the world" do
    assert LearnCoverage.hello() == :world
  end
end
