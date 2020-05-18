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
      make_character_sit(context)
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

      # happy path where there are matches, and chosen index is in range
      num_exact_matches > 1 and which_target > 0 and which_target <= num_exact_matches ->
        match = Enum.at(matches.exact_matches, which_target - 1)

        make_character_sit(context, match.match)

      # unhappy path where there are multiple matches
      num_exact_matches > 1 and which_target == 0 ->
        handle_multiple_matches(context, matches.exact_matches)

      # happy path with a single match with no index chosen
      num_partial_matches == 1 and which_target == 0 ->
        match = List.first(matches.partial_matches)

        make_character_sit(context, match.match)

      # happy path where there are matches, and chosen index is in range
      num_partial_matches > 1 and which_target > 0 and which_target <= num_partial_matches ->
        match = Enum.at(matches.partial_matches, which_target - 1)

        make_character_sit(context, match.match)

      # unhappy path where there are multiple matches
      num_partial_matches > 1 and which_target == 0 ->
        handle_multiple_matches(context, matches.partial_matches)

      # unhappy path where there are no matches at all
      true ->
        error_msg = "{{warning}}You want to sit on what?{{/warning}}"

        ExecutionContext.success_with_output(context, context.character.id, error_msg, "error")
    end
  end

  defp handle_multiple_matches(context, matches) when length(matches) < 10 do
    descriptions = Enum.map(matches, fn match -> match.glance_description end)

    error_msg = "{{warning}}Please choose where to sit.{{/warning}}"

    multiple_match_error(context, descriptions, matches, error_msg, __MODULE__)
  end

  defp handle_multiple_matches(context, _matches) do
    error_msg = "Found too many matches. Please be more specific."

    ExecutionContext.success_with_output(context, context.character.id, error_msg, "error")
  end

  @spec make_character_sit(context :: ExecutionContext.t(), furniture_object :: Object.t() | nil) ::
          ExecutionContext.t()
  defp make_character_sit(context, furniture_object \\ nil) do
    char = context.character

    cond do
      char.position == Character.sitting() ->
        ExecutionContext.success_with_output(
          context,
          context.character.id,
          "You are already sitting down!",
          "error"
        )

      furniture_object == nil ->
        update = %{
          position: Character.sitting(),
          relative_position: "",
          relative_item_id: nil
        }

        Character.update(context.character, update)

        others =
          Character.list_others_active_in_areas(context.character, context.character.area_id)

        context
        |> ExecutionContext.add_output(
          others,
          "#{context.character.name} sits down.",
          "info"
        )
        |> ExecutionContext.success_with_output(
          context.character.id,
          "You sit down.",
          "info"
        )

      furniture_object != nil and furniture_object.is_furniture and
          char.position != Character.sitting() ->
        update = %{
          position: Character.sitting(),
          relative_position: "on",
          relative_item_id: furniture_object.id
        }

        Character.update(context.character, update)

        others =
          Character.list_others_active_in_areas(context.character, context.character.area_id)

        context
        |> ExecutionContext.add_output(
          others,
          "#{context.character.name} sits down on #{furniture_object.glance_description}.",
          "info"
        )
        |> ExecutionContext.success_with_output(
          context.character.id,
          "You sit down on #{furniture_object.glance_description}.",
          "info"
        )

      true ->
        ExecutionContext.success_with_output(
          context,
          context.character.id,
          "Unfortunately, #{furniture_object.glance_description} can not be sat on.",
          "error"
        )
    end
  end
end
