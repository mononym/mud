defmodule Mud.Engine.Search do
  @moduledoc """
  Utilities to help with searching during autocomplete.
  """

  alias Mud.Engine.{Character, Item, Link}
  require Logger

  defmodule Match do
    @enforce_keys [:match_string, :short_description, :long_description, :match]
    defstruct match_string: nil,
              short_description: nil,
              long_description: nil,
              match: nil

    @type t() :: %__MODULE__{
            match_string: String.t(),
            short_description: String.t(),
            long_description: String.t(),
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

  @doc """
  Find matches in worn containers.
  """
  @spec find_matches_in_worn_containers(
          String.t(),
          String.t()
        ) ::
          {:ok, [Match.t()]} | {:error, :no_match}
  def find_matches_in_worn_containers(character_id, input, mode \\ "simple") do
    search_string = input_to_wildcard_string(input, mode)
    items = Item.search_worn_containers(character_id, search_string)

    case things_to_match(items) do
      [] ->
        {:error, :no_match}

      matches ->
        {:ok, matches}
    end
  end

  @doc """
  Find matches in worn or held items.
  """
  @spec find_matches_in_inventory(
          String.t(),
          String.t()
        ) ::
          {:ok, [Match.t()]} | {:error, :no_match}
  def find_matches_in_inventory(character_id, input, mode \\ "simple") do
    search_string = input_to_wildcard_string(input, mode)
    items = Item.search_inventory(character_id, search_string)

    case things_to_match(items) do
      [] ->
        {:error, :no_match}

      matches ->
        {:ok, matches}
    end
  end

  @doc """
  Find matches on the ground or in the area.
  """
  @spec find_matches_in_area(
          String.t(),
          String.t()
        ) ::
          {:ok, [Match.t()]} | {:error, :no_match}
  def find_matches_in_area(area_id, input, mode \\ "simple") do
    search_string = input_to_wildcard_string(input, mode)
    items = Item.search_area(area_id, search_string)

    case things_to_match(items) do
      [] ->
        {:error, :no_match}

      matches ->
        {:ok, matches}
    end
  end

  @doc """
  Find matches in worn items.
  """
  @spec find_matches_in_worn_items(
          String.t(),
          String.t()
        ) ::
          {:ok, [Match.t()]} | {:error, :no_match}
  def find_matches_in_worn_items(character_id, input, mode \\ "simple") do
    search_string = input_to_wildcard_string(input, mode)
    items = Item.search_worn_items(character_id, search_string)

    case things_to_match(items) do
      [] ->
        {:error, :no_match}

      matches ->
        {:ok, matches}
    end
  end

  @doc """
  Find matches in worn items.
  """
  @spec find_matches_on_ground(
          String.t(),
          String.t()
        ) ::
          {:ok, [Match.t()]} | {:error, :no_match}
  def find_matches_on_ground(area_id, input, mode \\ "simple") do
    search_string = input_to_wildcard_string(input, mode)
    items = Item.search_on_ground(area_id, search_string)

    case things_to_match(items) do
      [] ->
        {:error, :no_match}

      matches ->
        {:ok, matches}
    end
  end

  @doc """
  Find matches in worn items.
  """
  @spec find_matches_on_ground_or_worn_items(
          String.t(),
          String.t(),
          String.t()
        ) ::
          {:ok, [Match.t()]} | {:error, :no_match}
  def find_matches_on_ground_or_worn_items(area_id, character_id, input, mode \\ "simple") do
    search_string = input_to_wildcard_string(input, mode)
    items = Item.search_on_ground_or_worn_items(area_id, character_id, search_string)

    case things_to_match(items) do
      [] ->
        {:error, :no_match}

      matches ->
        {:ok, matches}
    end
  end

  @doc """
  Find matches in held or worn items.
  """
  @spec find_matches_on_ground_or_worn_or_held_items(
          String.t(),
          String.t(),
          String.t()
        ) ::
          {:ok, [Match.t()]} | {:error, :no_match}
  def find_matches_on_ground_or_worn_or_held_items(area_id, character_id, input, mode \\ "simple") do
    search_string = input_to_wildcard_string(input, mode)
    items = Item.search_on_ground_or_worn_or_held_items(area_id, character_id, search_string)

    case things_to_match(items) do
      [] ->
        {:error, :no_match}

      matches ->
        {:ok, matches}
    end
  end

  defp unnest_place_path(place = %{path: nil}, path) do
    [place | path]
  end

  defp unnest_place_path(place = %{path: place_path}, path) do
    unnest_place_path(place_path, [%{place | path: nil} | path])
  end

  @doc """
  Find matches in items in unspecified location
  """
  @spec find_matches_relative_to_place_in_inventory(
          String.t(),
          Mud.Engine.Command.AstNode.Thing.t(),
          Mud.Engine.Command.AstNode.Place.t(),
          String.t()
        ) ::
          {:ok, [Match.t()]} | {:error, :no_match}
  def find_matches_relative_to_place_in_inventory(
        character_id,
        thing,
        place,
        mode \\ "simple"
      ) do
    path = unnest_place_path(place, [])

    items =
      Item.search_relative_to_inventory(
        character_id,
        path,
        thing,
        mode
      )

    case things_to_match(items) do
      [] ->
        {:error, :no_match}

      matches ->
        {:ok, matches}
    end
  end

  @doc """
  Find matches in items in unspecified location
  """
  @spec find_matches_relative_to_place_in_area(
          String.t(),
          Mud.Engine.Command.AstNode.Thing.t(),
          Mud.Engine.Command.AstNode.Place.t(),
          String.t()
        ) ::
          {:ok, [Match.t()]} | {:error, :no_match}
  def find_matches_relative_to_place_in_area(
        area_id,
        thing,
        place,
        mode \\ "simple"
      ) do
    path = unnest_place_path(place, [])

    items =
      Item.search_relative_to_item_in_area(
        area_id,
        path,
        thing,
        mode
      )

    case things_to_match(items) do
      [] ->
        {:error, :no_match}

      matches ->
        {:ok, matches}
    end
  end

  @spec things_to_match(any) :: [%Match{}]
  def things_to_match(things) when not is_list(things), do: things_to_match(List.wrap(things))

  def things_to_match(links = [%Link{} | _]) do
    Enum.map(links, fn link ->
      %Match{
        match_string: String.downcase(link.short_description),
        short_description: link.short_description,
        long_description: link.long_description,
        match: link
      }
    end)
  end

  def things_to_match(characters = [%Character{} | _]) do
    Enum.map(characters, fn character ->
      %Match{
        match_string: String.downcase(character.name),
        short_description: Character.short_description(character),
        long_description: Character.long_description(character),
        match: character
      }
    end)
  end

  def things_to_match(items = [%Item{} | _]) do
    Enum.map(items, fn item ->
      %Match{
        match_string: String.downcase(item.description.short),
        short_description: item.description.short,
        long_description: item.description.long,
        match: item
      }
    end)
  end

  def things_to_match([]), do: []

  @doc """
  Given an input, convert it to a wildcard string to be used in querying Postgres
  """
  def input_to_wildcard_string(input, mode \\ "simple")

  def input_to_wildcard_string(input, "advanced") do
    input
    |> String.graphemes()
    |> Stream.map(&"%#{&1}%")
    |> Enum.join()
  end

  def input_to_wildcard_string(input, "simple") do
    input
    |> String.split()
    |> Stream.map(&"%#{&1}%")
    |> Enum.join()
  end
end
