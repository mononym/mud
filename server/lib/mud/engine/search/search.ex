defmodule Mud.Engine.Search do
  @moduledoc """
  Utilities to help with searching during autocomplete.
  """

  alias Mud.Engine.{Character, Item, Link, ItemSearch}
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
  Find matches in held items only.
  """
  @spec find_matches_in_held_items(
          String.t(),
          String.t()
        ) ::
          {:ok, [Match.t()]} | {:error, :no_match}
  def find_matches_in_held_items(character_id, input, mode \\ "simple") do
    search_string = input_to_wildcard_string(input, mode)
    items = Item.search_held(character_id, search_string)

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
    items = ItemSearch.search_inventory(character_id, search_string)

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
  @spec find_matching_containers_in_inventory(
          String.t(),
          String.t()
        ) ::
          {:ok, [Match.t()]} | {:error, :no_match}
  def find_matching_containers_in_inventory(character_id, input, mode \\ "simple") do
    search_string = input_to_wildcard_string(input, mode)
    items = Item.search_inventory_for_containers(character_id, search_string)

    case things_to_match(items) do
      [] ->
        {:error, :no_match}

      matches ->
        {:ok, matches}
    end
  end

  @doc """
  Find matches in inventory not at the root level.

  So it won't find the backpack on your back, but it will find the sack in the backpack.
  """
  @spec find_matches_inside_inventory(
          String.t(),
          String.t()
        ) ::
          {:ok, [Match.t()]} | {:error, :no_match}
  def find_matches_inside_inventory(character_id, input, mode \\ "simple") do
    search_string = input_to_wildcard_string(input, mode)
    items = Item.search_inside_inventory(character_id, search_string)

    case things_to_match(items) do
      [] ->
        {:error, :no_match}

      matches ->
        {:ok, matches}
    end
  end

  @spec find_furniture_in_area(String.t(), String.t(), String.t()) ::
          {:error, :no_match} | {:ok, [Mud.Engine.Search.Match.t(), ...]}
  @doc """
  Find furniture in an area.
  """
  @spec find_furniture_in_area(
          String.t(),
          String.t()
        ) ::
          {:ok, [Match.t()]} | {:error, :no_match}
  def find_furniture_in_area(area_id, input, mode \\ "simple") do
    search_string = input_to_wildcard_string(input, mode)
    items = Item.search_furniture_in_area(area_id, search_string)

    case things_to_match(items) do
      [] ->
        {:error, :no_match}

      matches ->
        {:ok, matches}
    end
  end

  @spec find_exits_in_area(String.t(), String.t(), String.t()) ::
          {:error, :no_match} | {:ok, [Mud.Engine.Search.Match.t(), ...]}
  @doc """
  Find exits from an area.
  """
  @spec find_exits_in_area(
          String.t(),
          String.t()
        ) ::
          {:ok, [Match.t()]} | {:error, :no_match}
  def find_exits_in_area(area_id, input, mode \\ "simple") do
    search_string = input_to_wildcard_string(input, mode)
    links = Link.search_exits(area_id, search_string)

    links =
      case Enum.find(links, &(&1.short_description === input)) do
        nil ->
          links

        link ->
          [link]
      end

    case things_to_match(links) do
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
  Find matches that are on a surface which are visible from the perspective of an Area.

  Visible matches are item on the ground, or on surfaces all the way down to the item
  """
  @spec find_matches_on_visible_surfaces(
          String.t(),
          String.t()
        ) ::
          {:ok, [Match.t()]} | {:error, :no_match}
  def find_matches_on_visible_surfaces(area_id, input, mode \\ "simple") do
    search_string = input_to_wildcard_string(input, mode)
    items = ItemSearch.search_on_visible_surfaces_in_area(area_id, search_string)

    case things_to_match(items) do
      [] ->
        {:error, :no_match}

      matches ->
        {:ok, matches}
    end
  end

  @doc """
  Find matches on the ground of an area
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
  Find matches either on the ground or in worn items.
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

  @spec find_matches_on_ground_or_worn_or_held_items(binary, binary, binary, <<_::48, _::_*16>>) ::
          {:error, :no_match} | {:ok, [Mud.Engine.Search.Match.t(), ...]}
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
  @spec find_matches_relative_to_place_in_hands(
          String.t(),
          Mud.Engine.Command.AstNode.Thing.t(),
          Mud.Engine.Command.AstNode.Place.t(),
          String.t()
        ) ::
          {:ok, [Match.t()]} | {:error, :no_match}
  def find_matches_relative_to_place_in_hands(
        character_id,
        thing,
        place,
        mode \\ "simple"
      ) do
    path = unnest_place_path(place, [])

    # Either the last thing is set to be an override to where this specific item is to be placed, or it is just the place to go
    # for now strip and ignore any override, and just focus on getting stow to work and then come back later and work in the override for that item
    path =
      if length(path) >= 2 and Enum.at(path, 1).where == "in" do
        [_ | path] = path

        path
      else
        path
      end

    items =
      Item.search_relative_to_hands(
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
        mode,
        thing_is_immediate_child \\ true
      ) do
    # IO.inspect(thing, label: :find_matches_relative_to_place_in_inventory_thing)
    # IO.inspect(place, label: :find_matches_relative_to_place_in_inventory_place)
    path = unnest_place_path(place, [])
    # IO.inspect(path, label: :find_matches_relative_to_place_in_inventory_path)

    # Either the last thing is set to be an override to where this specific item is to be placed, or it is just the place to go
    # for now strip and ignore any override, and just focus on getting stow to work and then come back later and work in the override for that item

    items =
      Item.search_relative_to_inventory(
        character_id,
        path,
        thing,
        mode,
        thing_is_immediate_child
      )

    # IO.inspect(items, label: :find_matches_relative_to_place_in_inventory_items)

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
          String.t(),
          boolean()
        ) ::
          {:ok, [Match.t()]} | {:error, :no_match}
  def find_matches_relative_to_place_in_area(
        area_id,
        thing,
        place,
        mode \\ "simple",
        thing_is_immediate_child \\ true
      ) do
    # IO.inspect(thing, label: :find_matches_relative_to_place_in_area_thing)
    # IO.inspect(place, label: :find_matches_relative_to_place_in_area_place)
    path = unnest_place_path(place, [])
    # IO.inspect(path, label: :find_matches_relative_to_place_in_area_path)

    # Either the last thing is set to be an override to where this specific item is to be placed, or it is just the place to go
    # for now strip and ignore any override, and just focus on getting stow to work and then come back later and work in the override for that item
    # path =
    #   if length(path) >= 2 and Enum.at(path, 1).where == "in" do
    #     [_ | path] = path

    #     path
    #   else
    #     path
    #   end

    items =
      Item.search_relative_to_item_in_area(
        area_id,
        path,
        thing,
        mode,
        thing_is_immediate_child
      )

    # IO.inspect(items, label: :find_matches_relative_to_place_in_inventory_items)

    case things_to_match(items) do
      [] ->
        {:error, :no_match}

      matches ->
        {:ok, matches}
    end
  end

  @spec things_to_match(any) :: [%Match{}]
  def things_to_match(things) when not is_list(things),
    do: things_to_match(List.wrap(things))

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
