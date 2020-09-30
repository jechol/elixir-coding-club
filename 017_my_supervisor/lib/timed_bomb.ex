defmodule TimedBomb do
  use GenServer
  require Logger

  def start_link(delay) do
    GenServer.start_link(__MODULE__, delay, name: __MODULE__)
  end

  def init(delay) do
    Process.send_after(self(), :bomb, delay)
    # Logger.info("Bomb scheduled after #{delay}ms.")
    {:ok, delay}
  end

  def handle_info(:bomb, delay) do
    # Logger.error("Bomb!!!!")
    {:stop, :normal, delay}
  end
end
