defmodule MudWeb.ItemView do
  use MudWeb, :view

  alias MudWeb.{
    ItemView,
    ItemClosableView,
    ItemCoinView,
    ItemDescriptionView,
    ItemFlagsView,
    ItemFurnitureView,
    ItemGemView,
    ItemLocationView,
    ItemLockableView,
    ItemPhysicsView,
    ItemPocketView,
    ItemSurfaceView,
    ItemWearableView
  }

  alias MudWeb.ItemLocationView

  def render("index.json", %{items: items}) do
    render_many(items, ItemView, "item.json")
  end

  def render("show.json", %{item: item}) do
    render_one(item, ItemView, "item.json")
  end

  def render("item.json", %{item: item}) do
    if is_binary(item) do
      item
    else
      %{
        id: item.id,
        closable: render_one(item.closable, ItemClosableView, "item_closable.json"),
        coin: render_one(item.coin, ItemCoinView, "item_coin.json"),
        description: render_one(item.description, ItemDescriptionView, "item_description.json"),
        flags: render_one(item.flags, ItemFlagsView, "item_flags.json"),
        furniture: render_one(item.furniture, ItemFurnitureView, "item_furniture.json"),
        gem: render_one(item.gem, ItemGemView, "item_gem.json"),
        location: render_one(item.location, ItemLocationView, "item_location.json"),
        lockable: render_one(item.lockable, ItemLockableView, "item_lockable.json"),
        physics: render_one(item.physics, ItemPhysicsView, "item_physics.json"),
        pocket: render_one(item.pocket, ItemPocketView, "item_pocket.json"),
        surface: render_one(item.surface, ItemSurfaceView, "item_surface.json"),
        wearable: render_one(item.wearable, ItemWearableView, "item_wearable.json")
      }
    end
  end
end
