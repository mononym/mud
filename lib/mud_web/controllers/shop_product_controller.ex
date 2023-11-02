defmodule MudWeb.ShopProductController do
  use MudWeb, :controller

  alias Mud.Engine.Shop.Product

  action_fallback(MudWeb.FallbackController)

  def create(conn, %{"shop_product" => shop_product_params}) do
    with {:ok, %Product{} = shop_product} <-
           Product.create(shop_product_params) do
      conn
      |> put_status(:created)
      |> render("show.json", shop_product: shop_product)
    end
  end

  def show(conn, %{"id" => id}) do
    shop_product = Product.get!(id)

    conn
    |> render("show.json", shop_product: shop_product)
  end

  def update(conn, %{"shop_product_id" => id, "shop_product" => shop_product_params}) do
    shop_product = Product.get!(id)

    with {:ok, %Product{} = shop_product} <-
           Product.update(shop_product, shop_product_params) do
      conn
      |> render("show.json", shop_product: shop_product)
    end
  end

  def delete(conn, %{"shop_product_id" => id}) do
    shop_product = Product.get!(id)

    with {:ok, %Product{}} <- Product.delete(shop_product) do
      send_resp(conn, :no_content, "")
    end
  end
end
