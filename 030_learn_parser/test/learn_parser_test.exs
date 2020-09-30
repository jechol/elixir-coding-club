defmodule LearnParserTest do
  use ExUnit.Case
  doctest LearnParser

  test "greets the world" do
    assert LearnParser.hello() == :world
  end
end
