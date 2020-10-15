defmodule Clustering do
  use Application

  def start(_type, _args) do
    setup_siblings()

    Supervisor.start_link([], strategy: :one_for_one, name: __MODULE__)
  end

  def setup_siblings do
    # Turn node into a distributed node with the given name
    :net_kernel.start([:"self@127.0.0.1"])
    # Allow spawned nodes to fetch all code from this node
    :erl_boot_server.start([])
    :erl_boot_server.add_slave({127, 0, 0, 1})

    for i <- [0, 1] do
      {:ok, node} = :slave.start('127.0.0.1', :"sibling#{i}", '-loader inet -hosts 127.0.0.1')
      :rpc.block_call(node, :code, :add_paths, [:code.get_path()])

      # Transfer config
      for {app, _desc, _ver} <- Application.loaded_applications() do
        for {key, val} <- Application.get_all_env(app) do
          :rpc.block_call(node, Application, :put_env, [app, key, val])
        end
      end

      :rpc.block_call(node, Application, :ensure_all_started, [:mix])
      :rpc.block_call(node, Mix, :env, [Mix.env()])

      # Start all apps
      for {app, _desc, _ver} <- Application.started_applications() do
        :rpc.block_call(node, Application, :ensure_all_started, [app])
      end
    end
  end
end
