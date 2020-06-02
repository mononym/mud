defmodule Mud.Engine.Command.Kick do
  @moduledoc """
  The KICK command has the Character kick something.

  If no target is provided, the Character will kick the ground.

  Syntax:
    - kick <target>

  Examples:
    - kick
    - kick chair
    - kick George
  """

  alias Mud.Engine.Util
  alias Mud.Engine.Command.ExecutionContext
  alias Mud.Engine.Command.SingleTargetCallback
  alias Mud.Engine.{Character, Item}

  require Logger

  @behaviour Mud.Engine.Command.Callback

  defp target_types(), do: [:character, :item]

  @impl true
  def continue(context) do
    match = Util.refresh_thing(context.input.match)
    do_thing_to_match(context, match)
  end

  @impl true
  def execute(context) do
    case SingleTargetCallback.find_match(
           0,
           context.command.ast[:target],
           context.character,
           target_types()
         ) do
      {:ok, match} ->
        do_thing_to_match(context, match.match)

      {:error, {:multiple_matches, matches}} ->
        SingleTargetCallback.handle_multiple_matches(
          context,
          matches,
          "Pick the lucky recipient:",
          "That would require more feet. Please be more specific."
        )

      {:error, type} ->
        error_msg =
          case type do
            :no_match ->
              "Could not find anything to kick. Perhaps it's for the best."

            :out_of_range ->
              "It's...it's gone! It's just not there! Maybe try again?"
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

  @spec do_thing_to_match(ExecutionContext.t(), nil | Character.t() | Item.t()) ::
          ExecutionContext.t()
  defp do_thing_to_match(context, match) do
    char = context.character

    if char.position != Character.standing() do
      ExecutionContext.append_output(
        context,
        context.character.id,
        "You must be standing to do that.",
        "error"
      )
      |> ExecutionContext.set_success()
    else
      case match do
        character = %Character{} ->
          others =
            Character.list_others_active_in_areas(context.character, context.character.area_id)

          context
          |> ExecutionContext.append_output(
            others,
            "#{context.character.name} looks ready to kick #{character.name}!",
            "info"
          )
          |> ExecutionContext.append_output(
            context.character.id,
            "Violence is...sometimes the answer. But not this time.",
            "info"
          )
          |> ExecutionContext.set_success()

        _item = %Item{} ->
          others =
            Character.list_others_active_in_areas(context.character, context.character.area_id)

          context
          |> ExecutionContext.append_output(
            others,
            "#{context.character.name} looks ready to kick #{
              Item.describe_glance(match, context.character)
            }!",
            "info"
          )
          |> ExecutionContext.append_output(
            context.character.id,
            "What would kicking that solve?",
            "info"
          )
          |> ExecutionContext.set_success()
      end
    end
  end
end
