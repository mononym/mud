defmodule Mud.Engine.Command.Look do
  use Mud.Engine.CommandCallback

  alias Mud.Engine.{Character, Link, Object}
  alias Mud.Engine.Model.{CharacterModel, LinkModel, ObjectModel}
  alias Mud.Engine.CommandContext
  import Mud.Engine.Util

  require Logger

  defmodule ContinuationData do
    @enforce_keys [:data, :type]
    defstruct type: nil,
              data: nil
  end

  defmodule Match do
    @enforce_keys [:glance, :look]
    defstruct glance: nil,
              look: nil
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
  @spec continue(context :: CommandContext.t()) :: CommandContext.t()
  def continue(context) do
    segments = context.command.segments

    attempt_look_by_match(context.raw_input, context)
  end

  @impl true
  @spec execute(context :: CommandContext.t()) :: CommandContext.t()
  def execute(context) do
    IO.inspect("Beginning execution with the following context: #{inspect(context)}")

    segments = context.command.segments

    cond do
      # Accept either 'look at sword' or 'look sword' or 'look at 2 sword' or 'look 2 sword'
      (get_in(segments.children, [:number, :children, :at, :children, :target]) != nil and
         get_in(segments.children, [:number, :children, :at, :children, :target, :children, :path]) ==
           nil) or
        (get_in(segments.children, [:at, :children, :target]) != nil and
           get_in(segments.children, [:at, :children, :target, :children, :path]) == nil) or
        (get_in(segments.children, [:number, :children, :target]) != nil and
           get_in(segments.children, [:number, :children, :target, :children, :path]) == nil) or
          (get_in(segments.children, [:target]) != nil and
             get_in(segments.children, [:target, :children, :path]) == nil) ->
        Logger.debug("searching for target")

        segment =
          get_in(segments.children, [:number, :children, :at, :children, :target]) ||
            get_in(segments.children, [:at, :children, :target]) ||
            get_in(segments.children, [:target]) ||
            get_in(segments.children, [:number, :children, :target])

        which_target =
          if Map.has_key?(segments.children, :number) do
            min(1, List.first(segments.children.number.input))
          else
            0
          end

        look_at_target(context, Enum.join(segment.input, " "), which_target)

      # Accept 'look', default fallback for now, will need expanding as logic expands
      true ->
        description = describe_thing(Mud.Engine.get_area!(area_id), context.character)

        context
        |> append_message(output(context.character_id, description))
        |> set_success()
    end
  end

  @spec attempt_look_by_match(
          match :: ObjectModel.t() | LinkModel.t() | CharacterModel.t(),
          context :: CommandContext.t()
        )
  defp attempt_look_by_match(match, context) do
  end

  defp look_at_target(context, input, which_target) do
    Logger.debug("look_at_target")

    case look_at_exact_matches(context, input) do
      {:ok, context} ->
        Logger.debug("exact match found")
        context

      {:error, :no_match} ->
        Logger.debug("no exact match found")

        case look_at_partial_matches(context, input, which_target) do
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
    case Character.list_by_name_in_area(input, context.character.area_id) do
      [character] = [%Character{}] ->
        description = describe_thing(character)

        context =
          context
          |> append_message(
            output(
              context.character_id,
              "{{info}}#{description}{{/info}}"
            )
          )
          |> set_success(true)

        {:ok, context}

      _ ->
        {:error, :no_match}
    end
  end

  defp find_exact_match(:exit, context, input) do
    case Link.list_obvious_exits_by_exact_description_in_area(
           input,
           context.character.area_id
         ) do
      [link] ->
        room_description = describe_thing(link, context.character)

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
        {:error, :no_match}

      links when length(links) <= 10 and length(links) > 1 ->
        directions = Stream.map(links, & &1.text)

        error =
          "{{warning}}Multiple matching exits were found. Please enter the number associated with the Exit you wish to `look` at.{{/warning}}"

        context = multiple_result_error(context, directions, links, error, __MODULE__)

        {:ok, context}

      _many ->
        {:error, :no_match}
    end
  end

  defp find_exact_match(:object, context, input) do
    case Object.list_by_exact_glance_description_in_area(
           input,
           context.character.area_id
         ) do
      [object] ->
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
        {:error, :no_match}
    end
  end

  defp look_at_partial_matches(context, input, which_target) do
    potential_matches =
      @partial_match_order
      |> Enum.map(fn partial_match_type ->
        find_partial_match(partial_match_type, context, input)
      end)
      |> List.flatten()

    case potential_matches do
      [match] ->
        context =
          context
          |> append_message(
            output(
              context.character_id,
              "{{info}}#{match.look}{{/info}}"
            )
          )
          |> set_success(true)

        {:ok, context}

      matches when length(matches) > 1 and which_target > 0 and which_target <= length(matches) ->
        match = Enum.at(matches, which_target)

        context =
          context
          |> append_message(
            output(
              context.character_id,
              "{{info}}#{match.look}{{/info}}"
            )
          )
          |> set_success(true)

        {:ok, context}

      matches when length(matches) <= 9 and length(matches) > 1 ->
        glance_descriptions = Enum.map(matches, & &1.glance)

        error =
          "{{warning}}Multiple matches were found. Please enter the number associated with the thing you wish to `look` at.{{/warning}}"

        context = multiple_result_error(context, glance_descriptions, matches, error, __MODULE__)

        {:ok, context}

      _many_or_none ->
        {:error, :no_match}
    end
  end

  # Eventually this will need to bring back a character and do something more complex.
  # For the look it would need to actually build the look for the character.
  defp find_partial_match(:character, context, input) do
    Character.list_by_case_insensitive_prefix_in_area(input, context.character.id)
    |> Enum.map(fn name ->
      %Match{glance: name, look: name}
    end)
  end

  defp find_partial_match(:exit, context, input) do
    Link.list_obvious_exits_by_partial_description_in_area(input, context.character.area_id)
    |> Enum.map(&%Match{glance: &1.text, look: &1.text})
  end

  defp find_partial_match(:object, context, input) do
    Object.list_by_partial_glance_description_in_area(input, context.character.area_id)
    |> Enum.map(
      &%Match{glance: &1.description.glance_description, look: &1.description.look_description}
    )
  end

  def build_area_description(area_id, character_id) do
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
    Mud.Engine.Character.list_active_in_areas(area_id)
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

  defp describe_thing(character = %CharacterModel{}, looking_character = %CharacterModel{}) do
    Mud.Engine.describe_character(character)
  end

  defp describe_thing(link = %LinkModel{}, looking_character = %CharacterModel{}) do
    build_area_description(link.to_id, looking_character.id)
  end

  defp describe_thing(link = %AreaModel{}, looking_character = %CharacterModel{}) do
    build_area_description(link.to_id, looking_character.id)
  end
end
