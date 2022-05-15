defmodule MudWeb.ItemClosableView do
  use MudWeb, :view

  def render("item_closable.json", %{item_closable: item_closable}) do
    item_closable
  end
end
