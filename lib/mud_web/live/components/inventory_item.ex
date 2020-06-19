defmodule MudWeb.Live.Component.InventoryItem do
  use Phoenix.LiveComponent

  def render(assigns) do
    Phoenix.View.render(MudWeb.MudClientView, "inventory_item.html", assigns)
  end
end
