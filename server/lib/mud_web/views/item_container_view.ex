defmodule MudWeb.ItemContainerView do
  use MudWeb, :view

  def render("item_container.json", %{item_container: item_container}) do
    item_container
  end
end
