defmodule Mud.Engine.Command.Quit do
  use Mud.Engine.Command.Callback

  alias Mud.Engine.Command.Context
  alias Mud.Engine.Message

  def build_ast(ast_nodes) do
    List.first(ast_nodes)
  end

  def execute(context) do
    context
    |> do_ingame_stuff()
    |> Context.terminate_session()
  end

  @spec do_ingame_stuff(Mud.Engine.Command.Context.t()) :: none
  def do_ingame_stuff(context) do
    character = update_character(context.character.id)

    characters = Mud.Engine.Character.list_others_active_in_areas(character.id, character.area_id)

    context
    |> Context.append_message(
      Message.new_story_output(context.character_id)
      |> Message.append_text(
        "Thank you for playing! Come back soon!",
        "system_alert"
      )
    )
    |> Context.append_message(
      Message.new_story_output(characters)
      |> Message.append_text(
        "#{character.name} just left.",
        "info"
      )
    )
  end

  def update_character(character_id) do
    character_id
    |> Mud.Engine.Character.get_by_id!()
    |> Mud.Engine.Character.update!(%{active: false})
  end
end
