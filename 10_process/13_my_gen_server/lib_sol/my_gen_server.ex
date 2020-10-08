defmodule MyGenServer do
  def start_link(module, init_arg) do
    this = self()
    ref = make_ref()

    pid =
      spawn_link(fn ->
        {:ok, state} = module.init(init_arg)
        send(this, ref)
        loop(module, state)
      end)

    receive do
      ^ref -> {:ok, pid}
    end
  end

  def call(server, request) do
    ref = make_ref()
    send(server, {:"$gen_call", request, self(), ref})

    receive do
      {^ref, reply} -> reply
    end
  end

  defp loop(module, state) do
    receive do
      {:"$gen_call", request, from, ref} ->
        {:reply, reply, state} = module.handle_call(request, from, state)
        send(from, {ref, reply})
        loop(module, state)
    end
  end
end
