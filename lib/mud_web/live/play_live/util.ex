defmodule MudWeb.PlayLive.Util do
  @moduledoc """
  Helper functions for the various client components
  """

  def text_type_to_color(colors_settings, type) do
    Map.get(colors_settings, String.to_existing_atom(type))
  end

  def item_to_color(colors_settings, %{flags: %{is_gem: true}}) do
    colors_settings.gem
  end

  def item_to_color(colors_settings, %{flags: %{is_furniture: true}}) do
    colors_settings.furniture
  end

  def item_to_color(colors_settings, %{flags: %{is_equipment: true}}) do
    colors_settings.equipment
  end

  def item_to_color(colors_settings, %{flags: %{is_weapon: true}}) do
    colors_settings.weapon
  end

  def item_to_color(colors_settings, %{flags: %{is_armor: true}}) do
    colors_settings.armor
  end

  def item_to_color(colors_settings, %{flags: %{is_coin: true}}) do
    colors_settings.coin
  end

  def item_to_color(colors_settings, %{flags: %{is_shield: true}}) do
    colors_settings.shield
  end

  def item_to_color(colors_settings, %{flags: %{is_clothing: true}}) do
    colors_settings.clothing
  end

  def item_to_color(colors_settings, %{flags: %{is_structure: true}}) do
    colors_settings.structure
  end

  def item_to_color(colors_settings, %{flags: %{is_jewelry: true}}) do
    colors_settings.jewelry
  end

  def item_to_color(colors_settings, %{flags: %{is_misc: true}}) do
    colors_settings.misc
  end

  def item_to_color(colors_settings, _item) do
    colors_settings.misc
  end

  def build_parent_child_map(items) do
    Enum.reduce(Map.values(items), %{}, fn item, map ->
      if not is_nil(item.location.relative_item_id) do
        children = Map.get(map, item.location.relative_item_id, [])
        Map.put(map, item.location.relative_item_id, [item | children])
      else
        children = Map.get(map, item.id, [])
        Map.put(map, item.id, children)
      end
    end)
    |> Enum.into(%{}, fn {key, children} ->
      sorted =
        Enum.sort(children, fn child1, child2 ->
          DateTime.compare(child1.location.moved_at, child2.location.moved_at) in [:gt, :eq]
        end)
        |> Enum.map(& &1.id)

      {key, sorted}
    end)
  end

  def sort_by_moved_at(items) do
    Enum.sort(
      items,
      &(DateTime.compare(&1.location.moved_at, &2.location.moved_at) in [:gt, :eq])
    )
  end
end
