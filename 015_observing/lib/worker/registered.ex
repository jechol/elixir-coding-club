defmodule Worker.Registered do
  use GenServer

  def start_link(opts) do
    new_opts = Keyword.merge([name: __MODULE__], opts)
    GenServer.start_link(__MODULE__, [], new_opts)
  end
end
