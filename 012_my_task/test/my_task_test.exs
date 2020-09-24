defmodule MyTaskTest do
  use ExUnit.Case
  doctest MyTask

  test "greets the world" do
    assert MyTask.hello() == :world
  end
end
