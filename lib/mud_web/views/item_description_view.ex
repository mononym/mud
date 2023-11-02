defmodule MudWeb.ItemDescriptionView do
  use MudWeb, :view

  def render("item_description.json", %{item_description: item_description}) do
    item_description
  end
end
