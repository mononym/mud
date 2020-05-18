defmodule Mud.Engine.Command.Quit do
  use Mud.Engine.Command.Callback

  def execute(context) do
    do_ingame_stuff(context)

    terminate_session(context)
  end

  def do_ingame_stuff(context) do
    {:ok, character} =
      context.character_id
      |> Mud.Engine.Model.Character.get_by_id!()
      |> IO.inspect()
      |> Mud.Engine.Model.Character.update(%{active: false})

    characters = Mud.Engine.Model.Character.list_active_in_areas(character.area_id)

    Enum.each(characters, fn char ->
      Mud.Engine.Session.cast_message(%Mud.Engine.Output{
        character_id: char.id,
        text: "{{info}}#{character.name} just left.{{/info}}",
        id: UUID.uuid4()
      })
    end)
  end
end
