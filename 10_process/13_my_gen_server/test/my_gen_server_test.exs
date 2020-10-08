defmodule MyGenServerTest do
  use ExUnit.Case
  doctest MyGenServer

  defmodule Adder do
    def init(offset) do
      {:ok, offset}
    end

    def handle_call({:add, num}, _from, offset) do
      {:reply, num + offset, offset}
    end
  end

  for gen_server <- [GenServer, MyGenServer] do
    @gen_server gen_server

    test "#{@gen_server}.call" do
      {:ok, pid} = @gen_server.start_link(Adder, 10)
      110 = @gen_server.call(pid, {:add, 100})
    end
  end
end
