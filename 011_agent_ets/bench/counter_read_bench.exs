bench_read = fn counter_mod ->
  tasks = 1_000
  repeat = 1_000

  {:ok, counter} = counter_mod.start_link()

  1..tasks
  |> Task.async_stream(fn b ->
    counter_mod.increment(counter, b)
    1..repeat |> Enum.each(fn _ -> 1 = counter_mod.value(counter, b) end)
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
