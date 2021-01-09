defmodule MudWeb.ItemView do
  use MudWeb, :view
  alias MudWeb.ItemView

  def render("index.json", %{items: items}) do
    render_many(items, ItemView, "item.json")
  end

  def render("show.json", %{item: item}) do
    render_one(item, ItemView, "map.json")
  end

  def render("item.json", %{item: item}) do
    item
    |> Map.from_struct()
    |> Map.delete(:__meta__)
    |> Map.delete(:container_items)
    |> Map.delete(:container)
    |> Map.delete(:area)
    |> Map.delete(:wearable_worn_by)
    |> Map.delete(:holdable_held_by)
    |> Recase.Enumerable.convert_keys(&Recase.to_camel/1)
  end
end
