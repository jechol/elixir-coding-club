defmodule MyTask do
  defstruct pid: nil, ref: nil

  def async(fun) do
    # spawn_link, make_ref, send, receive 를 사용하여 구현
  end

  def await(%MyTask{pid: pid, ref: ref}) do
    # send, receive 를 사용하여 구현
  end
end
