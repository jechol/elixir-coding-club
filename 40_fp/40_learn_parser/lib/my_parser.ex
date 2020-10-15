# Generated from lib/my_parser.ex.exs, do not edit.
# Generated at 2020-10-04 21:52:12Z.

# lib/my_parser.ex.exs
defmodule MyParser do
  @moduledoc false

  @doc """
  Parses the given `binary` as datetime.

  Returns `{:ok, [token], rest, context, position, byte_offset}` or
  `{:error, reason, rest, context, line, byte_offset}` where `position`
  describes the location of the datetime (start position) as `{line, column_on_line}`.

  ## Options

    * `:byte_offset` - the byte offset for the whole binary, defaults to 0
    * `:line` - the line and the byte offset into that line, defaults to `{1, byte_offset}`
    * `:context` - the initial context value. It will be converted to a map

  """
  @spec datetime(binary, keyword) ::
          {:ok, [term], rest, context, line, byte_offset}
          | {:error, reason, rest, context, line, byte_offset}
        when line: {pos_integer, byte_offset},
             byte_offset: pos_integer,
             rest: binary,
             reason: String.t(),
             context: map()
  def datetime(binary, opts \\ []) when is_binary(binary) do
    context = Map.new(Keyword.get(opts, :context, []))
    byte_offset = Keyword.get(opts, :byte_offset, 0)

    line =
      case(Keyword.get(opts, :line, 1)) do
        {_, _} = line ->
          line

        line ->
          {line, byte_offset}
      end

    case(datetime__0(binary, [], [], context, line, byte_offset)) do
      {:ok, acc, rest, context, line, offset} ->
        {:ok, :lists.reverse(acc), rest, context, line, offset}

      {:error, _, _, _, _, _} = error ->
        error
    end
  end

  defp datetime__0(
         <<x0::integer, x1::integer, x2::integer, x3::integer, "-", x4::integer, x5::integer, "-",
           x6::integer, x7::integer, "T", x8::integer, x9::integer, ":", x10::integer,
           x11::integer, ":", x12::integer, x13::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 >= 48 and x0 <= 57 and (x1 >= 48 and x1 <= 57) and (x2 >= 48 and x2 <= 57) and
              (x3 >= 48 and x3 <= 57) and (x4 >= 48 and x4 <= 57) and (x5 >= 48 and x5 <= 57) and
              (x6 >= 48 and x6 <= 57) and (x7 >= 48 and x7 <= 57) and (x8 >= 48 and x8 <= 57) and
              (x9 >= 48 and x9 <= 57) and (x10 >= 48 and x10 <= 57) and (x11 >= 48 and x11 <= 57) and
              (x12 >= 48 and x12 <= 57) and (x13 >= 48 and x13 <= 57) do
    datetime__1(
      rest,
      [
        x13 - 48 + (x12 - 48) * 10,
        x11 - 48 + (x10 - 48) * 10,
        x9 - 48 + (x8 - 48) * 10,
        x7 - 48 + (x6 - 48) * 10,
        x5 - 48 + (x4 - 48) * 10,
        x3 - 48 + (x2 - 48) * 10 + (x1 - 48) * 100 + (x0 - 48) * 1000
      ] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 19
    )
  end

  defp datetime__0(rest, _acc, _stack, context, line, offset) do
    {:error,
     "expected ASCII character in the range '0' to '9', followed by ASCII character in the range '0' to '9', followed by ASCII character in the range '0' to '9', followed by ASCII character in the range '0' to '9', followed by string \"-\", followed by ASCII character in the range '0' to '9', followed by ASCII character in the range '0' to '9', followed by string \"-\", followed by ASCII character in the range '0' to '9', followed by ASCII character in the range '0' to '9', followed by string \"T\", followed by ASCII character in the range '0' to '9', followed by ASCII character in the range '0' to '9', followed by string \":\", followed by ASCII character in the range '0' to '9', followed by ASCII character in the range '0' to '9', followed by string \":\", followed by ASCII character in the range '0' to '9', followed by ASCII character in the range '0' to '9'",
     rest, context, line, offset}
  end

  defp datetime__1(<<"Z", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    datetime__2(rest, ["Z"] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp datetime__1(<<rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    datetime__2(rest, [] ++ acc, stack, context, comb__line, comb__offset)
  end

  defp datetime__2(rest, acc, _stack, context, line, offset) do
    {:ok, acc, rest, context, line, offset}
  end
end
