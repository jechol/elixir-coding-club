defmodule MyGenServerTest do
  use ExUnit.Case
  doctest MyGenServer

  defmodule Greet do
    def init(greet) do
      {:ok, greet}
    end

    def handle_call({:greet, name}, _from, greet) do
      {:reply, "#{greet} #{name}", greet}
    end
  end

  test "GenServer for reference" do
    {:ok, pid} = GenServer.start_link(Greet, "Hello")
    "Hello world" = GenServer.call(pid, {:greet, "world"})
  end

  test "MyGenServer" do
    {:ok, pid} = MyGenServer.start_link(Greet, "Hello")
    "Hello world" = MyGenServer.call(pid, {:greet, "world"})
  end
end
