defmodule Mud.Engine.Command.Look do
  use Mud.Engine.CommandCallback

  alias Mud.Engine.{Character, Object}

  require Logger

  defmodule ContinuationData do
    @enforce_keys [:data, :type]
    defstruct type: nil,
              data: nil
  end

  # @prepositions [
  #   "above",
  #   "across",
  #   "across from",
  #   "after",
  #   "against",
  #   "along",
  #   "alongside",
  #   "among",
  #   "at",
  #   "behind",
  #   "beside",
  #   "between",
  #   "beyond",
  #   "by",
  #   "except",
  #   "except for",
  #   "for",
  #   "following",
  #   "from",
  #   "in",
  #   "including",
  #   "inside",
  #   "into",
  #   "next to",
  #   "on",
  #   "ontop",
  #   "ontop of",
  #   "out",
  #   "over",
  #   "through",
  #   "towards",
  #   "under",
  #   "underneath",
  #   "up",
  #   "upon"
  # ]

  @impl true
  def parse_execute_arg_string(raw_args) do
    if String.starts_with?(raw_args, "at ") do
      {:ok, String.replace_leading(raw_args, "at ", "")}
    else
      {:ok, raw_args}
    end
  end

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
    Logger.debug("Continuing to execute 'look' command")

    int = context.parsed_args
    data = context.continuation_data

    # Make sure player selected an option from the list
    if int <= 9 and int >= 0 and int < map_size(data.data) do
      object = data.data[int]

      # Search for objects
      if data.type == :object do
        case Mud.Engine.get_object(object.id) do
          # The object was found
          object = %Object{} ->
            # Object is still on the ground in the same room as Character, so can be looked at
            if object.location.on_ground == true and
                 object.location.reference == context.character.location_id do
              context
              |> append_message(
                output(
                  context.character_id,
                  "{{info}}You see #{object.description.glance_description}.{{/info}}"
                )
              )
              |> clear_continuation_from_context()
              |> set_success(true)

              # Object has been moved and is not on the ground in the same room as Character, so cannot be looked at
            else
              context
              |> append_message(
                output(
                  context.character_id,
                  "{{error}}The `#{object.key}` you were attempting to observe is no longer present.{{/error}}"
                )
              )
              |> clear_continuation_from_context()
              |> set_success(true)
            end

          # Object has been deleted
          nil ->
            context
            |> append_message(
              output(
                context.character_id,
                "{{error}}The `#{object.key}` you were attempting to observe is no longer present.{{/error}}"
              )
            )
            |> clear_continuation_from_context()
            |> set_success(true)
        end
      else
        case Mud.Engine.get_character(object.id) do
          character = %Character{} ->
            # Character is still in the same room as Character run by Player, so can be looked at
            if character.location_id == context.character.location_id do
              context
              |> append_message(
                output(
                  context.character_id,
                  "{{info}}You see #{character.name}.{{/info}}"
                )
              )
              |> clear_continuation_from_context()
              |> set_success(true)

              # Character is not in room of Character run by player, so cannot be looked at
            else
              context
              |> append_message(
                output(
                  context.character_id,
                  "{{error}}The person you were attempting to observe is no longer present.{{/error}}"
                )
              )
              |> clear_continuation_from_context()
              |> set_success(true)
            end

          # Character has been deleted
          nil ->
            context
            |> append_message(
              output(
                context.character_id,
                "{{error}}The person you were attempting to observe is no longer present.{{/error}}"
              )
            )
            |> clear_continuation_from_context()
            |> set_success(true)
        end
      end
    else
      # The number Player selected is out of bounds for the list of choices given
      context
      |> append_message(
        output(
          context.character_id,
          "{{error}}The number `#{int}` is an invalid selection. Please `{{info}}look{{/info}}` again{{/error}}"
        )
      )
      |> clear_continuation_from_context()
      |> set_success(true)
    end
  end

  @impl true
  def execute(context) do
    Logger.debug("Beginning execution with the following context: #{inspect(context)}")

    case context.parsed_args do
      # An empty argument string means the intention is to look at the area
      "" ->
        build_area_description(context)

      # Player wants to look at a character or an item
      name_or_item ->
        split_input = String.split(name_or_item)

        # Player only entered a single thing after the look. So: 'look box' or 'look jim'
        if length(split_input) == 1 do
          # Start out looking for exact character name
          case Character.get_by_name(name_or_item) do
            # Found a perfect match for a character name
            character = %Character{} ->
              Logger.debug("Character found by perfect match: #{inspect(character)}")

              context
              |> append_message(
                output(
                  context.character_id,
                  "{{info}}You see #{character.name}.{{/info}}"
                )
              )
              |> set_success()

            # No perfect match for a character was found
            nil ->
              Logger.debug("Character not found")
              # Look for any matches with objects
              objects = Object.list_by_key_in_area(name_or_item, context.character.location_id)
              Logger.debug("Listing objects")

              case length(objects) do
                # If there are no matches with objects, check for partial character name
                0 ->
                  Logger.debug("No objects found, listing characters by prefix")

                  case Character.list_by_case_insensitive_prefix_in_area(
                         name_or_item,
                         context.character.location_id
                       ) do
                    [character] ->
                      Logger.debug("Character found by prefix: #{inspect(character)}")

                      context
                      |> append_message(
                        output(
                          context.character_id,
                          "{{info}}You see #{character.name}.{{/info}}"
                        )
                      )
                      |> set_success()

                    [] ->
                      Logger.debug("No Character found")

                      context
                      |> append_message(
                        output(
                          context.character_id,
                          "{{error}}What did you want to look at?{{/error}}"
                        )
                      )
                      |> set_success(true)

                    list_of_characters when length(list_of_characters) < 10 ->
                      Logger.debug("Several Characters found")
                      names = Stream.map(objects, & &1.name)

                      error =
                        "{{warning}}Multiple matching characters were found. Please enter the number associated with the item you wish to `look` at.{{/warning}}"

                      multiple_object_error(context, list_of_characters, names, error, :character)

                    _many ->
                      Logger.debug("Many Characters found")

                      context
                      |> append_message(
                        output(
                          context.character_id,
                          "{{error}}Could not find what you were looking for. Please try again.{{/error}}"
                        )
                      )
                      |> set_success(true)
                  end

                _count ->
                  handle_object_response(context, objects)
              end
          end
        else
          objects =
            Object.list_by_description_in_area(split_input, context.character.location_id)

          handle_object_response(context, objects)
        end
    end
  end

  defp handle_object_response(context, objects) do
    case length(objects) do
      1 ->
        [object] = objects

        context
        |> append_message(
          output(
            context.character_id,
            "{info}}You see #{object.description.glance_description}.{{/info}}"
          )
        )
        |> set_success(true)

      # Multiple objects were found, but not too many to show them in a list with options
      count when count <= 10 ->
        glances = Stream.map(objects, & &1.description.glance_description)

        error =
          "{{warning}}Multiple matching items were found. Please enter the number associated with the item you wish to `look` at.{{/warning}}"

        multiple_object_error(context, objects, glances, error, :object)

      _too_many ->
        context
        |> append_message(
          output(
            context.character_id,
            "{error}}Found too many items, please be more specific.{{/error}}"
          )
        )
        |> set_success()
    end
  end

  defp multiple_object_error(context, items, strings, error_message, type) do
    items = list_to_index_map(items)

    context
    |> append_message(
      output(
        context.character_id,
        error_message,
        strings
      )
    )
    |> set_is_continuation(true)
    |> set_continuation_data(%ContinuationData{
      data: items,
      type: type
    })
    |> set_continuation_module(__MODULE__)
    |> set_success()
  end

  def output(who, text, table_data \\ nil) do
    %Mud.Engine.Output{
      id: UUID.uuid4(),
      character_id: who,
      text: text,
      table_data: table_data
    }
  end

  defp list_to_index_map(list) do
    list
    |> Stream.with_index()
    |> Enum.reduce(%{}, fn {thing, index}, map ->
      Map.put(map, index, thing)
    end)
  end

  defp clear_continuation_from_context(context) do
    context
    |> clear_continuation_data()
    |> clear_continuation_module()
    |> set_is_continuation(false)
  end

  defp build_area_description(context) do
    area = Mud.Engine.get_area!(context.character.location_id)

    output =
      build_area_name(area)
      |> build_area_description(area)
      |> maybe_build_on_ground(area)
      |> maybe_build_hostiles(area)
      |> maybe_build_denizens(area)
      |> maybe_build_also_present(area, context.character_id)
      |> maybe_build_obvious_exits(area)

    context
    |> append_message(output(context.character_id, output))
    |> set_success()
  end

  defp build_area_name(area) do
    "{{area-name}}[#{area.name}]{{/area-name}}\n"
  end

  defp build_area_description(text, area) do
    text <> "{{area-description}}#{area.description}{{/area-description}}\n"
  end

  defp maybe_build_hostiles(text, _area) do
    # <> "{{hostiles}}Hostiles: #{player_characters}{{/hostiles}}\n"
    text
  end

  defp maybe_build_denizens(text, _area) do
    # <> "{{denizens}}Denizens: #{player_characters}{{/denizens}}\n"
    text
  end

  defp maybe_build_on_ground(text, area) do
    on_ground = build_objects_string(area.id)

    if on_ground == "" do
      text
    else
      text <> "{{on-ground}}On Ground: #{on_ground}{{/on-ground}}\n"
    end
  end

  # Character list should not contain the character the look is being performed for
  defp build_objects_string(area_id) do
    Object.list_in_area(area_id)
    |> Enum.map(fn object ->
      object.description.glance_description
    end)
    |> Enum.sort()
    |> Enum.join(", ")
  end

  defp maybe_build_also_present(text, area, character_id) do
    also_present = build_player_characters_string(area.id, character_id)

    if also_present == "" do
      text
    else
      text <> "{{also-present}}Also Present: #{also_present}{{/also-present}}\n"
    end
  end

  defp maybe_build_obvious_exits(text, area) do
    obvious_exits = build_obvious_exits_string(area.id)

    if obvious_exits == "" do
      text
    else
      text <> "{{obvious-exits}}Obvious Exits: #{obvious_exits}{{/obvious-exits}}\n"
    end
  end

  defp build_obvious_exits_string(area_id) do
    Mud.Engine.list_obvious_exits(area_id)
    |> Enum.map(fn link ->
      link.departure_direction
    end)
    |> Enum.sort()
    |> Enum.join(", ")
  end

  # Character list should not contain the character the look is being performed for
  defp build_player_characters_string(area_id, character_id) do
    Mud.Engine.list_active_characters_in_areas(area_id)
    # filter out self
    |> Enum.filter(fn char ->
      char.id != character_id
    end)
    |> Enum.map(fn char ->
      char.name
    end)
    |> Enum.sort()
    |> Enum.join(", ")
  end
end
