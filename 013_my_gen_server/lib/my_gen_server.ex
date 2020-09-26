defmodule MyGenServer do
  defstruct module: nil, state: nil

  def start_link(module, init_arg) do
    # Hint: self(), make_ref(), spawn_link(), send(), receive()
  end

  def call(server, request) do
    # Hint: send(), receive()
  end

  defp loop(module, state) do
    # Hint: receive(), send()
  end
end
