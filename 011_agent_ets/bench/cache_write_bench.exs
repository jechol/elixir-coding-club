bench_write = fn cache_mod, input ->
  {:ok, cache} = cache_mod.start_link()

  input
  |> Task.async_stream(fn task_input ->
    task_input
    |> Enum.each(fn {k, v} -> cache_mod.set(cache, k, v) end)
  end)
  |> Stream.run()
end

schedulers = :erlang.system_info(:schedulers)

Benchee.run(
  %{
    "AgentCache.Write" => fn input ->
      bench_write.(AgentCache, input)
    end,
    "EtsCache.Write" => fn input ->
      bench_write.(EtsCache, input)
    end
  },
  inputs:
    [{1, 0.1}, {1, 0.5}, {schedulers, 0.1}, {schedulers, 0.5}]
    |> Enum.map(fn setup = {tasks, conflict} ->
      {"(tasks: #{tasks}, conflict: #{conflict})", setup}
    end),
  before_scenario: fn {tasks, conflict} ->
    repeat = 10000
    task_repeat = repeat |> div(tasks)
    keys = ((repeat - 1) * (1 - conflict)) |> trunc() |> Kernel.+(1)

    input =
      (fn ->
         import StreamData

         1..tasks
         |> Enum.map(fn _ ->
           {integer(1..keys), term() |> resize(10)}
           |> tuple()
           |> Enum.take(task_repeat)
         end)
       end).()

    ^tasks = input |> Enum.count()
    ^repeat = input |> Enum.map(&Enum.count/1) |> Enum.sum()

    input
  end
)
