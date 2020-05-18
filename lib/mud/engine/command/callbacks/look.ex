defmodule Mud.Engine.Command.Look do
  use Mud.Engine.Command.Callback

  alias Mud.Engine.Model.{Area, Character, Link, Item}
  alias Mud.Engine.Command.ExecutionContext
  alias Mud.Engine.Search
  import Mud.Engine.Util

  require Logger

  defmodule ContinuationData do
    @enforce_keys [:data, :type]
    defstruct type: nil,
              data: nil
  end

  @impl true
  def continue(context) do
    description = describe_thing(context.input, context.character)

    context
    |> append_message(
      output(
        context.character_id,
        "{{info}}#{description}{{/info}}"
      )
    )
    |> set_success()
  end

  @impl true
  def execute(context) do
    segment = context.command.segments

    if segment[:target] != nil do
      which_target =
        if segment[:number] != nil do
          min(1, List.first(segment[:number][:input]))
        else
          1
        end

      look_at_target(context, segment[:target][:input], which_target)
    else
      description =
        describe_thing(
          Area.get_area!(context.character.area_id),
          context.character
        )

      context
      |> append_message(output(context.character_id, description))
      |> set_success()
    end
  end

  defp look_at_target(context, input, which_target) do
    matches = Search.find_matches_in_area(input, context.character.area_id, context.character)
    num_exact_matches = length(matches.exact_matches)
    num_partial_matches = length(matches.partial_matches)

    # NOTE: The 'duplicate' logic here is intentional. DO NOT REFACTOR UNLESS YOU KNOW WHAT YOU ARE DOING!
    #
    # Desired behaviour is that if there are exact matches, they should be handled as if there were no partial matches.
    cond do
      # success/happy path is where the chosen target is not above the number of matches
      num_exact_matches > 0 and which_target <= num_exact_matches ->
        match = Enum.at(matches.exact_matches, which_target - 1)

        ExecutionContext.success_with_output(context, match.look_description, "info")

      # failure/unhappy path is where there are exact matches, but chosen index is higher than allowed
      num_exact_matches > 0 and which_target > num_exact_matches ->
        handle_multiple_matches(context, matches.exact_matches)

      # success/happy path is where the chosen target is not above the number of matches
      num_partial_matches > 0 and which_target <= num_partial_matches ->
        match = Enum.at(matches.partial_matches, which_target - 1)

        ExecutionContext.success_with_output(context, match.look_description, "info")

      # failure/unhappy path is where there are partial matches, but chosen index is higher than allowed
      num_partial_matches > 0 and which_target > num_partial_matches ->
        handle_multiple_matches(context, matches.partial_matches)
    end
  end

  defp handle_multiple_matches(context, matches) when length(matches) < 10 do
    descriptions = Enum.map(matches, & &1.glance_description)

    error_msg =
      "{{warning}}Multiple matches were found. Please enter the number associated with the thing you wish to `look` at.{{/warning}}"

    multiple_match_error(context, descriptions, matches, error_msg, __MODULE__)
  end

  defp handle_multiple_matches(context, _matches) do
    error_msg = "Found too many matches. Please be more specific."

    ExecutionContext.success_with_output(context, error_msg, "error")
  end

  # TODO: Revisit this and streamline it. Only hit DB once and pull back more data
  @spec build_area_description(String.t(), String.t()) :: String.t()
  def build_area_description(area_id, character_id) do
    area = Mud.Engine.Model.Area.get_area!(area_id)

    build_area_name(area)
    |> build_area_desc(area)
    |> maybe_build_things_of_interest(area, character_id)
    |> maybe_build_on_ground(area, character_id)
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

  defp maybe_build_things_of_interest(text, area, looking_character_id) do
    things_of_interest =
      area.id
      |> Item.list_visible_scenery_in_area()
      |> Stream.map(fn item ->
        describe_thing(item, looking_character_id)
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

  defp maybe_build_on_ground(text, area, looking_character_id) do
    on_ground =
      Item.list_in_area(area.id)
      |> Stream.filter(&(!&1.is_scenery))
      |> Stream.map(fn item ->
        describe_thing(item, looking_character_id)
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
    Mud.Engine.Model.Link.list_obvious_exits(area_id)
    |> Enum.map(fn link ->
      link.text
    end)
    |> Enum.sort()
    |> Enum.join(", ")
  end

  # Character list should not contain the character the look is being performed for
  defp build_player_characters_string(area_id, character_id) do
    Mud.Engine.Model.Character.list_active_in_areas(area_id)
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

  defp describe_thing(item, looking_character, lod \\ :glance)

  defp describe_thing(item = %Item{}, looking_character_id, :look) do
    Item.describe_look(item, looking_character_id)
  end

  defp describe_thing(item = %Item{}, looking_character_id, :glance) do
    Item.describe_glance(item, looking_character_id)
  end

  defp describe_thing(character = %Character{}, looking_character_id, :look) do
    Character.describe_look(character, looking_character_id)
  end

  defp describe_thing(character = %Character{}, looking_character_id, :glance) do
    Character.describe_glance(character, looking_character_id)
  end

  defp describe_thing(link = %Link{}, looking_character_id, _) do
    build_area_description(link.to_id, looking_character_id)
  end

  defp describe_thing(area = %Area{}, looking_character_id, _) do
    build_area_description(area.id, looking_character_id)
  end
end
