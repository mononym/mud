defmodule MudWeb.ItemFlagsView do
  use MudWeb, :view

  def render("item_flags.json", %{item_flags: item_flags}) do
    item_flags
  end
end
