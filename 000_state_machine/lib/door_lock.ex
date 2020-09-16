defmodule DoorLock do
  use GenStateMachine, callback_mode: [:state_functions, :state_enter]

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
  def locked(:enter, _old_state, _data) do
    do_lock()
    :keep_state_and_data
  end

  def locked(:timeout, _, data) do
    do_lock()
    {:keep_state, %Data{data | input: []}}
  end

  def locked(:cast, {:button, button}, %Data{code: code, input: input} = data) do
    (input ++ [button])
    |> Enum.reverse()
    |> Enum.take(code |> length())
    |> Enum.reverse()
    |> case do
      ^code ->
        {:next_state, :open, %Data{data | input: []}, [{:state_timeout, 5000, :lock}]}

      new_input ->
        {:keep_state, %Data{data | input: new_input}, 5000}
    end
  end

  def open(:enter, _old_state, _data) do
    do_unlock()
    :keep_state_and_data
  end

  def open(:state_timeout, :lock, data) do
    {:next_state, :locked, data}
  end

  def open(:cast, {:button, _}, _) do
    :keep_state_and_data
  end

  ## actions
  def do_lock() do
    IO.puts("Locked")
  end

  def do_unlock() do
    IO.puts("Unlocked")
  end
end
