defmodule MyTaskTest do
  use ExUnit.Case

  for task <- [Task, MyTask] do
    @task task

    test "#{task} success" do
      this = self()
      task = %@task{owner: ^this, pid: _pid, ref: _ref} = @task.async(fn -> :foo end)

      assert :foo == @task.await(task)
    end

    test "#{task} failure" do
      Process.flag(:trap_exit, true)

      @task.async(fn -> raise RuntimeError end)

      assert_receive {:EXIT, _, {%RuntimeError{}, _}}
    end
  end
end
