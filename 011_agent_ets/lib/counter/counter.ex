defmodule Counter do
  @type counter :: reference() | pid()

  @callback start_link() :: {:ok, counter()}
  @callback value(counter(), any()) :: integer()
  @callback increment(counter(), any()) :: integer()
end
