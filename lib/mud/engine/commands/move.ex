defmodule Mud.Engine.Command.Move do
  use Mud.Engine.CommandCallback

  require Logger

  import Mud.Engine.Util

  alias Mud.Engine.Link

  @impl true
  def parse_continuation_arg_string(raw_args) do
    case Integer.parse(raw_args) do
      {integer, _} ->
        {:ok, integer}

      :error ->
        {:error, :not_an_integer}
    end
  end

  @impl true
  def continue(context) do
    Logger.debug("Continuing to execute 'move' command")

    int = context.parsed_args
    data = context.continuation_data

    # Make sure exit selected an option from the list
    if int <= 9 and int >= 0 and int < map_size(data) do
      link = data[int]

      # Get for links
      case Mud.Engine.get_link(link.id) do
        # The link was found
        link = %Link{} ->
          do_move(context, link)

        # Object has been deleted
        nil ->
          context
          |> append_message(
            output(
              context.character_id,
              "{{error}}You are unable to use `#{link.text}` as an exit as it is no longer present.{{/error}}"
            )
          )
          |> clear_continuation_from_context()
          |> set_success(true)
      end
    else
      # The number Player selected is out of bounds for the list of choices given
      context
      |> append_message(
        output(
          context.character_id,
          "{{error}}The number `#{int}` is an invalid selection. Please try to exit the area again.{{/error}}"
        )
      )
      |> clear_continuation_from_context()
      |> set_success(true)
    end
  end

  @impl true
  def execute(%Mud.Engine.CommandContext{} = context) do
    context =
      if context.parsed_args == "" do
        %{
          context
          | command: %{context.command | command: normalize_direction(context.command.command)}
        }
      else
        %{
          context
          | command: %{context.command | command: normalize_direction(context.parsed_args)}
        }
      end

    case Mud.Engine.find_obvious_exit_in_area(
           context.character.location_id,
           context.command.command
         ) do
      [] ->
        append_message(
          context,
          %Mud.Engine.Output{
            id: context.id,
            character_id: context.character_id,
            text: "{{error}}You cannot travel in that direction.{{/error}}"
          }
        )

      [link] ->
        IO.inspect(link)
        do_move(context, link)

      # TODO: MAKE THIS LOGIC LIKE LOOK LOGIC WITH MULTIPLE MATCHES
      # links here like object
      list_of_links when length(list_of_links) < 10 ->
        Logger.debug("Several Links found")
        obvious_directions = Stream.map(list_of_links, & &1.text)

        error =
          "{{warning}}Multiple matching exits were found. Please enter the number associated with the exit you wish to use.{{/warning}}"

        multiple_link_error(context, list_of_links, obvious_directions, error)

      _many ->
        Logger.debug("Many Links found")

        context
        |> append_message(
          output(
            context.character_id,
            "{{error}}Which Exit?{{/error}}"
          )
        )
        |> set_success(true)
    end
  end

  defp do_move(context, link) do
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
                "{{info}}#{character.name} has entered the area from #{link.arrival_direction}.{{info}}"
            }
          )
        end
      )

    context_with_all_messages
    |> Mud.Engine.Util.clear_continuation_from_context()
    |> set_success()
  end

  defp multiple_link_error(context, items, strings, error_message) do
    items = Mud.Util.list_to_index_map(items)

    context
    |> append_message(
      output(
        context.character_id,
        error_message,
        strings
      )
    )
    |> set_is_continuation(true)
    |> set_continuation_data(items)
    |> set_continuation_module(__MODULE__)
    |> set_success()
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
