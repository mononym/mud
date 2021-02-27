defmodule MudWeb.ItemWearableView do
  use MudWeb, :view

  def render("item_wearable.json", %{item_wearable: item_wearable}) do
    item_wearable
  end
end
