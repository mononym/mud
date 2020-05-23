defmodule Mud.Engine.Command.Look do
  @moduledoc """
  Allows a Character to 'see' the world around them.

  Current algorithm allows for looking at items and characters, and into the next area.
  """
  use Mud.Engine.Command.Callback

  alias Mud.Engine.Model.Area
  alias Mud.Engine.Command.ExecutionContext
  alias Mud.Engine.Search
  alias Mud.Engine.Util
  alias Mud.Engine.Message

  require Logger

  defmodule ContinuationData do
    @enforce_keys [:data, :type]
    defstruct type: nil,
              data: nil
  end

  @impl true
  def continue(context) do
    description = context.input.look_description

    context
    |> ExecutionContext.append_message(
      Message.new_output(
        context.character_id,
        "{{info}}#{description}{{/info}}"
      )
    )
    |> ExecutionContext.set_success()
  end

  @impl true
  def execute(context) do
    ast = context.command.ast

    if ast[:target] != nil do
      which_target =
        if ast[:number] != nil do
          min(1, List.first(ast[:number][:input]))
        else
          0
        end

      look_at_target(context, ast[:target][:input], which_target)
    else
      description = Area.describe_look(context.character.area_id, context.character)

      context
      |> ExecutionContext.append_message(Message.new_output(context.character_id, description))
      |> ExecutionContext.set_success()
    end
  end

  @spec look_at_target(ExecutionContext.t(), String.t(), integer) :: ExecutionContext.t()
  defp look_at_target(context, input, which_target) do
    matches =
      Search.find_matches_in_area(
        [:item, :character, :link],
        context.character.area_id,
        input,
        context.character
      )

    num_exact_matches = length(matches.exact_matches)
    num_partial_matches = length(matches.partial_matches)

    # NOTE: The 'duplicate' logic here is intentional. DO NOT REFACTOR UNLESS YOU ARE SURE OF WHAT YOU ARE DOING!
    #
    # Desired behaviour is that if there are exact matches, they should be handled as if there were no partial matches.
    cond do
      # happy path with a single match with no index chosen
      num_exact_matches == 1 and which_target == 0 ->
        match = List.first(matches.exact_matches)

        ExecutionContext.append_message(
          context,
          Message.new_output(
            context.character.id,
            match.look_description,
            "info"
          )
        )
        |> ExecutionContext.set_success()

      # happy path where there are matches, and chosen index is in range
      num_exact_matches > 1 and which_target > 0 and which_target <= num_exact_matches ->
        match = Enum.at(matches.exact_matches, which_target - 1)

        ExecutionContext.append_message(
          context,
          Message.new_output(
            context.character.id,
            match.look_description,
            "info"
          )
        )
        |> ExecutionContext.set_success()

      # unhappy path where there are multiple matches
      num_exact_matches > 1 and which_target == 0 ->
        handle_multiple_matches(context, matches.exact_matches)

      # happy path with a single match with no index chosen
      num_partial_matches == 1 and which_target == 0 ->
        match = List.first(matches.partial_matches)

        ExecutionContext.append_message(
          context,
          Message.new_output(
            context.character.id,
            match.look_description,
            "info"
          )
        )
        |> ExecutionContext.set_success()

      # happy path where there are matches, and chosen index is in range
      num_partial_matches > 1 and which_target > 0 and which_target <= num_partial_matches ->
        match = Enum.at(matches.partial_matches, which_target - 1)

        ExecutionContext.append_message(
          context,
          Message.new_output(
            context.character.id,
            match.look_description,
            "info"
          )
        )
        |> ExecutionContext.set_success()

      # unhappy path where there are multiple matches
      num_partial_matches > 1 and which_target == 0 ->
        handle_multiple_matches(context, matches.partial_matches)

      # unhappy path where there are multiple matches or no matches at all
      true ->
        error_msg = "Could not find what you were looking for."

        ExecutionContext.append_message(
          context,
          Message.new_output(context.character.id, error_msg, "error")
        )
        |> ExecutionContext.set_success()
    end
  end

  defp handle_multiple_matches(context, matches) when length(matches) < 10 do
    descriptions = Enum.map(matches, & &1.glance_description)

    error_msg =
      "Multiple matches were found. Please enter the number associated with the thing you wish to `look` at."

    Util.multiple_match_error(context, descriptions, matches, error_msg, __MODULE__)
  end

  defp handle_multiple_matches(context, _matches) do
    error_msg = "Found too many matches. Please be more specific."

    ExecutionContext.append_message(
      context,
      Message.new_output(context.character.id, error_msg, "error")
    )
    |> ExecutionContext.set_success()
  end
end