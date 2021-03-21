defmodule MudWeb.ItemSurfaceView do
  use MudWeb, :view

  def render("item_surface.json", %{item_surface: item_surface}) do
    item_surface
  end
end
