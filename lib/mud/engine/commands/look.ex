defmodule Mud.Engine.Command.Look do
  use Mud.Engine.CommandCallback

  alias Mud.Engine.{Character, Link, Object}
  alias Mud.Engine.Command.Segment
  import Mud.Engine.Util

  require Logger

  defmodule ContinuationData do
    @enforce_keys [:data, :type]
    defstruct type: nil,
              data: nil
  end

  @exact_match_order [:character, :object, :exit]
  @partial_match_order [:character, :object, :exit]

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
  def execute(context) do
    IO.inspect("Beginning execution with the following context: #{inspect(context)}")

    segments = context.command.segments

    cond do
      # Accept either 'look at sword' or 'look sword'
      (Map.has_key?(segments, :at) and Map.has_key?(segments, :target) and
         length(Map.keys(segments)) == 3) or
          (Map.has_key?(segments, :look) and Map.has_key?(segments, :target) and
             length(Map.keys(segments)) == 2) ->
        Logger.debug("searching for target")
        segment = segments.target

        look_at_target(context, Enum.join(segment.input, " "))

      # Accept 'look'
      segments.look != nil ->
        Logger.debug("building area description")
        IO.inspect(context)
        description = build_area_description(context.character.location_id, context.character.id)

        context
        |> append_message(output(context.character_id, description))
        |> set_success()
    end
  end

  defp look_at_target(context, input) do
    Logger.debug("look_at_target")

    case look_at_exact_matches(context, input) do
      {:ok, context} ->
        Logger.debug("exact match found")
        context

      {:error, :no_match} ->
        Logger.debug("no exact match found")

        case look_at_partial_matches(context, input) do
          {:ok, context} ->
            Logger.debug("partial match found")
            context

          {:error, _} ->
            Logger.debug("no partial match found")

            context
            |> append_message(
              output(
                context.character_id,
                "{{error}}Could not find what you were looking for. Please try again.{{/error}}"
              )
            )
            |> set_success(true)
        end
    end
  end

  defp look_at_exact_matches(context, input) do
    Logger.debug("look_at_exact_matches")

    Enum.find_value(@exact_match_order, {:error, :no_match}, fn exact_match_type ->
      case find_exact_match(exact_match_type, context, input) do
        {:ok, context} ->
          {:ok, context}

        _ ->
          Logger.debug("No exact match found")

          false
      end
    end)
  end

  defp find_exact_match(:character, context, input) do
    Logger.debug("find_exact_match character")

    case Character.get_by_name_in_area(input, context.character.location_id) do
      character = %Character{} ->
        Logger.debug("Character found by perfect match: #{inspect(character)}")

        context =
          context
          |> append_message(
            output(
              context.character_id,
              "{{info}}You see #{character.name}.{{/info}}"
            )
          )
          |> set_success(true)

        {:ok, context}

      _ ->
        Logger.debug("No character found")

        {:error, :no_match}
    end
  end

  defp find_exact_match(:exit, context, input) do
    Logger.debug("find_exact_match exit")

    case Link.list_obvious_exits_by_exact_description_in_area(
           input,
           context.character.location_id
         ) do
      [link] ->
        Logger.debug("Link found: #{inspect(link)}")

        room_description = build_area_description(link.to_id, context.character.id)

        context =
          context
          |> append_message(
            output(
              context.character_id,
              room_description
            )
          )
          |> set_success()

        {:ok, context}

      [] ->
        Logger.debug("No link found")
        {:error, :no_match}

      links when length(links) <= 10 and length(links) > 1 ->
        Logger.debug("Several Links found")
        directions = Stream.map(links, & &1.text)

        error =
          "{{warning}}Multiple matching exits were found. Please enter the number associated with the Exit you wish to `look` at.{{/warning}}"

        context = multiple_result_error(context, directions, directions, error)

        {:ok, context}

      _many ->
        Logger.debug("Many links found")
        {:error, :no_match}
    end
  end

  defp find_exact_match(:object, context, input) do
    Logger.debug("find_exact_match object")

    case Object.list_by_exact_description_in_area(
           input,
           context.character.location_id
         ) do
      [object = %Object{}] ->
        Logger.debug("Object found: #{inspect(object)}")

        context =
          context
          |> append_message(
            output(
              context.character_id,
              "{{info}}#{object.description.look_description}.{{/info}}"
            )
          )
          |> set_success()

        {:ok, context}

      _ ->
        Logger.debug("Zero or multiple objects found")
        {:error, :no_match}
    end
  end

  defp look_at_partial_matches(context, input) do
    Logger.debug("look_at_partial_matches")

    potential_matches =
      @partial_match_order
      |> Enum.map(fn partial_match_type ->
        find_partial_match(partial_match_type, context, input)
      end)
      |> List.flatten()

    case potential_matches do
      [match] ->
        Logger.debug("Single partial match found: #{inspect(match)}")

        context =
          context
          |> append_message(
            output(
              context.character_id,
              "{{info}}#{match}{{/info}}"
            )
          )
          |> set_success(true)

        {:ok, context}

      matches when length(matches) <= 10 and length(matches) > 1 ->
        Logger.debug("Several matches found")

        error =
          "{{warning}}Multiple matches were found. Please enter the number associated with the thing you wish to `look` at.{{/warning}}"

        context = multiple_result_error(context, matches, matches, error)

        {:ok, context}

      _many_or_none ->
        Logger.debug("Many or no matches found")

        {:error, :no_match}
    end
  end

  defp find_partial_match(:character, context, input) do
    Character.list_names_by_case_insensitive_prefix_in_area(input, context.character.id)
    # case Character.list_names_by_case_insensitive_prefix_in_area(input, context.character.id) do
    #   [name] ->
    #     Logger.debug("Character found by partial match: #{inspect(name)}")

    #     context =
    #       context
    #       |> append_message(
    #         output(
    #           context.character_id,
    #           "{{info}}You see #{name}.{{/info}}"
    #         )
    #       )
    #       |> set_success(true)

    #     {:ok, context}

    #   characters when length(characters) <= 10 and length(characters) > 1 ->
    #     Logger.debug("Several Characters found")
    #     names = Stream.map(characters, & &1.name)

    #     error =
    #       "{{warning}}Multiple matching characters were found. Please enter the number associated with the Character you wish to `look` at.{{/warning}}"

    #     context = multiple_result_error(context, names, names, error)

    #     {:ok, context}

    #   _many_or_none ->
    #     Logger.debug("Many or no Characters found")

    #     {:error, :no_match}
    # end
  end

  defp find_partial_match(:exit, context, input) do
    # Logger.debug("find_partial_match exit")

    Link.list_obvious_exits_by_partial_description_in_area(input, context.character.location_id)
    |> Enum.map(& &1.text)

    # case Link.list_obvious_exits_by_partial_description_in_area(
    #        input,
    #        context.character.location_id
    #      ) do
    #   [link] ->
    #     Logger.debug("Link found: #{inspect(link)}")

    #     context =
    #       context
    #       |> append_message(
    #         output(
    #           context.character_id,
    #           "{{info}}You see #{link.description}.{{/info}}"
    #         )
    #       )
    #       |> set_success()

    #     {:ok, context}

    #   [] ->
    #     Logger.debug("No link found")
    #     {:error, :no_match}

    #   links when length(links) <= 10 and length(links) > 1 ->
    #     Logger.debug("Several Links found")
    #     directions = Stream.map(links, & &1.text)

    #     error =
    #       "{{warning}}Multiple matching exits were found. Please enter the number associated with the Exit you wish to `look` at.{{/warning}}"

    #     context = multiple_result_error(context, directions, directions, error)

    #     {:ok, context}

    #   _many ->
    #     Logger.debug("Many links found")
    #     {:error, :no_match}
    # end
  end

  defp find_partial_match(:object, context, input) do
    Object.list_descriptions_by_partial_description_in_area(input, context.character.location_id)
    # case Object.list_by_partial_key_in_area(input, context.character.location_id) do
    #   [object] ->
    #     Logger.debug("Object found: #{inspect(object)}")

    #     context =
    #       context
    #       |> append_message(
    #         output(
    #           context.character_id,
    #           "{{info}}You see #{object.description.look_description}.{{/info}}"
    #         )
    #       )
    #       |> set_success()

    #     {:ok, context}

    #   objects when length(objects) <= 10 and length(objects) > 1 ->
    #     Logger.debug("Several Objects found")
    #     descriptions = Stream.map(objects, & &1.description.glance_description)

    #     error =
    #       "{{warning}}Multiple matching objects were found. Please enter the number associated with the object you wish to `look` at.{{/warning}}"

    #     {:ok, multiple_result_error(context, descriptions, descriptions, error)}

    #   _many ->
    #     {:error, :no_match}
    # end
  end

  defp multiple_result_error(context, keys, values, error_message) do
    values =
      values
      |> Enum.map(&("look " <> &1))
      |> Mud.Util.list_to_index_map()

    context
    |> append_message(
      output(
        context.character_id,
        error_message,
        keys
      )
    )
    |> set_is_continuation(true)
    |> set_continuation_data(values)
    |> set_continuation_module(__MODULE__)
    |> set_continuation_type(:numeric)
    |> set_success()
  end

  defp build_area_description(area_id, character_id) do
    IO.inspect({area_id, character_id})
    area = Mud.Engine.get_area!(area_id)

    build_area_name(area)
    |> build_area_desc(area)
    |> maybe_build_things_of_interest(area)
    |> maybe_build_on_ground(area)
    |> maybe_build_hostiles(area)
    |> maybe_build_denizens(area)
    |> maybe_build_also_present(area, character_id)
    |> maybe_build_obvious_exits(area)
  end

  defp build_area_name(area) do
    "{{area-name}}[#{area.name}]{{/area-name}}\n"
  end

  defp build_area_desc(text, area) do
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

  defp maybe_build_things_of_interest(text, area) do
    things_of_interest =
      Object.list_in_area(area.id)
      |> Stream.filter(& &1.is_scenery)
      |> Stream.filter(fn obj ->
        obj.scenery == nil or obj.scenery.hidden != true
      end)
      |> Stream.map(fn object ->
        object.description.glance_description
      end)
      |> Enum.sort()
      |> Enum.join(", ")

    if things_of_interest == "" do
      text
    else
      text <>
        "{{things-of-interest}}Things of Interest: #{things_of_interest}{{/things-of-interest}}\n"
    end
  end

  defp maybe_build_on_ground(text, area) do
    on_ground =
      Object.list_in_area(area.id)
      |> Stream.filter(&(!&1.is_scenery))
      |> Stream.map(fn object ->
        object.description.glance_description
      end)
      |> Enum.sort()
      |> Enum.join(", ")

    if on_ground == "" do
      text
    else
      text <> "{{on-ground}}On Ground: #{on_ground}{{/on-ground}}\n"
    end
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
      link.text
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
