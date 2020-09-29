bench_write = fn counter_mod ->
  tasks = 1_000
  repeat = 1_000
  sum = tasks * repeat

  {:ok, counter} = counter_mod.start_link()

  ^sum =
    0..(tasks - 1)
    |> Task.async_stream(fn b ->
      0..(repeat - 1) |> Enum.each(fn _ -> counter_mod.increment(counter, b) end)
      counter_mod.value(counter, b)
    end)
    |> Enum.reduce(0, fn {:ok, n}, acc -> acc + n end)
end

Benchee.run(%{
  "AgentCounter.Write" => fn ->
    bench_write.(AgentCounter)
  end,
  "EtsCounter.Write" => fn ->
    bench_write.(EtsCounter)
  end
})
