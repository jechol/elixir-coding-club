defmodule MyAgentTest do
  use ExUnit.Case
  doctest MyAgent

  test "greets the world" do
    assert MyAgent.hello() == :world
  end
end
