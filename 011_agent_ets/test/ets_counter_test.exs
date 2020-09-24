defmodule EtsCounterTest do
  use ExUnit.Case, async: false

  @max 100_000

  test "single partition" do
    table = EtsCounter.start_link()

    {time, :ok} =
      :timer.tc(fn ->
        1..@max
        |> Task.async_stream(fn _ -> EtsCounter.increment(table, 0) end)
        |> Stream.run()
      end)

    assert @max == table |> EtsCounter.value()

    IO.puts("#{time / 1000}ms taken.")
  end

  test "10 partitions" do
    table = EtsCounter.start_link(write_concurrency: false)

    {time, :ok} =
      :timer.tc(fn ->
        1..@max
        |> Task.async_stream(fn c -> EtsCounter.increment(table, rem(c, 10)) end)
        |> Stream.run()
      end)

    assert @max == table |> EtsCounter.value()

    IO.puts("10: #{time / 1000}ms taken.")
  end

  test "10 partitions with write_concurrency" do
    table = EtsCounter.start_link(write_concurrency: true)

    {time, :ok} =
      :timer.tc(fn ->
        1..@max
        |> Task.async_stream(fn c -> EtsCounter.increment(table, rem(c, 10)) end)
        |> Stream.run()
      end)

    assert @max == table |> EtsCounter.value()

    IO.puts("10 + write : #{time / 1000}ms taken.")
  end
end
