defmodule PP do
  @moduledoc """
  Pretty printer

  Import this module in your code to use `pp`.
  """

  @doc """
  Pretty prints the expression with optional ANSI formatting

  ## Examples

      iex> x = 1

      iex> pp(x + 2, [:red, :bright])
      x + 2 # => 3
  """
  defmacro pp(expr, ansi_format \\ :reset) do
    quote bind_quoted: [expr: expr, ansi_format: ansi_format, expr_s: Macro.to_string(expr)] do
      [ansi_format, "#{expr_s} # => #{inspect expr}"]
      |> IO.ANSI.format()
      |> IO.puts()
    end
  end
end
