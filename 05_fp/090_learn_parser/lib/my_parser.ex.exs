# lib/my_parser.ex.exs
defmodule MyParser do
  @moduledoc false

  # parsec:MyParser
  import NimbleParsec

  date =
    integer(4)
    |> ignore(string("-"))
    |> integer(2)
    |> ignore(string("-"))
    |> integer(2)

  time =
    integer(2)
    |> ignore(string(":"))
    |> integer(2)
    |> ignore(string(":"))
    |> integer(2)
    |> optional(string("Z"))

  defparsec :datetime, date |> ignore(string("T")) |> concat(time)

  # parsec:MyParser
end
