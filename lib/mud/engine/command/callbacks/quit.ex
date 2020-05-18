defmodule Mud.Engine.Command.Quit do
  use Mud.Engine.Command.Callback

  def execute(context) do
    context
    |> do_ingame_stuff()
    |> terminate_session()
  end

  def do_ingame_stuff(context) do
    {:ok, character} =
      context.character_id
      |> Mud.Engine.Model.Character.get_by_id!()
      |> Mud.Engine.Model.Character.update(%{active: false})

    characters =
      Mud.Engine.Model.Character.list_others_active_in_areas(character, character.area_id)

    context
    |> Mud.Engine.Command.ExecutionContext.add_output(
      character.id,
      "Thank you for playing! Come back soon!",
      "warning"
    )
    |> Mud.Engine.Command.ExecutionContext.success_with_output(
      characters,
      "#{character.name} just left.",
      "info"
    )
  end
end
