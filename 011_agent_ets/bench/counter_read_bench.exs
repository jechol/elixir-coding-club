bench_read = fn counter_mod ->
  counters = 1

  # Write 벤치와 달리 read 는 shared lock 이어서 row 가 1개든 100개든 분산 여부가 ets 성능에 영향이 없다.
  # counters = 100

  tasks = 1_000
  repeat = 1_000

  {:ok, counter} = counter_mod.start_link()

  1..counters |> Enum.each(fn c -> counter_mod.increment(counter, c) end)

  1..tasks
  |> Task.async_stream(fn b ->
    1..repeat |> Enum.each(fn _ -> 1 = counter_mod.value(counter, :rand.uniform(counters)) end)
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
