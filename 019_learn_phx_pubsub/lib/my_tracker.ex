defmodule MyTracker do
  alias Phoenix.Tracker
  alias Phoenix.PubSub
  use Tracker

  def start_link(opts) do
    opts = Keyword.merge([name: __MODULE__], opts)
    Phoenix.Tracker.start_link(__MODULE__, opts, opts)
  end

  @impl true
  def init(opts) do
    server = Keyword.fetch!(opts, :pubsub_server)
    {:ok, %{pubsub_server: server}}
  end

  @impl true
  def handle_diff(diff, state = %{pubsub_server: pubsub_server}) do
    diff
    |> Enum.each(fn {topic, {joins, leaves}} ->
      joins
      |> Enum.each(fn {key, meta} ->
        IO.puts(~s(presence join: #{topic} "#{key}" with meta #{inspect(meta)}))
        msg = {:join, key, meta}
        PubSub.broadcast!(pubsub_server, topic, msg)
      end)

      leaves
      |> Enum.each(fn {key, meta} ->
        IO.puts(~s(presence leave: #{topic} "#{key}" with meta #{inspect(meta)}))
        msg = {:leave, key, meta}
        PubSub.broadcast!(pubsub_server, topic, msg)
      end)
    end)

    {:ok, state}
  end
end
