defmodule Mud.Engine.Command.Quit do
  use Mud.Engine.CommandCallback

  def execute(context) do
    do_ingame_stuff(context)

    terminate_session(context)
  end

  def do_ingame_stuff(context) do
    {:ok, character} =
      context.character_id
      |> Mud.Engine.Character.get_by_id!()
      |> Mud.Engine.update_character(%{active: false})

    characters = Mud.Engine.Character.list_active_in_areas(character.area_id)

    Enum.each(characters, fn char ->
      Mud.Engine.cast_message_to_character_session(%Mud.Engine.Output{
        character_id: char.id,
        text: "{{info}}#{character.name} just left.{{/info}}",
        id: UUID.uuid4()
      })
    end)
  end
end
