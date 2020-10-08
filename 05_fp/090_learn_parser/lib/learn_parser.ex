defmodule LearnParser do
  import NimbleParsec

  defparsec :digit_and_lowercase,
            empty()
            |> ascii_char([?0..?9])
            |> ascii_char([?a..?z])
            |> label("digit followed by lowercase letter")
end
