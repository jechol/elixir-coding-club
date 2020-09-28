defmodule MyRegistry do
  def start_link(keys: :unique, name: reg_name) do
  end

  def register(reg_name, key, value) do
  end

  def lookup(reg_name, key) do
  end

  def unregister(reg_name, key) do
  end

  def register_name({reg_name, key}, pid) do
    # Hidden function. See Registry source at
    # https://github.com/elixir-lang/elixir/blob/1145dc01680aab7094f8a6dbd38b65185e14adb4/lib/elixir/lib/registry.ex#L244
  end

  def whereis_name({reg_name, key} = _name) do
    # Hidden function. See Registry source at
    # https://github.com/elixir-lang/elixir/blob/1145dc01680aab7094f8a6dbd38b65185e14adb4/lib/elixir/lib/registry.ex#L222
  end
end
