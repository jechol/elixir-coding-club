defmodule Observing.ChildSup do
  use Supervisor

  def start_link([]) do
    Supervisor.start_link(__MODULE__, [], name: ChildSup)
  end

  @impl true
  def init([]) do
    children = [
      Supervisor.child_spec(Observing.Worker, id: Observing.Worker1),
      Supervisor.child_spec(Observing.Worker, id: Observing.Worker2)
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
