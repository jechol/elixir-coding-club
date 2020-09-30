schedulers = :erlang.system_info(:schedulers)
repeat = 100_000

bench_write = fn counter_mod, {tasks, keys} ->
  {:ok, counter} = counter_mod.start_link()
  task_repeat = repeat |> div(tasks)

  1..tasks
  |> Task.async_stream(fn _ ->
    1..task_repeat |> Enum.each(fn _ -> counter_mod.increment(counter, :rand.uniform(keys)) end)
  end)
  |> Stream.run()
end

Benchee.run(
  [AgentCounter, EtsCounter]
  |> Enum.map(fn counter_mod ->
    {counter_mod, fn input -> bench_write.(counter_mod, input) end}
  end),
  inputs:
    [{1, 1}, {1, 1000}, {schedulers, 1}, {schedulers, 1000}]
    |> Enum.map(fn {tasks, keys} ->
      {%{tasks: tasks, keys: keys} |> inspect(), {tasks, keys}}
    end),
  warmup: 1,
  time: 2
)
