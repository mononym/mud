defmodule Mud.Engine.Command.Move do
  use Mud.Engine.CommandCallback

  @impl true
  def execute(context) do
    context =
      if context.args == "" do
        %{context | matched_verb: normalize_direction(String.trim(context.matched_verb))}
      else
        %{context | matched_verb: normalize_direction(String.trim(context.args))}
      end

    case Mud.Engine.find_obvious_exit_in_character_location(
           context.character_id,
           context.matched_verb
         ) do
      nil ->
        append_message(
          context,
          Mud.Engine.Message.new(
            context.player_id,
            context.character_id,
            "You cannot travel in that direction.",
            :output
          )
        )

      link ->
        # Move the character in the database
        {:ok, character} =
          context.character_id
          |> Mud.Engine.get_character!()
          |> Mud.Engine.update_character(%{location_id: link.to_id})

        characters_by_location =
          Mud.Engine.list_characters_in_areas([link.to_id, link.from_id])
          # Filter out "self"
          |> Enum.filter(fn char ->
            char.id != character.id
          end)
          # Group by location
          |> Enum.group_by(fn char ->
            char.location_id
          end)

        # Perform look logic for character
        context_with_look_command =
          append_message(
            context,
            Mud.Engine.Message.new(
              character.player_id,
              character.id,
              "look",
              :input
            )
          )

        # Send messages to everyone in room that the character just left
        context_with_some_messages =
          Enum.reduce(
            characters_by_location[link.from_id] || [],
            context_with_look_command,
            fn char, ctx ->
              append_message(
                ctx,
                Mud.Engine.Message.new(
                  char.id,
                  "#{character.name} left the area heading #{link.departure_direction}.",
                  :output
                )
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
                Mud.Engine.Message.new(
                  char.id,
                  "#{character.name} has entered the area from the #{link.arrival_direction}.",
                  :output
                )
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
