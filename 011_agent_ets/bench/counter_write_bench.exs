bench_write = fn counter_mod ->
  tasks = 1000
  repeat = 1_000
  sum = tasks * repeat

  {:ok, counter} = counter_mod.start_link()

  ^sum =
    1..tasks
    |> Task.async_stream(fn b ->
      1..repeat |> Enum.each(fn r -> ^r = counter_mod.increment(counter, b) end)
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
