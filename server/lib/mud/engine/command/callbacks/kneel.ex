defmodule Mud.Engine.Command.Kneel do
  @moduledoc """
  The KNEEL command moves the character into a kneeling position.

  If no target is provided, the Character will kneel in place.

  Syntax:
    - kneel < on | in > target

  Examples:
    - kneel
    - kneel chair
    - kneel on chair
  """
  use Mud.Engine.Command.Callback

  alias Mud.Engine.Command.Context
  alias Mud.Engine.{Character}
  alias Mud.Engine.Event.Client.UpdateArea
  alias Mud.Engine.Event.Client.UpdateCharacter
  alias Mud.Engine.Message

  require Logger

  def build_ast(_ast_nodes) do
    :ok
  end

  @impl true
  def execute(%Context{} = context) do
    if context.character.status.position == "kneeling" do
      Context.append_message(
        context,
        Message.new_story_output(
          context.character.id,
          "You are already kneeling.",
          "system_info"
        )
      )
    else
      updated_status =
        Mud.Engine.Character.Status.update!(context.character.status, %{position: "kneeling"})

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
        |> Message.append_text(" kneels down.", "base")

      self_msg =
        context.character.id
        |> Message.new_story_output()
        |> Message.append_text("You", "character")
        |> Message.append_text(" kneel down.", "base")

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
