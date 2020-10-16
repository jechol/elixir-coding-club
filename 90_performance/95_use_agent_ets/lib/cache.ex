defmodule Cache do
  @type cache :: reference() | pid()

  @callback start_link() :: {:ok, cache()}
  @callback get(cache(), any()) :: {:ok, any()} | :error
  @callback set(cache(), any(), any()) :: :ok
end
