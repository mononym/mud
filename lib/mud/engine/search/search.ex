defmodule Mud.Engine.Search do
  @moduledoc """
  Utilities to help with searching during autocomplete.
  """

  alias Mud.Engine.{Character, Item, Link}
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

  @spec find_matches_in_area_v2(
          [:character | :item | :link],
          String.t(),
          String.t(),
          Character.t(),
          integer()
        ) ::
          {:ok, [Match.t()]} | {:error, :out_of_range | :no_match}
  def find_matches_in_area_v2(target_types, area_id, input, looking_character, which_target) do
    target_types
    |> Stream.map(fn type -> find_matches(type, area_id) end)
    |> Enum.map(fn matches ->
      matches
      |> things_to_match(looking_character)
      |> build_search_results(input)
    end)
    |> merge_search_results()
    |> check_search_results(which_target)
  end

  defp check_search_results(results, which_target) do
    case check_matches(results.exact_matches, which_target) do
      {:error, :no_match} ->
        check_matches(results.partial_matches, which_target)

      result ->
        result
    end
  end

  defp check_matches(matches, which_target) do
    num_matches = length(matches)

    cond do
      # happy path with matches with no index chosen
      num_matches >= 1 and which_target == 0 ->
        {:ok, matches}

      # happy path where there are multiple matches, and chosen index is in range
      num_matches > 0 and which_target > 0 and which_target <= num_matches ->
        match =
          matches
          |> Enum.at(which_target - 1)
          |> List.wrap()

        {:ok, [match]}

      # unhappy path where there are multiple matches but chosen index is out of range
      num_matches > 0 and which_target > num_matches ->
        {:error, :out_of_range}

      # unhappy path where there are no matches
      num_matches == 0 ->
        {:error, :no_match}
    end
  end

  @doc """
  Given a list of characters/items/links and a string to check against, generate a set of matches or return an error.
  """
  @spec generate_matches(
          [Character.t() | Item.t() | Link.t()],
          String.t(),
          Character.t(),
          integer()
        ) ::
          {:ok, [Match.t()]} | {:error, :out_of_range | :no_match}
  def generate_matches(things, input, looking_character, which_target \\ 0) do
    things
    |> things_to_match(looking_character)
    |> build_search_results(input)
    |> check_search_results(which_target)
  end

  @spec find_matches_in_area([:character | :item | :link], String.t(), String.t(), Character.t()) ::
          SearchResults.t()
  def find_matches_in_area(target_types, area_id, input, looking_character) do
    target_types
    |> Stream.map(fn type -> find_matches(type, area_id) end)
    |> Enum.map(fn matches ->
      matches
      |> things_to_match(looking_character)
      |> build_search_results(input)
    end)
    |> merge_search_results()
  end

  defp find_matches(:character, area_id) do
    area_id
    |> Character.list_in_area()
  end

  defp find_matches(:item, area_id) do
    area_id
    |> Item.list_in_area()
  end

  defp find_matches(:link, area_id) do
    area_id
    |> Link.list_obvious_exits_in_area()
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
    Logger.debug(inspect({input, match_string}))

    cond do
      String.equivalent?(match_string, input) ->
        :exact_matches

      Regex.match?(search_regex, match_string) ->
        :partial_matches

      true ->
        :nomatch
    end
  end

  defp things_to_match(links = [%Link{} | _], looking_character) do
    Enum.map(links, fn link ->
      %Match{
        match_string: String.downcase(link.text),
        glance_description: link.text,
        look_description: Link.describe_look(link, looking_character),
        match: link
      }
    end)
  end

  defp things_to_match(characters = [%Character{} | _], looking_character) do
    Enum.map(characters, fn character ->
      %Match{
        match_string: String.downcase(character.name),
        glance_description: Character.describe_glance(character, looking_character),
        look_description: Character.describe_look(character, looking_character),
        match: character
      }
    end)
  end

  defp things_to_match(items = [%Item{} | _], looking_character) do
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

  defp things_to_match([], _), do: []
end
