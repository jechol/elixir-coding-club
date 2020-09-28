defmodule MyAgent do
  use GenServer

  def start_link(init_fun) do
    GenServer.start_link(__MODULE__, init_fun)
  end

  def init(init_fun) do
    {:ok, init_fun.()}
  end

  def get(pid, get_fun) do
    GenServer.call(pid, {:get, get_fun})
  end

  def update(pid, update_fun) do
    GenServer.call(pid, {:update, update_fun})
  end

  # callback

  def handle_call({:get, get_fun}, _from, state) do
    {:reply, get_fun.(state), state}
  end

  def handle_call({:update, update_fun}, _from, state) do
    {:reply, :ok, update_fun.(state)}
  end
end
