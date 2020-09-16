defmodule DoorLock do
  use GenStateMachine, callback_mode: :state_functions

  defmodule Data do
    defstruct code: [], input: []
  end

  # interface
  def start_link(code) when is_list(code) do
    GenStateMachine.start_link(__MODULE__, code, [])
  end

  def init(code) do
    {:ok, :locked, %Data{code: code}}
  end

  def button(pid, button) do
    GenStateMachine.cast(pid, {:button, button})
  end

  ## state callback

  ## actions
  def do_lock() do
    IO.puts("Locked")
  end

  def do_unlock() do
    IO.puts("Unlocked")
  end
end
