# list = Enum.to_list(1..10_000)
# map_fun = fn i -> [i, i * i] end

max = 100_000
buckets = 1000

bench_counter = fn counter_mod ->
  {:ok, counter} = counter_mod.start_link()

  1..max
  |> Task.async_stream(fn c -> counter_mod.increment(counter, rem(c, buckets)) end)
  |> Stream.run()

  sum =
    0..(buckets - 1)
    |> Task.async_stream(fn c -> counter_mod.value(counter, rem(c, buckets)) end)
    |> Enum.reduce(0, fn {:ok, n}, acc -> acc + n end)

  if sum != max do
    IO.inspect(sum)
    raise RuntimeError
  end
end

Benchee.run(
  %{
    "AgentCounter.100K" => fn ->
      bench_counter.(AgentCounter)
    end,
    "EtsCounter.100K" => fn ->
      bench_counter.(EtsCounter)
    end
  },
  time: 5,
  memory_time: 2
)
