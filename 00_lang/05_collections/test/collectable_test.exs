defmodule CollectableTest do
  use ExUnit.Case

  test "Tuple" do
    assert [1, 2, 3] |> Enum.into({}) == {1, 2, 3}
    assert [1, 2, 3] |> Enum.into({:a, :b}) == {:a, :b, 1, 2, 3}
  end
end
