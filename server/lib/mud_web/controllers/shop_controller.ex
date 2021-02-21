defmodule MudWeb.ShopController do
  use MudWeb, :controller

  alias Mud.Engine.Shop

  action_fallback(MudWeb.FallbackController)

  def index(conn, _params) do
    shops = Shop.list_all()
    render(conn, "index.json", shops: shops)
  end

  def load_shops_for_builder(conn, _params) do
    shops = Shop.list_all_with_products()
    render(conn, "index.json", shops: shops)
  end

  def create(conn, %{"shop" => shop_params}) do
    with {:ok, %Shop{} = shop} <-
           Shop.create(shop_params) do
      conn
      |> put_status(:created)
      |> render("show.json", shop: shop)
    end
  end

  def show(conn, %{"id" => id}) do
    shop = Shop.get!(id)
    render(conn, "show.json", shop: shop)
  end

  def update(conn, %{"shop_id" => id, "shop" => shop_params}) do
    shop = Shop.get!(id)

    with {:ok, %Shop{} = shop} <-
           Shop.update(shop, shop_params) do
      render(conn, "show.json", shop: shop)
    end
  end

  def delete(conn, %{"shop_id" => id}) do
    shop = Shop.get!(id)

    with {:ok, %Shop{}} <- Shop.delete(shop) do
      send_resp(conn, :no_content, "")
    end
  end
end
