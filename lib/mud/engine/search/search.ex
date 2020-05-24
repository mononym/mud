defmodule Mud.Engine.Search do
  @moduledoc """
  Utilities to help with searching during autocomplete.
  """

  alias Mud.Engine.Model.{Character, Item, Link}
  import Mud.Engine.Util
  require Logger

  defmodule Match do
    @enforce_keys [:match_string, :glance_description, :look_description, :match]
    defstruct match_string: nil,
              glance_description: nil,
              look_description: nil,
              match: nil

    @type t() :: %__MODULE__{
            match_string: String.t(),
            glance_description: String.t(),
            look_description: String.t(),
            match: Character.t() | Item.t() | Link.t()
          }
  end

  defmodule SearchResults do
    @moduledoc false

    defstruct exact_matches: [], partial_matches: []

    @type t() :: %__MODULE__{
            exact_matches: [Mud.Engine.Search.Match.t()],
            partial_matches: [Mud.Engine.Search.Match.t()]
          }
  end

  @spec find_matches_in_area([:character | :item | :link], String.t(), String.t(), Character.t()) ::
          SearchResults.t()
  def find_matches_in_area(target_types, area_id, input, looking_character) do
    target_types
    |> Enum.map(fn type -> find_matches(type, area_id, input, looking_character) end)
    |> merge_search_results()
  end

  defp find_matches(:character, area_id, input, looking_character) do
    area_id
    |> Character.list_in_area()
    |> characters_to_match(looking_character)
    |> build_search_results(input)
  end

  defp find_matches(:item, area_id, input, looking_character) do
    area_id
    |> Item.list_in_area()
    |> items_to_match(looking_character)
    |> build_search_results(input)
  end

  defp find_matches(:link, area_id, input, looking_character) do
    area_id
    |> Link.list_obvious_exits_in_area()
    |> links_to_match(looking_character)
    |> build_search_results(input)
  end

  # Performs the sorting of the possible matches, dumping those that don't match
  defp build_search_results(matches, input) do
    Enum.reduce(matches, %SearchResults{}, fn match, result ->
      search_regex = input_to_fuzzy_regex(input)
      type = type_of_match(input, search_regex, match.match_string)

      if type != :nomatch do
        Map.put(result, type, [match | Map.get(result, type)])
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
        :exact_matches

      Regex.match?(search_regex, match_string) ->
        :partial_matches

      true ->
        :nomatch
    end
  end

  defp links_to_match(links, looking_character) do
    Enum.map(links, fn link ->
      %Match{
        match_string: String.downcase(link.text),
        glance_description: link.text,
        look_description: Link.describe_look(link, looking_character),
        match: link
      }
    end)
  end

  defp characters_to_match(characters, looking_character) do
    Enum.map(characters, fn character ->
      %Match{
        match_string: String.downcase(character.name),
        glance_description: Character.describe_glance(character, looking_character),
        look_description: Character.describe_look(character, looking_character),
        match: character
      }
    end)
  end

  defp items_to_match(items, looking_character) do
    Enum.map(items, fn item ->
      desc = Item.describe_glance(item, looking_character)

      %Match{
        match_string: String.downcase(desc),
        glance_description: desc,
        look_description: Item.describe_look(item, looking_character),
        match: item
      }
    end)
  end
end
