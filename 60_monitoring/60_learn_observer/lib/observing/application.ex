defmodule Observing.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Starts a worker by calling: Observing.Observing.Worker.start_link(arg)
      Supervisor.child_spec(Observing.Worker, id: Anonymous),
      Supervisor.child_spec({Observing.Worker, [name: Registered]}, id: Observing.Registered),
      {Observing.ParentWorker, [name: Parent]},
      Observing.ChildSup
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Observing.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
