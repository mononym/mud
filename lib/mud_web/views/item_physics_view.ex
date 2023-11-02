defmodule MudWeb.ItemPhysicsView do
  use MudWeb, :view

  def render("item_physics.json", %{item_physics: item_physics}) do
    item_physics
  end
end
