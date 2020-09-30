schedulers = :erlang.system_info(:schedulers)
repeat = 10000

bench_write = fn cache_mod, input ->
  {:ok, cache} = cache_mod.start_link()

  input
  |> Task.async_stream(fn task_input ->
    task_input
    |> Enum.each(fn {k, v} -> cache_mod.set(cache, k, v) end)
  end)
  |> Stream.run()
end

Benchee.run(
  [AgentCache, EtsCache]
  |> Enum.map(fn cache_mod ->
    {"#{cache_mod}", fn input -> bench_write.(cache_mod, input) end}
  end),
  inputs:
    [{1, 0.1}, {1, 0.5}, {schedulers, 0.1}, {schedulers, 0.5}]
    |> Enum.map(fn setup = {tasks, conflict} ->
      {"(tasks: #{tasks}, conflict: #{conflict})", setup}
    end),
  before_scenario: fn {tasks, conflict} ->
    import StreamData

    task_repeat = repeat |> div(tasks)
    keys = ((repeat - 1) * (1 - conflict)) |> trunc() |> Kernel.+(1)

    1..tasks
    |> Enum.map(fn _ ->
      {integer(1..keys), term() |> resize(10)}
      |> tuple()
      |> Enum.take(task_repeat)
    end)
  end
)
