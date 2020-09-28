defmodule MyRegistry do
  def start_link(keys: :unique, name: reg_name) do
    {:ok, _reg} = Agent.start_link(fn -> %{} end, name: reg_name)
  end

  def register(reg_name, key, value) do
    this = self()

    case Agent.get(reg_name, fn map -> map |> Map.fetch(key) end) do
      {:ok, {existing_pid, _existing_value}} ->
        {:error, {:already_registered, existing_pid}}

      :error ->
        Agent.update(reg_name, fn map -> map |> Map.put_new(key, {this, value}) end)
        {:ok, self()}
    end
  end

  def lookup(reg_name, key) do
    Agent.get(reg_name, fn map -> map |> Map.get(key, []) |> List.wrap() end)
  end

  def unregister(reg_name, key) do
    Agent.update(reg_name, fn map -> map |> Map.delete(key) end)
  end

  def register_name({reg_name, key}, pid) do
    # Hidden function. See Registry source at
    # https://github.com/elixir-lang/elixir/blob/1145dc01680aab7094f8a6dbd38b65185e14adb4/lib/elixir/lib/registry.ex#L244

    register(reg_name, key, pid)
    :yes
  end

  def whereis_name({reg_name, key} = _name) do
    # Hidden function. See Registry source at
    # https://github.com/elixir-lang/elixir/blob/1145dc01680aab7094f8a6dbd38b65185e14adb4/lib/elixir/lib/registry.ex#L222

    Agent.get(reg_name, fn map -> map |> Map.get(key) end)
    |> case do
      {pid, _} -> pid
      nil -> :undefined
    end
  end
end
