defmodule MudWeb.ItemPocketView do
  use MudWeb, :view

  def render("item_pocket.json", %{item_pocket: item_pocket}) do
    item_pocket
  end
end
