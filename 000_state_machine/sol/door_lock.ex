defmodule DoorLock do
  use GenStateMachine, callback_mode: [:state_functions, :state_enter]
  import Definject

  defmodule Data do
    defstruct code: [], input: []
  end

  # interface
  def start_link(code) when is_list(code) do
    GenStateMachine.start_link(__MODULE__, code, [])
  end

  definject init(code) do
    {:ok, :locked, %Data{code: code}}
  end

  def button(pid, button) do
    GenStateMachine.cast(pid, {:button, button})
  end

  ## state callback
  definject locked(:enter, _old_state, %Data{}) do
    __MODULE__.do_lock()
    :keep_state_and_data
  end

  definject locked(:timeout, _, %Data{} = data) do
    {:keep_state, %Data{data | input: []}}
  end

  definject locked(:cast, {:button, button}, %Data{code: code, input: input} = data) do
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

  definject open(:enter, _old_state, %Data{}) do
    __MODULE__.do_unlock()
    :keep_state_and_data
  end

  definject open(:state_timeout, :lock, data) do
    {:next_state, :locked, data}
  end

  definject open(:cast, {:button, _}, _) do
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
