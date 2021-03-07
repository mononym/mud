defmodule MudWeb.ItemFurnitureView do
  use MudWeb, :view

  def render("item_furniture.json", %{item_furniture: item_furniture}) do
    item_furniture
  end
end
