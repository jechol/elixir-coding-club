# list = Enum.to_list(1..10_000)
# map_fun = fn i -> [i, i * i] end

max = 100_000
buckets = 1000

Benchee.run(
  %{
    "AgentCounter.100K" => fn ->
      {:ok, pid} = AgentCounter.start_link()

      1..max
      |> Task.async_stream(fn c -> AgentCounter.increment(pid, rem(c, buckets)) end)
      |> Stream.run()

      sum =
        0..(buckets - 1)
        |> Task.async_stream(fn c -> AgentCounter.value(pid, rem(c, buckets)) end)
        |> Enum.reduce(0, fn {:ok, n}, acc -> acc + n end)

      if sum != max do
        IO.inspect(sum)
        raise RuntimeError
      end
    end,
    "EtsCounter.100K" => fn ->
      table = EtsCounter.start_link()

      1..max
      |> Task.async_stream(fn c -> EtsCounter.increment(table, rem(c, buckets)) end)
      |> Stream.run()

      sum =
        0..(buckets - 1)
        |> Task.async_stream(fn c -> EtsCounter.value(table, rem(c, buckets)) end)
        |> Enum.reduce(0, fn {:ok, n}, acc -> acc + n end)

      if sum != max do
        IO.inspect(sum)
        raise RuntimeError
      end
    end
  },
  time: 5,
  memory_time: 2
)
