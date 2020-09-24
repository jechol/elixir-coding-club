bench_read = fn counter_mod ->
  buckets = 1_000
  repeat = 1_000

  {:ok, counter} = counter_mod.start_link()

  0..(buckets - 1)
  |> Task.async_stream(fn b ->
    counter_mod.increment(counter, b)
    0..(repeat - 1) |> Enum.each(fn _ -> counter_mod.value(counter, b) end)
  end)
  |> Stream.run()
end

Benchee.run(%{
  "AgentCounter.Read" => fn ->
    bench_read.(AgentCounter)
  end,
  "EtsCounter.Read" => fn ->
    bench_read.(EtsCounter)
  end
})
