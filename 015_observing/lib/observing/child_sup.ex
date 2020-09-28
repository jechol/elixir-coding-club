defmodule Observing.ChildSup do
  use Supervisor

  def start_link([]) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init([]) do
    children = [
      Supervisor.child_spec(Worker, id: Worker1),
      Supervisor.child_spec(Worker, id: Worker2)
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
