defmodule Mud.Engine.Command.Wear do
  @moduledoc """
  The WEAR command allows the Character to put on things like rings, backpacks, armour, clothing, etc...

  Syntax:
    - wear <target>

  Examples:
    - wear backpack
  """

  alias Mud.Engine.Util
  alias Mud.Engine.Command.ExecutionContext
  alias Mud.Engine.Command.SingleTargetCallback
  alias Mud.Engine.{Character, Item}

  require Logger

  @behaviour Mud.Engine.Command.Callback

  defp target_types(), do: [:item]

  @impl true
  def continue(context) do
    target = Util.refresh_thing(context.input.match)

    if context.character.area_id == target.area_id do
      do_thing_to_match(context, %{context.input | match: target})
    else
      ExecutionContext.append_output(
        context,
        context.character.id,
        "The {{item}}#{context.input.glance_description}{{/item}} is no longer present.",
        "error"
      )
      |> ExecutionContext.set_success()
    end
  end

  @impl true
  def execute(context) do
    which_target = min(0, context.command.ast[:number][:input] || 0)

    result =
      SingleTargetCallback.find_match(
        which_target,
        context.command.ast[:target][:input],
        context.character,
        target_types()
      )

    case result do
      {:ok, match} ->
        do_thing_to_match(context, match)

      {:error, {:multiple_matches, matches}} ->
        SingleTargetCallback.handle_multiple_matches(
          context,
          matches,
          "Which of these did you intend to wear?",
          "You can't possibly wear all of those at once. Please be more specific."
        )

      {:error, type} ->
        error_msg =
          case type do
            :no_match ->
              "Could not find anything to wear. Perhaps it's for the best."

            :out_of_range ->
              "Nope! Nice try though. You need to choose one of the provided options."
          end

        ExecutionContext.append_output(
          context,
          context.character.id,
          error_msg,
          "error"
        )
        |> ExecutionContext.set_success()
    end
  end

  @spec do_thing_to_match(ExecutionContext.t(), Mud.Engine.Match.t()) :: ExecutionContext.t()
  defp do_thing_to_match(context, match) do
    item = match.match

    if item.is_wearable do
      Item.update!(item, %{wearable_worn_by_id: context.character.id})

      others = Character.list_others_active_in_areas(context.character, context.character.area_id)

      context
      |> ExecutionContext.append_output(
        others,
        "{{character}}#{context.character.name}{{/character}} puts {{item}}#{
          match.glance_description
        }{{/item}} on their {{bodypart}}#{item.wearable_location}{{/bodypart}}.",
        "info"
      )
      |> ExecutionContext.append_output(
        context.character.id,
        "{{item}}#{String.capitalize(match.glance_description)}{{/item}} is now on your {{bodypart}}#{
          item.wearable_location
        }{{/bodypart}}.",
        "info"
      )
      |> ExecutionContext.set_success()
    else
      ExecutionContext.append_output(
        context,
        context.character.id,
        String.capitalize("{{item}}#{match.glance_description}{{/item}} cannot be worn."),
        "error"
      )
      |> ExecutionContext.set_success()
    end
  end
end
