defmodule EtsCounterTest do
  use ExUnit.Case, async: false

  test "value return 0 for never counted" do
    {:ok, counter} = EtsCounter.start_link()
    assert EtsCounter.value(counter, :never_counted) == 0
  end

  test "increment" do
    {:ok, counter} = EtsCounter.start_link()

    Task.async(fn ->
      EtsCounter.increment(counter, :a)
      EtsCounter.increment(counter, :a)
      EtsCounter.increment(counter, :b)

      assert EtsCounter.value(counter, :a) == 2
    end)
    |> Task.await()
  end
end
