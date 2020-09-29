defmodule AgentCounterTest do
  use ExUnit.Case, async: false

  for counter <- [AgentCounter, EtsCounter] do
    @counter counter

    describe "#{@counter}" do
      test "value return 0 for never counted" do
        {:ok, counter} = @counter.start_link()
        assert @counter.value(counter, :never_counted) == 0
      end

      test "increment" do
        {:ok, counter} = @counter.start_link()

        Task.async(fn ->
          @counter.increment(counter, :a)
          @counter.increment(counter, :a)
          @counter.increment(counter, :b)

          assert @counter.value(counter, :a) == 2
        end)
        |> Task.await()
      end
    end
  end
end
