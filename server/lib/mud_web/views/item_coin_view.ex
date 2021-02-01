defmodule MudWeb.ItemCoinView do
  use MudWeb, :view

  def render("item_coin.json", %{item_coin: item_coin}) do
    item_coin
  end
end
