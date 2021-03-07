defmodule MudWeb.ItemView do
  use MudWeb, :view

  alias MudWeb.{
    ItemView,
    ItemLocationView,
    ItemFlagsView,
    ItemGemView,
    ItemPhysicsView,
    ItemContainerView,
    ItemDescriptionView,
    ItemFurnitureView,
    ItemCoinView,
    ItemWearableView
  }

  alias MudWeb.ItemLocationView

  def render("index.json", %{items: items}) do
    render_many(items, ItemView, "item.json")
  end

  def render("show.json", %{item: item}) do
    render_one(item, ItemView, "map.json")
  end

  def render("item.json", %{item: item}) do
    if is_binary(item) do
      item
    else
      %{
        id: item.id,
        location: render_one(item.location, ItemLocationView, "item_location.json"),
        flags: render_one(item.flags, ItemFlagsView, "item_flags.json"),
        description: render_one(item.description, ItemDescriptionView, "item_description.json"),
        container: render_one(item.container, ItemContainerView, "item_container.json"),
        physics: render_one(item.physics, ItemPhysicsView, "item_physics.json"),
        coin: render_one(item.coin, ItemCoinView, "item_coin.json"),
        gem: render_one(item.gem, ItemGemView, "item_gem.json"),
        furniture: render_one(item.furniture, ItemFurnitureView, "item_furniture.json"),
        wearable: render_one(item.wearable, ItemWearableView, "item_wearable.json")
      }
    end
  end
end
