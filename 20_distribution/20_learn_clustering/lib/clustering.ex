defmodule Clustering do
  use Application

  def start(_type, _args) do
    setup_clustering()

    Supervisor.start_link([], strategy: :one_for_one, name: __MODULE__)
  end

  def setup_clustering do
    # Turn node into a distributed node with the given name
    :net_kernel.start([:"master@127.0.0.1", :longnames])
    # Allow spawned nodes to fetch all code from this node
    :erl_boot_server.start([])
    :erl_boot_server.add_slave({127, 0, 0, 1})

    for i <- [0, 1] do
      :slave.start('127.0.0.1', :"slave#{i}", '-loader inet -hosts 127.0.0.1')
      :rpc.block_call()
    end
  end

  @moduledoc """
  Documentation for `Clustering`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Clustering.hello()
      :world

  """
  def hello do
    :world
  end
end
