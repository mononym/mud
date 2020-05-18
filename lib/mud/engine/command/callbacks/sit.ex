defmodule Mud.Engine.Command.Sit do
  @moduledoc """
  The SIT command moves the character into a sitting position.

  If no target is provided, the Character will sit in place.

  Syntax:
    - sit < on | in > target

  Examples:
    - sit
    - sit chair
    - sit on chair
  """
  use Mud.Engine.Command.Callback

  alias Mud.Engine.Command.ExecutionContext
  alias Mud.Engine.Model.{Character}
  alias Mud.Engine.Search

  require Logger

  import Mud.Engine.Util

  @impl true
  def continue(%ExecutionContext{} = context) do
    make_character_sit(context, context.input.match)
  end

  @impl true
  def execute(%ExecutionContext{} = context) do
    segments = context.command.segments

    if segments[:target] != nil do
      which_target = min(0, segments[:number][:input] || 0)

      sit_on_target(
        context,
        segments[:target][:input],
        which_target
      )
    else
      help_docs = Mud.Engine.Util.get_module_docs(__MODULE__)

      context
      |> append_message(
        output(
          context.character_id,
          "{{help_docs}}#{help_docs}{{/help_docs}}"
        )
      )
      |> set_success()
    end
  end

  def sit_on_target(context, input, which_target) do
    matches = Search.find_matches_in_area(context.character.area_id, input, context.character)

    num_exact_matches = length(matches.exact_matches)
    num_partial_matches = length(matches.partial_matches)

    # NOTE: The 'duplicate' logic here is intentional. DO NOT REFACTOR UNLESS YOU ARE SURE OF WHAT YOU ARE DOING!
    #
    # Desired behaviour is that if there are exact matches, they should be handled as if there were no partial matches.
    cond do
      # happy path with a single match with no index chosen
      num_exact_matches == 1 and which_target == 0 ->
        match = List.first(matches.exact_matches)

        make_character_sit(context, match.match)

      # ExecutionContext.success_with_output(context, match.look_description, "info")

      # happy path where there are matches, and chosen index is in range
      num_exact_matches > 1 and which_target > 0 and which_target <= num_exact_matches ->
        match = Enum.at(matches.exact_matches, which_target - 1)

        make_character_sit(context, match.match)

      # ExecutionContext.success_with_output(context, match.look_description, "info")

      # unhappy path where there are multiple matches
      num_exact_matches > 1 and which_target == 0 ->
        handle_multiple_matches(context, matches.exact_matches)

      # happy path with a single match with no index chosen
      num_partial_matches == 1 and which_target == 0 ->
        match = List.first(matches.partial_matches)

        make_character_sit(context, match.match)

      # ExecutionContext.success_with_output(context, match.look_description, "info")

      # happy path where there are matches, and chosen index is in range
      num_partial_matches > 1 and which_target > 0 and which_target <= num_partial_matches ->
        match = Enum.at(matches.partial_matches, which_target - 1)

        make_character_sit(context, match.match)

      # ExecutionContext.success_with_output(context, match.look_description, "info")

      # unhappy path where there are multiple matches
      num_partial_matches > 1 and which_target == 0 ->
        handle_multiple_matches(context, matches.partial_matches)

      # unhappy path where there are no matches at all
      true ->
        error_msg = "{{warning}}You want to sit on what?{{/warning}}"

        ExecutionContext.success_with_output(context, error_msg, "error")
    end
  end

  defp handle_multiple_matches(context, matches) when length(matches) < 10 do
    descriptions = Enum.map(matches, fn match -> match.glance_description end)

    error_msg = "{{warning}}Please choose where to sit.{{/warning}}"

    multiple_match_error(context, descriptions, matches, error_msg, __MODULE__)
  end

  defp handle_multiple_matches(context, _matches) do
    error_msg = "Found too many matches. Please be more specific."

    ExecutionContext.success_with_output(context, error_msg, "error")
  end

  @spec make_character_sit(context :: ExecutionContext.t(), furniture_object :: Object.t()) ::
          ExecutionContext.t()
  defp make_character_sit(context, furniture_object) do
    char = context.character

    cond do
      furniture_object.is_furniture and char.position != "sitting" ->
        update = %{
          position: "sitting",
          relative_position: "on",
          relative_object: furniture_object.id
        }

        Character.update(context.character, update)

        context
        |> append_message(
          output(
            context.character_id,
            "{{info}}You sit down on #{furniture_object.glance_description}{{/info}}"
          )
        )
        |> set_success()

      char.position == "sitting" ->
        context
        |> append_message(
          output(
            context.character_id,
            "{{error}}You are already sitting down!{{/error}}"
          )
        )
        |> set_success()

      true ->
        context
        |> append_message(
          output(
            context.character_id,
            "{{warning}}Unfortunately, #{furniture_object.glance_description} can not be sat on.{{/warning}}"
          )
        )
        |> set_success()
    end
  end
end
