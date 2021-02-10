defmodule MudWeb.ItemGemView do
  use MudWeb, :view

  def render("item_gem.json", %{item_gem: item_gem}) do
    item_gem
  end
end
