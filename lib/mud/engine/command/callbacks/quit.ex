defmodule Mud.Engine.Command.Quit do
  use Mud.Engine.Command.Callback

  alias Mud.Engine.Command.ExecutionContext
  alias Mud.Engine.Message

  def build_ast(ast_nodes) do
    List.first(ast_nodes)
  end

  def execute(context) do
    context
    |> do_ingame_stuff()
    |> ExecutionContext.terminate_session()
  end

  def do_ingame_stuff(context) do
    {:ok, character} =
      context.character_id
      |> Mud.Engine.Character.get_by_id!()
      |> Mud.Engine.Character.update(%{active: false})

    characters = Mud.Engine.Character.list_others_active_in_areas(character.id, character.area_id)

    context
    |> ExecutionContext.append_message(
      Message.new_output(
        character.id,
        "Thank you for playing! Come back soon!",
        "warning"
      )
    )
    |> ExecutionContext.append_message(
      Message.new_output(
        characters,
        "#{character.name} just left.",
        "info"
      )
    )
  end
end
