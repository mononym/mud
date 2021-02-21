defmodule MudWeb.ShopProductView do
  use MudWeb, :view
  alias MudWeb.ShopProductView

  def render("index.json", %{shop_products: shop_products}) do
    render_many(shop_products, ShopProductView, "shop_product.json")
  end

  def render("show.json", %{shop_product: shop_product}) do
    render_one(shop_product, ShopProductView, "shop_product.json")
  end

  def render("shop_product.json", %{shop_product: shop_product}) do
    shop_product
  end
end
