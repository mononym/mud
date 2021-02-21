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
    products =
      if is_list(shop.products) do
        render_many(
          shop.products,
          MudWeb.ShopProductView,
          "shop_product.json"
        )
      else
        []
      end

    %{shop | products: products}
  end
end
