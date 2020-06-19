defmodule Mud.Engine.Command.Stand do
  @moduledoc """
  The STAND command moves the character into a standing position from any other position.

  Syntax:
    - stand

  Examples:
    - stand
  """
  use Mud.Engine.Command.Callback

  alias Mud.Engine.Message
  alias Mud.Engine.Command.ExecutionContext
  alias Mud.Engine.{Character, Item}

  require Logger

  @impl true
  def execute(%ExecutionContext{} = context) do
    if context.character.position != Character.standing() do
      update = %{
        position: Character.standing(),
        relative_position: "",
        relative_item_id: nil
      }

      Character.update(context.character, update)

      desc = from_description(context.character)

      others =
        Character.list_others_active_in_areas(context.character.id, context.character.area_id)

      context
      |> ExecutionContext.append_message(
        Message.new_output(
          others,
          "#{context.character.name} rises to their feet" <> desc <> ".",
          "info"
        )
      )
      |> ExecutionContext.append_message(
        Message.new_output(
          context.character.id,
          "You rise to your feet" <> desc <> ".",
          "info"
        )
      )
      |> ExecutionContext.set_success()
    else
      error_msg = "You are already standing!"

      context
      |> ExecutionContext.append_message(
        Message.new_output(context.character.id, error_msg, "error")
      )
      |> ExecutionContext.set_success()
    end
  end

  defp from_description(character) do
    if character.relative_item_id != nil do
      desc =
        Item.get!(character.relative_item_id)
        |> Item.short_description(character)

      " from #{desc}"
    else
      ""
    end
  end
end
