defmodule EtsCounterTest do
  use ExUnit.Case, async: false

  @max 100_000

  test "single bucket" do
    table = EtsCounter.start_link()

    {time, :ok} =
      :timer.tc(fn ->
        1..@max
        |> Task.async_stream(fn _ -> EtsCounter.increment(table, 0) end)
        |> Stream.run()
      end)

    assert @max == table |> EtsCounter.value(0)

    IO.puts("single bucket: #{time / 1000}ms taken.")
  end

  @buckets 1000
  @bucket_size @max / @buckets

  test "#{@buckets} buckets" do
    table = EtsCounter.start_link(write_concurrency: false)

    {time, :ok} =
      :timer.tc(fn ->
        1..@max
        |> Task.async_stream(fn c -> EtsCounter.increment(table, rem(c, @buckets)) end)
        |> Stream.run()
      end)

    assert @bucket_size == table |> EtsCounter.value(0)

    IO.puts("#{@buckets} buckets: #{time / 1000}ms taken.")
  end

  test "#{@buckets} buckets with write_concurrency" do
    table = EtsCounter.start_link(write_concurrency: true)

    {time, :ok} =
      :timer.tc(fn ->
        1..@max
        |> Task.async_stream(fn c -> EtsCounter.increment(table, rem(c, @buckets)) end)
        |> Stream.run()
      end)

    assert @bucket_size == table |> EtsCounter.value(0)

    IO.puts("#{@buckets} buckets + write_concurrency: #{time / 1000}ms taken.")
  end
end
