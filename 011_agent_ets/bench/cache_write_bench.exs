tasks = 1
repeat = 100

# keys = 1
keys = 1_000

value_length = 1_000

contents =
  (fn ->
     import StreamData

     1..tasks
     |> Enum.map(fn _ ->
       #  {integer(1..keys), integer() |> list_of(length: value_length)}
       {integer(1..keys), binary(length: 1000)}
       |> tuple()
       |> Enum.take(repeat)
     end)
   end).()

^tasks = contents |> Enum.count()
^repeat = contents |> List.first() |> Enum.count()
# ^value_length = contents |> List.first() |> List.first() |> elem(1) |> Enum.count()
^value_length = contents |> List.first() |> List.first() |> elem(1) |> byte_size()

bench_write = fn cache_mod ->
  {:ok, cache} = cache_mod.start_link()

  contents
  |> Task.async_stream(fn task_content ->
    task_content
    |> Enum.each(fn {k, v} -> cache_mod.set(cache, k, v) end)
  end)
  |> Stream.run()
end

Benchee.run(%{
  "AgentCache.Write" => fn ->
    bench_write.(AgentCache)
  end,
  "EtsCache.Write" => fn ->
    bench_write.(EtsCache)
  end
})
