defmodule MySupervisorTest do
  use ExUnit.Case
  doctest MySupervisor

  test "greets the world" do
    assert MySupervisor.hello() == :world
  end
end
