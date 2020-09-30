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

  # def count_parallel(counter_mod) do
  #   {:ok, counter} = counter_mod.start_link()

  #   0..999_9
  #   |> Enum.chunk_every(100)
  #   |> Task.async_stream(fn _ ->
  #     counter_mod.increment(counter, :rand.uniform(10))
  #   end)
  #   |> Stream.run()

  #   0..999
  #   |> Enum.map(fn i -> counter_mod.value(counter, i) end)
  #   |> Enum.reduce(0, &Kernel.+/2)
  # end

  # test "ets is not safe" do
  #   sum = count_parallel(EtsCounter)
  #   assert sum == 100_00
  # end
end
