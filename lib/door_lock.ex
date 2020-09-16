defmodule DoorLock do
  use GenStateMachine, callback_mode: [:state_functions, :state_enter]

  defmodule Data do
    defstruct code: [], length: 0, buttons: []
  end

  # interface
  def start_link(code) when is_list(code) do
    GenStateMachine.start_link(__MODULE__, code, [])
  end

  def init(code) do
    {:ok, :locked, %Data{code: code, length: length(code)}}
  end

  def button(pid, button) do
    GenStateMachine.cast(pid, {:button, button})
  end

  ## state callback
  def locked(:enter, _old_state, %Data{} = data) do
    do_lock()
    {:keep_state, %Data{data | buttons: []}}
  end

  def locked(:cast, {:button, button}, %Data{code: code, length: length, buttons: buttons} = data) do
    (buttons ++ [button])
    |> Enum.reverse()
    |> Enum.take(length)
    |> Enum.reverse()
    |> case do
      ^code ->
        {:next_state, :open, %Data{data | buttons: []}, [{:state_timeout, 5000, :lock}]}

      new_buttons ->
        {:keep_state, %Data{buttons: new_buttons}}
    end
  end

  def open(:enter, _old_state, %Data{}) do
    do_unlock()
    :keep_state_and_data
  end

  def open(:state_timeout, :lock, data) do
    do_lock()
    {:next_state, :locked, data}
  end

  def open(:cast, {:button, _}, data) do
    {:next_state, :open, data}
  end

  ## actions
  defp do_lock() do
    IO.puts("Locked")
  end

  defp do_unlock() do
    IO.puts("Unlocked")
  end
end
