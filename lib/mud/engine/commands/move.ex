defmodule Mud.Engine.Command.Move do
  use Mud.Engine.CommandCallback

  @impl true
  def execute(%Mud.Engine.CommandContext{} = context) do
    IO.inspect(context)

    context =
      if context.parsed_args == "" do
        %{
          context
          | command: %{context.command | command: normalize_direction(context.command.command)}
        }
      else
        %{context | command: normalize_direction(context.parsed_args)}
      end

    case Mud.Engine.find_obvious_exit_in_character_location(
           context.character_id,
           context.command.command
         ) do
      nil ->
        append_message(
          context,
          %Mud.Engine.Output{
            id: context.id,
            character_id: context.character_id,
            text: "{{error}}You cannot travel in that direction.{{/error}}"
          }
        )

      link ->
        # Move the character in the database
        {:ok, character} =
          context.character_id
          |> Mud.Engine.get_character!()
          |> Mud.Engine.update_character(%{location_id: link.to_id})

        # Perform look logic for character
        context_with_look_command =
          append_message(
            context,
            %Mud.Engine.Input{
              id: UUID.uuid4(),
              character_id: context.character_id,
              text: "look",
              type: :silent
            }
          )

        # List all the characters that need to be informed of a move
        characters_by_location =
          Mud.Engine.list_active_characters_in_areas([link.to_id, link.from_id])
          # Filter out "self"
          |> Enum.filter(fn char ->
            char.id != character.id
          end)
          # Group by location
          |> Enum.group_by(fn char ->
            char.location_id
          end)

        # Send messages to everyone in room that the character just left
        context_with_some_messages =
          Enum.reduce(
            characters_by_location[link.from_id] || [],
            context_with_look_command,
            fn char, ctx ->
              append_message(
                ctx,
                %Mud.Engine.Output{
                  id: UUID.uuid4(),
                  character_id: char.id,
                  text:
                    "{{info}}#{character.name} left the area heading #{link.departure_direction}.{{/info}}"
                }
              )
            end
          )

        # Send messages to everyone in room that the character is arriving in
        context_with_all_messages =
          Enum.reduce(
            characters_by_location[link.to_id] || [],
            context_with_some_messages,
            fn char, ctx ->
              append_message(
                ctx,
                %Mud.Engine.Output{
                  id: UUID.uuid4(),
                  character_id: char.id,
                  text:
                    "{{info}}#{character.name} has entered the area from the #{
                      link.arrival_direction
                    }.{{info}}"
                }
              )
            end
          )

        set_success(context_with_all_messages, true)
    end
  end

  defp normalize_direction(direction) do
    case direction do
      "nw" ->
        "northwest"

      "ne" ->
        "northeast"

      "n" ->
        "north"

      "e" ->
        "east"

      "w" ->
        "west"

      "s" ->
        "south"

      "sw" ->
        "southwest"

      "se" ->
        "southeast"

      "o" ->
        "out"

      "ou" ->
        "out"

      "i" ->
        "in"

      "u" ->
        "up"

      "d" ->
        "down"

      "do" ->
        "down"

      "dow" ->
        "down"

      _ ->
        direction
    end
  end
end
