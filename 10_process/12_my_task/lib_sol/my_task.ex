defmodule MyTask do
  defstruct owner: nil, pid: nil, ref: nil

  def async(fun) do
    from = self()
    ref = make_ref()
    pid = spawn_link(fn -> send(from, {ref, fun.()}) end)

    %MyTask{owner: from, pid: pid, ref: ref}
  end

  def await(%MyTask{ref: ref}) do
    receive do
      {^ref, value} -> value
    end
  end
end
