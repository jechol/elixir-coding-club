defmodule MyAgentTest do
  use ExUnit.Case

  for agent <- [Agent, MyAgent] do
    @agent agent

    test "#{@agent}" do
      this = self()
      ref = make_ref()

      {:ok, pid} =
        @agent.start_link(fn ->
          send(this, ref)
          %{}
        end)

      assert_receive ^ref

      assert @agent.get(pid, fn x -> map_size(x) end) == 0

      :ok = @agent.update(pid, fn map -> Map.put(map, :foo, :bar) end)
      assert @agent.get(pid, fn map -> Map.get(map, :foo) end) == :bar
    end
  end
end
