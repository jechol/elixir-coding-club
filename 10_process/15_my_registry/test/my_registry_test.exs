defmodule MyRegistryTest do
  use ExUnit.Case

  for registry <- [Registry, MyRegistry] do
    @registry registry

    test "#{@registry} register/lookup/unregister" do
      reg_name = [@registry, Test1Reg] |> Module.concat()
      this = self()

      {:ok, _} = @registry.start_link(keys: :unique, name: reg_name)
      {:ok, _registry_pid} = @registry.register(reg_name, "hello", "world")

      {:error, {:already_registered, ^this}} = @registry.register(reg_name, "hello", "world")

      [{^this, "world"}] = @registry.lookup(reg_name, "hello")
      :ok = @registry.unregister(reg_name, "hello")
      [] = @registry.lookup(reg_name, "hello")
    end

    test "{:via, #{@registry}, {registry, key}}" do
      reg_name = [@registry, Test2Reg] |> Module.concat()
      {:ok, _} = @registry.start_link(keys: :unique, name: reg_name)

      name = {:via, @registry, {reg_name, "agent"}}
      {:ok, _} = Agent.start_link(fn -> 0 end, name: name)
      0 = Agent.get(name, & &1)
    end
  end
end
