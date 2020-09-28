defmodule Observing.ParentWorker do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  def init([]) do
    # link
    Observing.Worker.start_link(name: LinkedChild)

    # monitor
    monitored = spawn(&wait/0)
    Process.register(monitored, MonitoredChild)
    Process.monitor(monitored)

    {:ok, []}
  end

  def wait() do
    receive do
    end

    wait()
  end
end
