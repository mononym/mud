defmodule MudWeb.ItemLocationView do
  use MudWeb, :view

  def render("item_location.json", %{item_location: item_location}) do
    item_location
  end
end
