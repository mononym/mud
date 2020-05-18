defmodule Mud.Engine.Util do
  @moduledoc """
  Helper functions.
  """

  import Mud.Engine.Command.ExecutionContext

  def output(who, text, table_data \\ nil) do
    %Mud.Engine.Output{
      id: UUID.uuid4(),
      character_id: who,
      text: text,
      table_data: table_data
    }
  end

  def clear_continuation_from_context(context) do
    context
    |> clear_continuation_data()
    |> clear_continuation_module()
    |> set_is_continuation(false)
  end

  @spec multiple_match_error(
          command_context :: CommandContext.t(),
          keys :: [String.t()],
          values :: [any()],
          error_message :: String.t(),
          continuation_module :: module()
        ) :: CommandContext.t()
  def multiple_match_error(context, keys, values, error_message, continuation_module) do
    indexed_values = list_to_index_map(values)

    context
    |> append_message(
      output(
        context.character_id,
        error_message,
        keys
      )
    )
    |> set_is_continuation(true)
    |> set_continuation_data(indexed_values)
    |> set_continuation_module(continuation_module)
    |> set_continuation_type(:numeric)
    |> set_success()
  end

  @doc """
  Retrieve the module docs for a module.

  Default is English. Primarily created for Commands and using moduledocs as in game command documentation.
  """
  @spec get_module_docs(module | String.t(), String.t()) :: String.t()
  def get_module_docs(module, language \\ "en") do
    module
    |> Code.fetch_docs()
    |> elem(4)
    |> Map.get(language)
  end

  def list_to_index_map(list, offset \\ 1) do
    list
    |> Stream.with_index(offset)
    |> Enum.reduce(%{}, fn {thing, index}, map ->
      Map.put(map, index, thing)
    end)
  end

  @doc """
  Takes in a list of strings and turns it into a compiled regex expression.

  The expression searches for words that contain the given space separated values.
  For example, given the input "a b c" the produced regex would match the following strings: "ba ab bc", "a ba cb"
  But not: "ab ca bc", "ab ca b c"
  """
  @spec input_to_fuzzy_regex(String.t()) :: Regex.t()
  def input_to_fuzzy_regex(input) do
    optional_group = ".*?"
    middle_group = optional_group <> "\\s+"

    replaced_input = String.replace(input, ~r/\s+/, middle_group)

    Regex.compile!("^" <> replaced_input <> optional_group)
  end
end
