defmodule Worker.Parent do
  use GenServer

  def start_link([]) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    {:ok, child} = Worker.Anonymous.start_link([])
    Worker.Anonymous.start_link([])
    {:ok, child} = {:ok, nil}

    {:ok, %{child: child}}
  end
end
