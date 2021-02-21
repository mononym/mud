defmodule MudWeb.ShopView do
  use MudWeb, :view
  alias MudWeb.ShopView

  def render("index.json", %{shops: shops}) do
    render_many(shops, ShopView, "shop.json")
  end

  def render("show.json", %{shop: shop}) do
    render_one(shop, ShopView, "shop.json")
  end

  def render("shop.json", %{shop: shop}) do
    shop
  end
end
