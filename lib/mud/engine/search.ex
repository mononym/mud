defmodule Mud.Engine.Search do
  @moduledoc """
  Utilities to help with searching during autocomplete.
  """

  alias Mud.Engine.Character
  alias Mud.Engine.Link

  @doc """
  Constant for matching against what type of thing to search for during autocomplete.
  """
  @spec switches() :: atom()
  def switches, do: :switches

  @doc """
  Constant for matching against what type of thing to search for during autocomplete.
  """
  @spec characters() :: atom()
  def characters, do: :characters

  @doc """
  Constant for matching against what type of thing to search for during autocomplete.
  """
  @spec exits() :: atom()
  def exits, do: :exits

  @doc """
  Constant for matching against what type of thing to search for during autocomplete.
  """
  @spec scenery() :: atom()
  def scenery, do: :scenery

  @doc """
  Constant for matching against what type of thing to search for during autocomplete.
  """
  @spec objects() :: atom()
  def objects, do: :objects

  @doc """
  Given a list of types of things to search, returns a list of suggestions.
  """
  @spec autocomplete(
          things_to_search :: [:switches | :characters | :exits | :scenery | :objects],
          text :: String.t(),
          area_id :: String.t()
        ) :: [String.t()]
  def autocomplete(things_to_search, text, character_id) do
    things_to_search
    |> Enum.map(fn thing ->
      search(thing, text, character_id)
    end)
    |> List.flatten()
  end

  @doc """
  Take a string and return a string with the words surrounded by percent signs.

  ## Examples

      iex> text_to_search_terms("pouch")
      "%pouch%"

      iex> text_to_search_terms("red pouch encrusted diamonds")
      "%red% %pouch% %encrusted% %diamonds%"
  """
  @spec text_to_search_terms(text :: String.t()) :: String.t()
  def text_to_search_terms(text) do
    text
    |> String.split()
    |> Stream.map(&"%#{&1}%")
    |> Enum.join(" ")
  end

  defp search(:character, text, character_id) do
    Character.list_names_by_case_insensitive_prefix_in_area(text, character_id)
  end

  defp search(:obvious_exit, text, character_id) do
    Link.list_text_of_obvious_exits_around_character(text, character_id)
  end

  # defp search(:object, text, character_id) do
  #   Object.list_description_by_description_in_area(text, character_id)
  # end

  # Scenery is currently taken care of by :object search above
  defp search(:scenery, _text, _area_id) do
    []
  end
end
