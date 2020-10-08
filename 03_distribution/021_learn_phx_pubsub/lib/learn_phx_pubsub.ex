defmodule LearnPhxPubsub do
  use Application
  alias Phoenix.PubSub

  def start(_type, _args) do
    children = [
      {PubSub, name: :ps},
      {MyTracker, [name: :tr, pubsub_server: :ps]}
    ]

    Supervisor.start_link(children, strategy: :rest_for_one)
  end
end
