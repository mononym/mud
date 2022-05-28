defmodule Mud.Engine.Item do
  @moduledoc """
  An Item is the building block of almost everything in the world.

  Containers, swords, coins, gems, scarves, furniture, houses (the outsides anyway), and more are all Items.
  """
  use Mud.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Mud.Repo
  alias Mud.Engine.{Area, Character}

  alias Mud.Engine.Item.{
    Closable,
    Coin,
    Description,
    Flags,
    Furniture,
    Gem,
    Location,
    Lockable,
    Physics,
    Pocket,
    Surface,
    Wearable
  }

  require Logger

  @type id :: String.t()

  @derive Jason.Encoder
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "items" do
    has_one(:closable, Closable)
    has_one(:coin, Coin)
    has_one(:description, Description)
    has_one(:flags, Flags)
    has_one(:furniture, Furniture)
    has_one(:gem, Gem)
    has_one(:location, Location)
    has_one(:lockable, Lockable)
    has_one(:physics, Physics)
    has_one(:pocket, Pocket)
    has_one(:surface, Surface)
    has_one(:wearable, Wearable)

    timestamps()
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> change()
    |> cast(attrs, [])
  end

  @topic inspect(__MODULE__)

  @doc """
  Subscribe to the PubSub topic for all Character events.
  """
  @spec subscribe :: {:ok, :subscribed}
  def subscribe do
    :ok = Phoenix.PubSub.subscribe(Mud.PubSub, @topic)
    {:ok, :subscribed}
  end

  @doc """
  Subscribe to the PubSub topic for all Character events related to a single Character.
  """
  @spec subscribe(String.t()) :: {:ok, :subscribed}
  def subscribe(item_id) when is_binary(item_id) do
    :ok = Phoenix.PubSub.subscribe(Mud.PubSub, @topic <> ":#{item_id}")
    {:ok, :subscribed}
  end

  def create_from_template_for_area(template, args, area_id) do
    create(Mud.Engine.ItemTemplate.build_template_for_area(template, args, area_id))
  end

  def create(attrs \\ %{}) do
    Logger.debug("Creating item with attrs: #{inspect(attrs)}")

    normalized_attrs = normalize_attrs(attrs)

    Logger.debug("Normalized attrs: #{inspect(normalized_attrs)}")

    Repo.transaction(fn ->
      insert_new()
      |> setup_required_component(normalized_attrs, :flags, Flags)
      |> setup_required_component(normalized_attrs, :location, Location)
      |> maybe_setup_optional_component(normalized_attrs, :closable, Closable)
      |> maybe_setup_optional_component(normalized_attrs, :coin, Coin)
      |> maybe_setup_optional_component(normalized_attrs, :furniture, Furniture)
      |> maybe_setup_optional_component(normalized_attrs, :gem, Gem)
      |> maybe_setup_optional_component(normalized_attrs, :lockable, Lockable)
      |> maybe_setup_optional_component(normalized_attrs, :physics, Physics)
      |> maybe_setup_optional_component(normalized_attrs, :pocket, Pocket)
      |> maybe_setup_optional_component(normalized_attrs, :surface, Surface)
      |> maybe_setup_optional_component(normalized_attrs, :wearable, Wearable)
      # Description should be very last since it might actually build up a description based on everything else having been filled in
      |> maybe_setup_optional_component(normalized_attrs, :description, Description)
      |> preload()
    end)
  end

  defp template_keys_to_atoms(template) do
    Map.new(template, fn {k, v} ->
      {if is_binary(k) do
         String.to_atom(k)
       else
         k
       end,
       if is_binary(v) do
         v
       else
         Map.new(v, fn {key, val} ->
           {if is_binary(key) do
              String.to_atom(key)
            else
              key
            end, val}
         end)
       end}
    end)
  end

  # given a set of attributes, go through the flags and then strip away any components which do not match the set flags
  # this is to facilitate templates
  defp normalize_attrs(attrs) do
    attrs = template_keys_to_atoms(attrs)

    keys_map = %{
      is_closable: [:closable],
      is_coin: [:coin],
      is_furniture: [:furniture],
      is_material: [],
      is_scenery: [],
      is_gem: [:gem],
      is_lockable: [:lockable],
      is_wearable: [:wearable],
      has_surface: [:surface],
      is_equipment: [:equipment],
      has_pocket: [:pocket],
      has_physics: [:physics]
    }

    base_keys_to_keep = [:description, :location, :flags]

    final_keys_to_keep =
      Enum.reduce(keys_map, base_keys_to_keep, fn {key, ktk}, keys_tk ->
        Logger.debug("Checking key: #{inspect(key)}")

        if Map.has_key?(attrs[:flags], key) and attrs[:flags][key] do
          ktk ++ keys_tk
        else
          keys_tk
        end
      end)

    Logger.debug("Keeping keys: #{inspect(final_keys_to_keep)}")

    purged_attrs =
      Enum.reduce(Map.keys(attrs), attrs, fn key, attr ->
        if key in final_keys_to_keep do
          attr
        else
          Map.delete(attr, key)
        end
      end)

    Logger.debug("Attributes after purge: #{inspect(purged_attrs)}")

    # Make sure the item is described
    cond do
      Map.has_key?(purged_attrs[:flags], :coin) and purged_attrs[:flags][:coin] ->
        Map.put(purged_attrs, :description, %{
          short: "some coins",
          details: "some coins",
          key: if(purged_attrs.coin.count > 1, do: "coins", else: "coin")
        })

      true ->
        purged_attrs
    end
  end

  defp setup_required_component(item, attrs, key, callback) do
    thing = callback.create(Map.put(Map.get(attrs, key, %{}), :item_id, item.id))

    %{item | key => thing}
  end

  defp maybe_setup_optional_component(item, attrs, :description, Description) do
    if item.flags.is_gem do
      short = Gem.generate_short_description(item.gem)
      desc = Map.get(attrs, :description, %{})

      description =
        desc
        |> Map.put(:item_id, item.id)
        |> Map.put(:short, short)
        |> Map.put(:long, short)
        |> Map.put(:key, attrs.gem.type)
        |> Description.create()

      %{item | :description => description}
    else
      if Map.has_key?(attrs, :description) do
        thing = Description.create(Map.put(Map.get(attrs, :description, %{}), :item_id, item.id))
        %{item | :description => thing}
      else
        item
      end
    end
  end

  defp maybe_setup_optional_component(item, attrs, key, callback) do
    if Map.has_key?(attrs, key) do
      thing = callback.create(Map.put(Map.get(attrs, key, %{}), :item_id, item.id))
      %{item | key => thing}
    else
      item
    end
  end

  def update!(item_id, attrs) when is_binary(item_id) do
    keywords =
      attrs
      |> Keyword.new()
      |> Keyword.put_new(:updated_at, Timex.now())

    item =
      from(item in __MODULE__, where: item.id == ^item_id, select: item)
      |> Repo.update_all(set: keywords)
      |> elem(1)
      |> List.first()
      |> Repo.preload([:flags])

    update_item_components(attrs, item.flags)

    preload(item)
  end

  def update!(item, attrs) do
    item =
      item
      |> Repo.preload([:flags])

    update_item_components(attrs, item.flags)

    item
    |> changeset(attrs)
    |> Repo.update!()
    |> preload()
  end

  def update(item, attrs) do
    result =
      item
      |> changeset(attrs)
      |> Repo.update()

    case result do
      {:ok, item} ->
        item =
          item
          |> Repo.preload([:flags])

        update_item_components(attrs, item.flags)
        {:ok, preload(item)}

      error ->
        error
    end
  end

  @spec list(ids :: [binary]) :: [%__MODULE__{}]
  def list(ids) do
    ids = List.wrap(ids)

    from([item] in base_query_without_preload(),
      where: item.id in ^ids
    )
    |> Repo.all()
    |> preload()
  end

  @spec get!(id :: binary) :: %__MODULE__{}
  def get!(id) when is_binary(id) do
    from([item] in base_query_without_preload(),
      where: item.id == ^id
    )
    |> Repo.one!()
    |> preload()
  end

  @spec get(id :: binary) :: {:ok, %__MODULE__{}} | {:error, :not_found}
  def get(id) when is_binary(id) do
    from([item] in base_query_without_preload(),
      where: item.id == ^id
    )
    |> Repo.one()
    |> case do
      nil ->
        {:error, :not_found}

      item ->
        {:ok, item |> preload()}
    end
  end

  def get_item_in_hand_as_list(character_id, hand) do
    from(
      [item, location: location] in base_query_without_preload(),
      where:
        location.hand == ^hand and
          item.id in subquery(base_query_for_held_item_ids(character_id))
    )
    |> Repo.all()
    |> preload()
  end

  def list_items_in_hands(character_id) do
    from(
      item in base_query_without_preload(),
      where: item.id in subquery(base_query_for_held_item_ids(character_id))
    )
    |> Repo.all()
    |> preload()
  end

  @doc """
  Deletes an item.

  ## Examples

      iex> delete(item)
      {:ok, %__MODULE__{}}

      iex> delete(item)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete(item :: %__MODULE__{}) :: {:ok, %__MODULE__{}} | {:error, %Ecto.Changeset{}}
  def delete(item) do
    Repo.delete(item)
  end

  @doc """
  Given one or more items, return thier immediate children
  """
  @spec list_immediate_children(
          %__MODULE__{} | [%__MODULE__{}] | String.t() | [String.t()],
          boolean()
        ) ::
          [
            %__MODULE__{}
          ]
  def list_immediate_children(items, include_items \\ false)

  def list_immediate_children([], _) do
    []
  end

  def list_immediate_children(items, include_items) do
    results =
      items
      |> items_to_ids()
      |> list_all_immediate_children_query()
      |> Repo.all()

    if include_items do
      Enum.concat([items, results])
    else
      results
    end
    |> preload()
  end

  def list_immediate_children_with_relationship(items, relationship)

  def list_immediate_children_with_relationship([], _relationship) do
    []
  end

  def list_immediate_children_with_relationship(items, relationship) do
    items
    |> items_to_ids()
    |> list_all_immediate_children_with_relationship_query(relationship)
    |> Repo.all()
    |> preload()
  end

  @doc """
  Given one or more items, return all of their children and optionally them
  """
  @spec list_all_recursive_children(
          %__MODULE__{} | [%__MODULE__{}] | String.t() | [String.t()],
          boolean()
        ) ::
          [
            %__MODULE__{}
          ]
  def list_all_recursive_children(items, include_items \\ false)

  def list_all_recursive_children([], _) do
    []
  end

  def list_all_recursive_children(items, include_items) do
    items
    |> items_to_ids()
    |> list_all_recursive_child_query(include_items)
    |> Repo.all()
    |> preload()
  end

  @doc """
  Given one or more items, return them and all of their parents.
  """
  @spec list_all_recursive_parents(%__MODULE__{} | [%__MODULE__{}] | String.t() | [String.t()]) ::
          [
            %__MODULE__{}
          ]
  def list_all_recursive_parents([]) do
    []
  end

  def list_all_recursive_parents(items) do
    items
    |> items_to_ids()
    |> list_all_recursive_parent_query(true)
    |> Repo.all()
    |> preload()
  end

  def list_all_parents(items) do
    ids = items_to_ids(items)

    Repo.all(list_all_recursive_parent_query(ids, true))
    |> preload()
  end

  @doc """
  List all items on the ground. Does not include scenery
  """
  @spec list_on_ground(id) :: [%__MODULE__{}]
  def list_on_ground(area_id) do
    from([location: location] in items_on_ground_query(area_id),
      order_by: [desc: location.moved_at]
    )
    |> Repo.all()
    |> preload()
  end

  @doc """
  List all items in an Area, those on the ground and scenery included.
  """
  @spec list_in_area(id) :: [%__MODULE__{}]
  def list_in_area(area_id) do
    from([location: location] in all_in_area_query(area_id),
      order_by: [desc: location.moved_at]
    )
    |> Repo.all()
    |> preload()
  end

  @doc """
  List all items in an Area, those on the ground and scenery included.
  """
  @spec list_in_area_and_all_nested(id) :: [%__MODULE__{}]
  def list_in_area_and_all_nested(area_id) do
    area_id
    |> all_in_area_query()
    |> modify_query_select_id()
    |> list_all_recursive_child_query(true)
    |> Repo.all()
    |> preload()
  end

  @spec list_items_in_area_and_nested_visible_items(id) :: [%__MODULE__{}]
  def list_items_in_area_and_nested_visible_items(area_id) do
    everything_and_nested_items =
      everything_and_nested_items_in_area_query(area_id)
      |> Repo.all()
      |> preload()

    # go through items and build up parent/child index
    item_index = build_item_index(everything_and_nested_items)
    # maps item id to the id of the parent
    parent_index = build_parent_index(everything_and_nested_items)

    Enum.filter(everything_and_nested_items, fn item ->
      is_visible_item(item, item_index, parent_index)
    end)
  end

  @spec list_scenery_in_area_and_nested_visible_items(id) :: [%__MODULE__{}]
  def list_scenery_in_area_and_nested_visible_items(area_id) do
    scenery_and_nested_items =
      scenery_and_nested_items_in_area_query(area_id)
      |> Repo.all()
      |> preload()

    # go through items and build up parent/child index
    item_index = build_item_index(scenery_and_nested_items)
    # maps item id to the id of the parent
    parent_index = build_parent_index(scenery_and_nested_items)

    Enum.filter(scenery_and_nested_items, fn item ->
      is_visible_item(item, item_index, parent_index)
    end)
  end

  defp is_visible_item(
         _item = %{flags: %{hidden: false}, location: %{on_ground: true}},
         _item_index,
         _parent_index
       ) do
    true
  end

  defp is_visible_item(
         _item = %{location: %{relative_to_item: true, relation: "on", item_id: parent}},
         item_index,
         parent_index
       ) do
    if item_index[parent_index[parent]].flags.has_surface do
      is_visible_item(item_index[parent_index[parent]], item_index, parent_index)
    else
      false
    end
  end

  defp is_visible_item(_, _, _) do
    false
  end

  @spec list_scenery_in_area(id) :: [%__MODULE__{}]
  def list_scenery_in_area(area_id) do
    scenery_in_area_query(area_id)
    |> Repo.all()
    |> preload()
  end

  @spec list_held_or_worn_items_and_children(String.t()) :: [%__MODULE__{}]
  def list_held_or_worn_items_and_children(character_id) do
    character_id
    |> held_or_worn_and_children_query()
    |> order_by([location: location], location.moved_at)
    |> Repo.all()
    |> preload()
  end

  @doc """
  Turn a list of items strings like: [{item, "a wooden spoon on a ovaled silver plate on a tall wooden counter"}, {item2, "a silver fork on the ground"}]
  """
  def items_to_short_desc_with_nested_location_with_item(items) do
    items = List.wrap(items)
    parents = list_all_parents(items)
    parent_index = build_item_index(parents)

    Enum.map(items, fn item ->
      {item, build_parent_string(item, parent_index)}
    end)
  end

  @doc """
  Turn a list of items strings like: [{item, "a wooden spoon on a ovaled silver plate on a tall wooden counter"}, {item2, "a silver fork on the ground"}]
  """
  def list_full_path(item) do
    wrapped_item = List.wrap(item)
    parents = list_all_parents(wrapped_item)
    parent_index = build_item_index(parents)

    build_parent_list(item, parent_index, [])
  end

  defp build_parent_list(item, parent_index, parents) do
    cond do
      item.location.relative_to_item ->
        build_parent_list(parent_index[item.location.relative_item_id], parent_index, [
          item | parents
        ])

      true ->
        [item | parents]
    end
  end

  @doc """
  Turn a list of items strings like: [{item, "a wooden spoon on a ovaled silver plate on a tall wooden counter"}, {item2, "a silver fork on the ground"}]
  """
  def items_to_short_desc_with_nested_location_without_item(items) do
    items = List.wrap(items)
    parents = list_all_parents(items)
    parent_index = build_item_index(parents)

    Enum.map(items, fn item ->
      build_parent_string(item, parent_index)
    end)
  end

  defp build_parent_string(item, parent_index) do
    cond do
      item.location.relative_to_item ->
        "#{item.description.short} from #{build_parent_string(parent_index[item.location.relative_item_id], parent_index)}"

      item.flags.is_scenery ->
        item.description.short

      item.location.on_ground ->
        "#{item.description.short} on the ground"

      item.location.worn_on_character ->
        "#{item.description.short} which you are wearing"

      item.location.held_in_hand ->
        "#{item.description.short} which you are holding"
    end
  end

  def list_worn_gem_pouches(character_id) do
    from(
      [description: description, location: location, flags: flags] in base_query_for_description_and_location_and_flags(),
      where:
        location.character_id == ^character_id and location.worn_on_character and
          flags.has_pocket == true and flags.is_wearable and flags.is_gem_pouch,
      order_by: [desc: location.moved_at]
    )
    |> Repo.all()
    |> preload()
  end

  def list_worn_containers(character_id) do
    from(
      [description: description, location: location, flags: flags] in base_query_for_description_and_location_and_flags(),
      where:
        location.character_id == ^character_id and location.worn_on_character and
          flags.has_pocket == true and flags.is_wearable,
      order_by: [desc: location.moved_at]
    )
    |> Repo.all()
    |> preload()
  end

  @doc """
  Given an item, determines if any of the parents are held/worn by a character
  """
  def in_inventory?(item = %__MODULE__{}, character) do
    in_inventory?(item.id, character)
  end

  def in_inventory?(item, character = %Character{}) do
    in_inventory?(item, character.id)
  end

  def in_inventory?(item_id, character_id) do
    res =
      Repo.one(
        from([location: location] in base_query_without_preload(),
          where:
            location.item_id in subquery(recursive_parent_ids_query([item_id], true)) and
              (location.held_in_hand or location.worn_on_character) and
              location.character_id == ^character_id
        )
      )

    res != nil
  end

  @doc """
  Given an item, determines if any of the parents are held/worn by a character
  """
  def in_area?(item = %__MODULE__{}, area) do
    in_area?(item.id, area)
  end

  def in_area?(item, area = %Area{}) do
    in_area?(item, area.id)
  end

  def in_area?(item_id, area_id) do
    res =
      Repo.one(
        from([flags: flags, location: location] in base_query_without_preload(),
          where:
            location.item_id in subquery(recursive_parent_ids_query([item_id], true)) and
              location.on_ground and location.area_id == ^area_id,
          select: count(location.id)
        )
      )

    res != 0
  end

  @doc """
  Checks all parents up to the root to ensure that they are open if they are containers.

  If the item is a root item itself, being held in the hand or worn or on the ground, `true` is returned.
  """
  def parent_containers_open?(%{
        location: %{
          on_ground: on_ground,
          held_in_hand: held_in_hand,
          worn_on_character: worn_on_character
        }
      })
      when on_ground or held_in_hand or worn_on_character do
    true
  end

  def parent_containers_open?(item = %__MODULE__{}) do
    from(closable in Closable,
      where: closable.item_id in subquery(recursive_parent_ids_query(List.wrap(item.id))),
      select: fragment("bool_and(?)", closable.open)
    )
    |> Repo.one!()
  end

  def list_closed_parent_containers(item = %__MODULE__{}) do
    sorted_parents = list_sorted_parent_containers(item)

    Enum.filter(sorted_parents, &(not &1.closable.open))
  end

  def list_sorted_parent_containers(item = %__MODULE__{}) do
    parents =
      from([flags: flags] in base_query_without_preload(),
        where:
          flags.item_id in subquery(recursive_parent_ids_query(List.wrap(item.id))) and
            flags.has_pocket
      )
      |> Repo.all()
      |> preload()

    item_index = build_item_index(parents)
    parent_index = build_parent_index(parents)

    layers =
      Enum.reduce(parents, %{}, fn it, layer_index ->
        Map.put(layer_index, it.id, count_layers(it, parent_index, item_index, 0))
      end)

    Enum.sort(parents, fn item1, item2 ->
      layers[item1.id] >= layers[item2.id]
    end)
  end

  defp count_layers(nil, _parent_index, _item_index, layer) do
    layer
  end

  defp count_layers(it, parent_index, item_index, layer) do
    if it.location.on_ground or it.location.held_in_hand or it.location.worn_on_character do
      layer
    else
      count_layers(
        item_index[parent_index[it.location.area_id]],
        parent_index,
        item_index,
        layer + 1
      )
    end
  end

  def list_worn_by(character_id) do
    from(
      item in __MODULE__,
      join: location in Location,
      on: location.item_id == item.id,
      where: item.wearable_worn_by_id == ^character_id,
      order_by: location.moved_at
    )
    |> Repo.all()
    |> preload()
  end

  def list_held_by(character_id) do
    base_query_for_held_items(character_id)
    |> Repo.all()
    |> preload()
  end

  defp held_or_worn_and_children_query(character_id) do
    item_tree_initial_query =
      Location
      |> where(
        [l],
        l.character_id == ^character_id and (l.held_in_hand or l.worn_on_character)
      )

    item_tree_recursion_query =
      Location
      |> join(
        :inner,
        [location],
        lt in "location_tree",
        on:
          location.relative_item_id == lt.item_id and location.relative_to_item and
            location.relation == ^"in"
      )

    item_tree_query =
      item_tree_initial_query
      |> union_all(^item_tree_recursion_query)

    all_item_ids =
      {"location_tree", Location}
      |> recursive_ctes(true)
      |> with_cte("location_tree", as: ^item_tree_query)
      |> select([l], l.item_id)

    from(item in base_query_without_preload(), where: item.id in subquery(all_item_ids))
  end

  def build_from_template_and_place_in_character_hand(template, character_id, hand) do
    location_props = %{held_in_hand: true, character_id: character_id, hand: hand}

    template
    |> Map.delete("location")
    |> Map.put(:location, location_props)
    |> create()
  end

  #
  #
  # Helper functions
  #
  #

  def base_query_for_description_and_location_and_flags() do
    from(
      item in __MODULE__,
      left_join: location in assoc(item, :location),
      as: :location,
      left_join: description in assoc(item, :description),
      as: :description,
      left_join: flags in assoc(item, :flags),
      as: :flags
    )
  end

  def base_query_for_description_and_location() do
    from(
      item in __MODULE__,
      left_join: location in assoc(item, :location),
      as: :location,
      left_join: description in assoc(item, :description),
      as: :description
    )
  end

  def base_query_without_preload() do
    from(
      item in __MODULE__,
      left_join: coin in assoc(item, :coin),
      as: :coin,
      left_join: description in assoc(item, :description),
      as: :description,
      left_join: flags in assoc(item, :flags),
      as: :flags,
      left_join: furniture in assoc(item, :furniture),
      as: :furniture,
      left_join: gem in assoc(item, :gem),
      as: :gem,
      left_join: location in assoc(item, :location),
      as: :location,
      left_join: physics in assoc(item, :physics),
      as: :physics,
      left_join: surface in assoc(item, :surface),
      as: :surface,
      left_join: wearable in assoc(item, :wearable),
      as: :wearable
    )
  end

  defp items_on_ground_query(area_id) do
    from(
      [item, location: location, flags: flags] in base_query_without_preload(),
      where: location.on_ground == true and location.area_id == ^area_id and not flags.is_scenery,
      order_by: [desc: location.moved_at]
    )
  end

  defp scenery_in_area_query(area_id) do
    from(
      item in __MODULE__,
      left_join: location in assoc(item, :location),
      as: :location,
      left_join: flags in assoc(item, :flags),
      as: :flags,
      where: location.area_id == ^area_id and flags.is_scenery,
      order_by: [desc: location.moved_at]
    )
  end

  @spec everything_and_nested_items_in_area_query(any) :: Ecto.Query.t()
  def everything_and_nested_items_in_area_query(area_id) do
    area_item_id_query = base_query_for_root_area_item_ids(area_id)

    from([item, location: location] in base_query_without_preload(),
      where: item.id in subquery(recursive_child_ids_query(area_item_id_query, true)),
      order_by: [desc: location.moved_at]
    )
  end

  def scenery_and_nested_items_in_area_query(area_id) do
    scenery_id_query = base_query_for_root_scenery_item_ids(area_id)

    from([item, location: location] in base_query_without_preload(),
      where: item.id in subquery(recursive_child_ids_query(scenery_id_query, true)),
      order_by: [desc: location.moved_at]
    )
  end

  defp all_in_area_query(area_id) do
    from(
      [location: location] in base_query_without_preload(),
      where: location.area_id == ^area_id
    )
  end

  defp insert_new() do
    Repo.insert!(%__MODULE__{})
  end

  def list_all_immediate_children_query(ids) do
    from([item, location: location] in base_query_without_preload(),
      where: item.id in subquery(child_ids_query(ids)),
      order_by: [desc: location.moved_at]
    )
  end

  def list_all_immediate_children_with_relationship_query(ids, relationship) do
    from([item, location: location] in base_query_without_preload(),
      where: item.id in subquery(child_ids_query(ids)) and location.relation == ^relationship,
      order_by: [desc: location.moved_at]
    )
  end

  def list_all_recursive_child_query(ids, include_self \\ false) do
    from(item in base_query_without_preload(),
      where: item.id in subquery(recursive_child_ids_query(ids, include_self))
    )
  end

  def recursive_child_ids_query(ids, include_self \\ false) do
    from(location in recursive_child_query(ids, include_self), select: location.item_id)
  end

  def list_all_recursive_parent_query(ids, include_self \\ false) do
    from(item in base_query_without_preload(),
      where: item.id in subquery(recursive_parent_ids_query(ids, include_self))
    )
  end

  def recursive_parent_ids_query(ids, include_self \\ false) do
    from(location in recursive_parent_query(ids, include_self), select: location.item_id)
  end

  def child_ids_query(ids) do
    from([location: location] in child_query(ids), select: location.item_id)
  end

  def child_query(ids) do
    if is_list(ids) do
      from(
        [location: location] in base_query_without_preload(),
        where: location.relative_to_item and location.relative_item_id in ^ids
      )
    else
      from(
        [location: location] in base_query_without_preload(),
        where: location.relative_to_item and location.relative_item_id in subquery(ids)
      )
    end
  end

  def specific_nested_item_area_initial_query(
        area_id,
        search_string
      ) do
    from(
      [description: description, location: location] in base_query_without_preload(),
      where:
        description.item_id in subquery(base_query_for_all_area_item_ids(area_id)) and
          like(description.short, ^search_string),
      select: description.item_id
    )
  end

  def specific_nested_item_inventory_initial_query(
        character_id,
        search_string
      ) do
    from(
      [description: description, location: location] in base_query_without_preload(),
      where:
        description.item_id in subquery(base_query_for_all_inventory_ids(character_id)) and
          like(description.short, ^search_string),
      select: description.item_id
    )
  end

  def specific_nested_item_in_hands_initial_query(
        character_id,
        search_string
      ) do
    from(
      [description: description, location: location] in base_query_without_preload(),
      where:
        description.item_id in subquery(base_query_for_held_item_ids(character_id)) and
          like(description.short, ^search_string),
      select: description.item_id
    )
  end

  def specific_nested_item_mid_level_query(
        previous_query,
        search_string
      ) do
    from(
      [description: description, location: location] in base_query_without_preload(),
      where:
        location.relative_to_item and
          location.item_id in subquery(recursive_child_ids_query(previous_query, true)) and
          like(description.short, ^search_string),
      select: description.item_id
    )
  end

  def specific_nested_item_top_level_query(
        previous_query,
        search_string,
        thing_is_immediate_child \\ true
      ) do
    query =
      if thing_is_immediate_child do
        child_ids_query(previous_query)
      else
        recursive_child_ids_query(previous_query)
      end

    from(
      [description: description, location: location] in base_query_without_preload(),
      where:
        location.relative_to_item and
          location.item_id in subquery(query) and
          like(description.short, ^search_string)
    )
  end

  def recursive_parent_query(maybe_subqry, include_self) do
    item_tree_initial_query =
      if is_list(maybe_subqry) do
        Location
        |> where(
          [l],
          l.item_id in ^maybe_subqry
        )
      else
        Location
        |> where(
          [l],
          l.item_id in subquery(maybe_subqry)
        )
      end

    item_tree_recursion_query =
      Location
      |> join(
        :inner,
        [location],
        lt in "location_tree",
        on: lt.relative_item_id == location.item_id
      )

    item_tree_query =
      item_tree_initial_query
      |> union_all(^item_tree_recursion_query)

    final_query =
      {"location_tree", Location}
      |> recursive_ctes(true)
      |> with_cte("location_tree", as: ^item_tree_query)

    if include_self do
      final_query
    else
      if is_list(maybe_subqry) do
        from(item in final_query, where: item.item_id not in ^maybe_subqry)
      else
        from(item in final_query, where: item.item_id not in subquery(maybe_subqry))
      end
    end
  end

  def list_all_recursive_surface_children(items) do
    ids = items_to_ids(items)

    from(item in base_query_without_preload(),
      where: item.id in subquery(recursive_surface_child_ids_query(ids))
    )
    |> Repo.all()
    |> preload()
  end

  defp recursive_surface_child_ids_query(ids) do
    from(location in recursive_surface_child_query(ids), select: location.item_id)
  end

  defp recursive_surface_child_query(maybe_subqry) do
    item_tree_initial_query =
      if is_list(maybe_subqry) do
        Location
        |> where(
          [l],
          l.item_id in ^maybe_subqry
        )
      else
        Location
        |> where(
          [l],
          l.item_id in subquery(maybe_subqry)
        )
      end

    item_tree_recursion_query =
      Location
      |> join(
        :inner,
        [location],
        lt in "location_tree",
        on: location.relative_item_id == lt.item_id and location.relation == "on"
      )

    item_tree_query =
      item_tree_initial_query
      |> union_all(^item_tree_recursion_query)

    {"location_tree", Location}
    |> recursive_ctes(true)
    |> with_cte("location_tree", as: ^item_tree_query)
  end

  defp recursive_child_query(maybe_subqry, _include_self) do
    item_tree_initial_query =
      if is_list(maybe_subqry) do
        Location
        |> where(
          [l],
          l.item_id in ^maybe_subqry
        )
      else
        Location
        |> where(
          [l],
          l.item_id in subquery(maybe_subqry)
        )
      end

    item_tree_recursion_query =
      Location
      |> join(
        :inner,
        [location],
        lt in "location_tree",
        on: location.relative_item_id == lt.item_id
      )

    item_tree_query =
      item_tree_initial_query
      |> union_all(^item_tree_recursion_query)

    final_query =
      {"location_tree", Location}
      |> recursive_ctes(true)
      |> with_cte("location_tree", as: ^item_tree_query)

    # if include_self do
    final_query
    # else
    #   if is_list(maybe_subqry) do
    #     from(item in final_query, where: item.item_id not in ^maybe_subqry)
    #   else
    #     from(item in final_query, where: item.item_id not in subquery(maybe_subqry))
    #   end
    # end
  end

  defp modify_query_select_id(query) do
    from(item in query, select: item.id)
  end

  defp modify_query_select_item_id(query) do
    from(location in query, select: location.item_id)
  end

  def base_query_for_all_inventory_ids(character_id) do
    base_query_for_all_inventory(character_id)
    |> modify_query_select_item_id()
  end

  def base_query_for_all_area_item_ids(area_id) do
    base_query_for_all_area_items(area_id)
    |> modify_query_select_item_id()
  end

  def base_query_for_all_scenery_and_nested_items(area_id) do
    recursive_child_query(base_query_for_root_area_item_ids(area_id), true)
  end

  def base_query_for_all_area_items(area_id) do
    recursive_child_query(base_query_for_root_area_item_ids(area_id), true)
  end

  @spec base_query_for_all_inventory(any) :: Ecto.Query.t()
  def base_query_for_all_inventory(character_id) do
    recursive_child_query(base_query_for_worn_and_held_inventory_ids(character_id), true)
  end

  def base_query_for_root_scenery_item_ids(area_id) do
    base_query_for_scenery_area_items(area_id)
    |> modify_query_select_id()
  end

  defp base_query_for_scenery_area_items(area_id) do
    from(
      item in __MODULE__,
      left_join: location in assoc(item, :location),
      as: :location,
      left_join: flags in assoc(item, :flags),
      as: :flags,
      where: location.area_id == ^area_id and flags.is_scenery
    )
  end

  def base_query_for_root_area_item_ids(area_id) do
    base_query_for_root_area_items(area_id)
    |> modify_query_select_id()
  end

  def base_query_for_worn_and_held_inventory_ids(character_id) do
    base_query_for_worn_and_held_inventory(character_id)
    |> modify_query_select_id()
  end

  def base_query_for_root_area_items(area_id) do
    from(
      [location: location] in base_query_without_preload(),
      where: location.on_ground and location.area_id == ^area_id
    )
  end

  def base_query_for_held_item_ids(character_id) do
    base_query_for_held_items(character_id)
    |> modify_query_select_id()
  end

  def base_query_for_held_items(character_id) do
    from(
      [location: location] in base_query_without_preload(),
      where: location.held_in_hand and location.character_id == ^character_id
    )
  end

  def base_query_for_worn_and_held_inventory(character_id) do
    from(
      [location: location] in base_query_without_preload(),
      where:
        (location.held_in_hand or location.worn_on_character) and
          location.character_id == ^character_id
    )
  end

  def search_inside_inventory_query(character_id, search_string) do
    from(
      [description: description, location: location] in base_query_without_preload(),
      where:
        description.item_id in subquery(base_query_for_all_inventory_ids(character_id)) and
          like(description.short, ^search_string) and not location.held_in_hand and
          not location.worn_on_character,
      order_by: [desc: location.moved_at]
    )
  end

  def search_inventory_query(character_id, search_string) do
    from(
      [description: description, location: location] in base_query_for_description_and_location(),
      where:
        description.item_id in subquery(base_query_for_all_inventory_ids(character_id)) and
          like(description.short, ^search_string),
      order_by: [desc: location.moved_at]
    )
  end

  def search_inventory_for_containers_query(character_id, search_string) do
    from(
      [description: description, location: location, flags: flags] in base_query_for_description_and_location_and_flags(),
      where:
        description.item_id in subquery(base_query_for_all_inventory_ids(character_id)) and
          like(description.short, ^search_string) and flags.has_pocket,
      order_by: [desc: location.moved_at]
    )
  end

  def search_held_query(character_id, search_string) do
    from(
      [description: description, location: location] in base_query_for_description_and_location(),
      where:
        description.item_id in subquery(base_query_for_held_item_ids(character_id)) and
          like(description.short, ^search_string),
      order_by: [desc: location.moved_at]
    )
  end

  def search_area_query(area_id, search_string) do
    from(
      [description: description, location: location] in base_query_for_description_and_location(),
      where:
        description.item_id in subquery(base_query_for_all_area_item_ids(area_id)) and
          like(description.short, ^search_string),
      order_by: [desc: location.moved_at]
    )
  end

  def items_to_ids(items) do
    items
    |> List.wrap()
    |> Enum.map(
      &if is_struct(&1) do
        &1.id
      else
        &1
      end
    )
  end

  defp build_item_index(parents) do
    Enum.reduce(parents, %{}, fn item, map -> Map.put(map, item.id, item) end)
  end

  defp build_parent_index(items) do
    Enum.reduce(items, %{}, fn item, map ->
      Map.put(map, item.id, item.location.relative_item_id)
    end)
  end

  defp update_item_components(attrs, flags) do
    flags =
      if Map.has_key?(attrs, "flags") do
        update_component("flags", attrs["flags"], flags.item_id)
      else
        flags
      end

    key_to_flags = %{
      "closable" => :close,
      "coin" => :coin,
      "description" => true,
      "furniture" => :furniture,
      "gem" => :gem,
      "location" => true,
      "lockable" => false,
      "physics" => :has_physics,
      "pocket" => :has_pocket,
      "surface" => :has_surface,
      "wearable" => :wearable
    }

    Enum.each(attrs, fn {key, val} ->
      if not is_nil(val) and key != "id" and
           (key_to_flags[key] == true or
              (key_to_flags[key] != false and Map.get(flags, key_to_flags[key]) == true)) do
        update_component(key, val, flags.item_id)
      end
    end)
  end

  defp update_component(key, attrs, item_id) do
    key_callback_map = %{
      "closable" => Closable,
      "coin" => Coin,
      "description" => Description,
      "flags" => Flags,
      "furniture" => Furniture,
      "gem" => Gem,
      "location" => Location,
      "lockable" => Lockable,
      "physics" => Physics,
      "pocket" => Pocket,
      "surface" => Surface,
      "wearable" => Wearable
    }

    callback = key_callback_map[key]

    if attrs["id"] == "" do
      callback.create(Map.put(attrs, "item_id", item_id))
    else
      callback.get!(attrs["id"]) |> callback.update!(attrs)
    end
  end

  def preload(results) do
    Repo.preload(
      results,
      [
        :closable,
        :coin,
        :description,
        :flags,
        :furniture,
        :gem,
        :location,
        :lockable,
        :physics,
        :pocket,
        :surface,
        :wearable
      ],
      force: true
    )
  end
end
