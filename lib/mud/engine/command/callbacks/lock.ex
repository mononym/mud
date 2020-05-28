defmodule Mud.Engine.Command.Lock do
  @moduledoc """
  The LOCK command allows the Character to lock something such as a door or a chest.

  Syntax:
    - lock <target>

  Examples:
    - lock backpack
    - lock door
  """

  alias Mud.Engine.Util
  alias Mud.Engine.Command.ExecutionContext
  alias Mud.Engine.Command.SingleTargetCallback
  alias Mud.Engine.Model.{Character, Item}

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
        "The #{context.input.glance_description} is no longer present.",
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
          "Which of these did you intend to lock?",
          "You can't possibly lock all of those at once. Please be more specific."
        )

      {:error, type} ->
        error_msg =
          case type do
            :no_match ->
              "Could not find anything to lock. Perhaps it's for the best."

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

    cond do
      item.container_lockable and not item.container_open and not item.container_locked ->
        Item.update!(item, %{container_locked: true})

        others =
          Character.list_others_active_in_areas(context.character, context.character.area_id)

        context
        |> ExecutionContext.append_output(
          others,
          "#{context.character.name} locked #{match.look_description}.",
          "info"
        )
        |> ExecutionContext.append_output(
          context.character.id,
          String.capitalize("#{match.glance_description} is now locked."),
          "info"
        )
        |> ExecutionContext.set_success()

      item.container_lockable and item.container_open ->
        ExecutionContext.append_output(
          context,
          context.character.id,
          String.capitalize("#{match.glance_description} can't be locked while open."),
          "error"
        )
        |> ExecutionContext.set_success()

      item.container_locked ->
        ExecutionContext.append_output(
          context,
          context.character.id,
          String.capitalize("#{match.glance_description} is already locked."),
          "error"
        )
        |> ExecutionContext.set_success()

      not item.container_lockable ->
        ExecutionContext.append_output(
          context,
          context.character.id,
          String.capitalize("#{match.glance_description} is not lockable."),
          "error"
        )
        |> ExecutionContext.set_success()
    end
  end
end
