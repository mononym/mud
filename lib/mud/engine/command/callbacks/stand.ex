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
  alias Mud.Engine.Event.Client.{UpdateArea, UpdateCharacter}

  require Logger

  def build_ast(ast_nodes) do
    ast_nodes
  end

  @impl true
  def execute(%ExecutionContext{} = context) do
    if context.character.position != Character.standing() do
      update = %{
        position: Character.standing(),
        relative_position: "",
        relative_item_id: nil
      }

      {:ok, char} = Character.update(context.character, update)

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
      |> ExecutionContext.append_event(
        others,
        UpdateArea.new(:update, char)
      )
      |> ExecutionContext.append_event(
        context.character.id,
        UpdateCharacter.new(:update, char)
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
      item = Item.get!(character.relative_item_id)

      " from #{item.short_description}"
    else
      ""
    end
  end
end
