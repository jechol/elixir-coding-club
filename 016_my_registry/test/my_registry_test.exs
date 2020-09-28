defmodule MyRegistryTest do
  use ExUnit.Case

  for registry <- [Registry, MyRegistry] do
    @registry registry

    test "#{@registry} register/lookup/unregister" do
      this = self()

      {:ok, _} = @registry.start_link(keys: :unique, name: Test1Reg)
      {:ok, _} = @registry.register(Test1Reg, "hello", "world")

      {:error, {:already_registered, ^this}} = @registry.register(Test1Reg, "hello", "world")

      [{^this, "world"}] = @registry.lookup(Test1Reg, "hello")

      :ok = @registry.unregister(Test1Reg, "hello")
    end

    test "{:via, #{@registry}, {registry, key}}" do
      reg_name = [@registry, Test2Reg] |> Module.concat()
      {:ok, _} = @registry.start_link(keys: :unique, name: reg_name)

      name = {:via, @registry, {reg_name, "agent"}}
      {:ok, _} = Agent.start_link(fn -> 0 end, name: name)
      name |> IO.inspect()
      0 = Agent.get(name, & &1)
    end
  end
end
