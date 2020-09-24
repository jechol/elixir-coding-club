bench_counter = fn counter_mod ->
  max = 100_000
  buckets = 1000
  watermark = max |> div(buckets)

  {:ok, counter} = counter_mod.start_link()

  0..(buckets - 1)
  |> Task.async_stream(fn b ->
    0..(watermark - 1) |> Enum.each(fn _ -> counter_mod.increment(counter, b) end)
  end)
  |> Stream.run()

  sum =
    0..(buckets - 1)
    |> Task.async_stream(fn b -> counter_mod.value(counter, b) end)
    |> Enum.reduce(0, fn {:ok, n}, acc -> acc + n end)

  if sum != max do
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
