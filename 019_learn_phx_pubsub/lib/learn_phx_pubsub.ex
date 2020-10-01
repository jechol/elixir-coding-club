defmodule LearnPhxPubsub do
  use Application
  alias Phoenix.PubSub

  def start(_type, _args) do
    children = [
      {PubSub, name: :learn_phx_pubsub}
    ]

    Supervisor.start_link(children, strategy: :rest_for_one)
  end

  @moduledoc """
  Documentation for `LearnPhxPubsub`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> LearnPhxPubsub.hello()
      :world

  """
  def hello do
    :world
  end
end
