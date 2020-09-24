defmodule MyTaskTest do
  use ExUnit.Case

  test "Task.async,await for reference" do
    task = Task.async(fn -> :foo end)

    assert :foo == Task.await(task)
  end

  test "success" do
    task = MyTask.async(fn -> :foo end)

    assert :foo == MyTask.await(task)
  end

  test "failure" do
    Process.flag(:trap_exit, true)

    MyTask.async(fn -> raise RuntimeError end)

    assert_receive {:EXIT, _, {%RuntimeError{}, _}}
  end
end
