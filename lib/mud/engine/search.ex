defmodule Mud.Engine.Search do
  @moduledoc """
  Utilities to help with searching during autocomplete.
  """

  alias Mud.Engine.Model.{Character, Item, Link}
  import Mud.Engine.Util

  defmodule Match do
    @enforce_keys [:match_string, :glance_description, :look_description, :match]
    defstruct match_string: nil,
              glance_description: nil,
              look_description: nil,
              match: nil
  end

  defmodule SearchResults do
    @moduledoc false

    defstruct exact_matches: [], partial_matches: []
  end

  def find_matches_in_area(input, area_id, looking_character_id) do
    item_matches = find_item_matches_in_area(input, area_id, looking_character_id)
    char_matches = find_character_matches_in_area(input, area_id, looking_character_id)
    link_matches = find_link_matches_in_area(input, area_id, looking_character_id)

    merge_search_results(item_matches ++ char_matches ++ link_matches)
  end

  defp find_link_matches_in_area(input, area_id, looking_character_id) do
    area_id
    |> Link.list_in_area()
    |> links_to_match(looking_character_id)
    |> build_search_results(input)
  end

  defp find_character_matches_in_area(input, area_id, looking_character_id) do
    area_id
    |> Character.list_in_area()
    |> characters_to_match(looking_character_id)
    |> build_search_results(input)
  end

  defp find_item_matches_in_area(input, area_id, looking_character_id) do
    area_id
    |> Item.list_in_area()
    |> items_to_match(looking_character_id)
    |> build_search_results(input)
  end

  # Performs the sorting of the possible matches, dumping those that don't match
  defp build_search_results(matches, input) do
    Enum.reduce(matches, %SearchResults{}, fn match, result ->
      search_regex = input_to_fuzzy_regex(input)
      type = type_of_match(input, search_regex, match.match_string)

      if type != :nomatch do
        Map.put(result, type, [match | result[type]])
      else
        result
      end
    end)
  end

  defp merge_search_results(search_results) do
    Enum.reduce(search_results, %SearchResults{}, fn result, final_results ->
      %{
        final_results
        | exact_matches: result.exact_matches ++ final_results.exact_matches,
          partial_matches: result.partial_matches ++ final_results.partial_matches
      }
    end)
  end

  # Determines what category/type of match the item/character/link is with the given input
  defp type_of_match(input, search_regex, match_string) do
    cond do
      String.equivalent?(match_string, input) ->
        :exact

      Regex.match?(search_regex, match_string) ->
        :partial

      true ->
        :nomatch
    end
  end

  defp links_to_match(links, looking_character_id) do
    Enum.map(links, fn link ->
      %Match{
        match_string: String.downcase(link.text),
        glance_description: link.text,
        look_description: Link.describe_look(link, looking_character_id),
        match: link
      }
    end)
  end

  defp characters_to_match(characters, looking_character_id) do
    Enum.map(characters, fn character ->
      %Match{
        match_string: String.downcase(character.name),
        glance_description: Character.describe_glance(character, looking_character_id),
        look_description: Character.describe_look(character, looking_character_id),
        match: character
      }
    end)
  end

  defp items_to_match(items, looking_character_id) do
    Enum.map(items, fn item ->
      desc = Item.describe_glance(item, looking_character_id)

      %Match{
        match_string: String.downcase(desc),
        glance_description: desc,
        look_description: Item.describe_look(item, looking_character_id),
        match: item
      }
    end)
  end
end
