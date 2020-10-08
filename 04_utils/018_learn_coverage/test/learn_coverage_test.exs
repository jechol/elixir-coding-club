defmodule LearnCoverageTest do
  use ExUnit.Case

  test "call" do
    assert LearnCoverage.target_called()
    assert LearnCoverage.not_target_called()
  end
end
