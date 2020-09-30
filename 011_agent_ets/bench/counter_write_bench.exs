bench_write = fn counter_mod ->
  counters = 1

  # AgentCounter는 map 단위로 update 되지만, EtsCounter 는 row 단위로 update 되기 때문에,
  # row 를 늘리면 EtsCounter 의 성능이 core 수만큼 증가한다.
  # counters = 100

  tasks = 1_000
  repeat = 1_000
  sum = tasks * repeat

  {:ok, counter} = counter_mod.start_link()

  1..tasks
  |> Task.async_stream(fn b ->
    1..repeat |> Enum.each(fn _ -> counter_mod.increment(counter, :rand.uniform(counters)) end)
  end)
  |> Stream.run()

  ^sum =
    1..counters
    |> Enum.map(fn c -> counter_mod.value(counter, c) end)
    |> Enum.reduce(0, &Kernel.+/2)
end

Benchee.run(%{
  "AgentCounter.Write" => fn ->
    bench_write.(AgentCounter)
  end,
  "EtsCounter.Write" => fn ->
    bench_write.(EtsCounter)
  end
})
