defmodule Observing.ParentWorker do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  def init([]) do
    # ETS
    :ets.new(:parent, [:public, :named_table])
    :ets.insert(:parent, {:message, "check this row in observer"})

    # link
    # {:ok, pid} = Observing.Worker.start_link(name: LinkedChild)
    # send(pid, :check_this_message_in_observer)

    # link
    linked = spawn_link(&wait/0)
    Process.register(linked, Linked)

    # monitor
    {monitored, _ref} = spawn_monitor(&wait/0)
    Process.register(monitored, Monitored)

    {:ok, []}
  end

  def wait() do
    receive do
    end
  end
end
