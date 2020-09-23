defmodule AgentEtsTest do
  use ExUnit.Case
  doctest AgentEts

  test "greets the world" do
    assert AgentEts.hello() == :world
  end
end
