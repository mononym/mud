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
  alias Mud.Engine.Model.{Character, Item}

  require Logger

  import Mud.Engine.Util

  @impl true
  def execute(%ExecutionContext{} = context) do
    segments = context.command.segments

    if segments[:target] != nil do
      which_target = min(0, segments[:number][:input] || [0]) |> List.first()

      sit_on_target(
        context,
        segments[:target][:input],
        context.character.area_id,
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

  def sit_on_target(context, input, area_id, which_target) do
    furniture = Item.list_furniture_in_area(area_id)

    exact_input = Enum.join(input, " ")

    exact_matches =
      Enum.filter(furniture, fn thing ->
        description = describe_thing(thing, context.character)
        exact_input == description
      end)

    case length(exact_matches) do
      0 ->
        sit_on_target_using_partial_description(context, input, furniture, which_target)

      1 ->
        make_character_sit(context, List.first(exact_matches))

      _more ->
        handle_multiple_matches(context, exact_matches)
    end
  end

  defp handle_multiple_matches(context, exact_matches) when length(exact_matches) < 10 do
    descriptions =
      Enum.map(exact_matches, fn match -> describe_thing(match, context.character) end)

    error_msg = "{{warning}}Please choose where to sit.{{/warning}}"

    multiple_match_error(context, descriptions, exact_matches, error_msg, __MODULE__)
  end

  defp handle_multiple_matches(context, _exact_matches) do
    error_msg = "Found too many matches. Please be more specific."

    ExecutionContext.success_with_output(context, error_msg, "error")
  end

  defp describe_thing(item = %Item{}, looking_character = %Character{}) do
    Item.describe_glance(item, looking_character)
  end

  @spec make_character_sit(context :: ExecutionContext.t(), furniture_object :: Object.t()) ::
          {:ok, ExecutionContext.t()} | {:error, :nomatch}
  defp make_character_sit(context, furniture_object) do
    if furniture_object.furniture.is_furniture do
      update = %{
        position: "sitting",
        relative_position: "on",
        relative_object: furniture_object.id
      }

      Character.update(context.character, update)

      context =
        context
        |> append_message(
          output(
            context.character_id,
            "{{info}}You sit down on the #{furniture_object.description.look_description}{{/info}}"
          )
        )
        |> set_success()

      {:ok, context}
    else
      context =
        context
        |> append_message(
          output(
            context.character_id,
            "{{warning}}Unfortunately, #{furniture_object.description.glance_description} can not be sat on.{{/warning}}"
          )
        )
        |> set_success()

      {:ok, context}
    end
  end

  defp sit_on_target_using_partial_description(context, input, furniture, which_target) do
    regex = input_to_fuzzy_regex(input)

    partial_matches =
      Enum.filter(furniture, fn thing ->
        description = describe_thing(thing, context.character)
        Regex.match?(regex, description)
      end)

    num_matches = length(partial_matches)

    cond do
      num_matches == 0 or which_target > num_matches ->
        error_msg = "{{warning}}Could not find anything to sit on.{{/warning}}"

        ExecutionContext.success_with_output(context, error_msg, "error")

      num_matches == 1 ->
        description = describe_thing(List.first(partial_matches), context.character)

        ExecutionContext.success_with_output(context, description, "info")

      which_target > 0 and which_target <= num_matches ->
        thing = Enum.at(furniture, which_target - 1)
        description = describe_thing(thing, context.character)

        ExecutionContext.success_with_output(context, description, "info")

      true ->
        handle_multiple_matches(context, partial_matches)
    end
  end
end
