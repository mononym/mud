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
  alias Mud.Engine.Util
  alias Mud.Engine.Command.Context
  alias Mud.Engine.{Character}
  alias Mud.Engine.Event.Client.{UpdateArea, UpdateCharacter}

  require Logger

  def build_ast(_ast_nodes) do
    :ok
  end

  @impl true
  def execute(%Context{} = context) do
    if context.character.status.position == "standing" do
      Context.append_message(
        context,
        Message.new_story_output(
          context.character.id,
          "You are already standing.",
          "system_info"
        )
      )
    else
      updated_status =
        Mud.Engine.Character.Status.update!(context.character.status, %{position: "standing"})

      character = Map.put(context.character, :status, updated_status)

      others =
        Character.list_others_active_in_areas(
          context.character.id,
          context.character.area_id
        )

      other_msg =
        others
        |> Message.new_story_output()
        |> Message.append_text("[#{context.character.name}]", "character")
        |> Message.append_text(" rises to #{Util.his_her_their(character)} feet.", "base")

      self_msg =
        context.character.id
        |> Message.new_story_output()
        |> Message.append_text("You", "character")
        |> Message.append_text(" rise to your feet.", "base")

      context
      |> Context.append_event(
        character.id,
        UpdateCharacter.new(%{action: "status", status: updated_status})
      )
      |> Context.append_event(
        [context.character_id | others],
        UpdateArea.new(%{action: :update, other_characters: [character]})
      )
      |> Context.append_message(other_msg)
      |> Context.append_message(self_msg)
    end
  end
end
