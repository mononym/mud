defmodule MudWeb.ItemLockableView do
  use MudWeb, :view

  def render("item_lockable.json", %{item_lockable: item_lockable}) do
    item_lockable
  end
end
