defmodule MyGenServerTest do
  use ExUnit.Case
  doctest MyGenServer

  test "greets the world" do
    assert MyGenServer.hello() == :world
  end
end
