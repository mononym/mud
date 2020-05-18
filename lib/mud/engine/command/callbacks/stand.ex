defmodule Mud.Engine.Command.Stand do
  @moduledoc """
  The STAND command moves the character into a standing position from any other position.

  Syntax:
    - stand

  Examples:
    - stand
  """
  use Mud.Engine.Command.Callback

  alias Mud.Engine.Command.ExecutionContext
  alias Mud.Engine.Model.{Character, Item}

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

      others = Character.list_others_active_in_areas(context.character, context.character.area_id)

      context
      |> ExecutionContext.add_output(
        others,
        "#{context.character.name} rises to their feet" <> desc <> ".",
        "info"
      )
      |> ExecutionContext.success_with_output(
        context.character.id,
        "You rise to your feet" <> desc <> ".",
        "info"
      )
    else
      error_msg = "You are already standing!"

      ExecutionContext.success_with_output(context, context.character.id, error_msg, "error")
    end
  end

  defp from_description(character) do
    if character.relative_item_id != nil do
      desc =
        Item.get!(character.relative_item_id)
        |> Item.describe_glance(character)

      " from #{desc}"
    else
      ""
    end
  end
end
