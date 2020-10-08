defmodule MyTask do
  defstruct pid: nil, ref: nil

  def async(fun) do
    from = self()
    ref = make_ref()

    pid =
      spawn_link(fn ->
        ret = fun.()

        receive do
          {:await, ^from, ^ref} -> send(from, {:result, self(), ref, ret})
        end
      end)

    %MyTask{pid: pid, ref: ref}
  end

  def await(%MyTask{ref: ref, pid: pid}) do
    send(pid, {:await, self(), ref})

    receive do
      {:result, ^pid, ^ref, ret} -> ret
    end
  end
end
