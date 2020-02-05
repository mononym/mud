defmodule Mud.Engine.Util do
  @moduledoc """
  Helper functions.
  """

  import Ecto.Changeset

  def replace_switches_with_prepositions(text, switch_mapping) do
    Enum.reduce(switch_mapping, text, fn {symbol, replacement}, string ->
      String.replace(string, symbol, " #{replacement} ")
    end)
  end
end
