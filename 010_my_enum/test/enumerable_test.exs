defmodule EnumerableTest do
  use ExUnit.Case

  test "BitString" do
    assert <<1, 2, 3>> |> Enum.to_list() == [1, 2, 3]
    assert <<1, 2, 3>> |> Enum.map(&(&1 * 10)) == [10, 20, 30]
    assert <<1, 2, 3>> |> Enum.filter(&(rem(&1, 2) == 1)) == [1, 3]
    assert <<1, 2, 3>> |> Enum.reduce(10, &(&1 + &2)) == 16
  end
end
