defmodule MudWeb.AreaController do
  use MudWeb, :controller

  alias Mud.Engine.{Area, Shop}

  action_fallback(MudWeb.FallbackController)

  def index(conn, _params) do
    areas = Area.list_all()
    render(conn, "index.json", areas: areas)
  end

  def list_by_map(conn, params) do
    areas = Area.list_by_map(params["map_id"], conn.query_params["include_linked"] == "true")
    render(conn, "index.json", areas: areas)
  end

  def create(conn, area_params) do
    with {:ok, %Area{} = area} <-
           Area.create(Recase.Enumerable.convert_keys(area_params, &Recase.to_snake/1)) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.area_path(conn, :show, area))
      |> render("show.json", area: area)
    end
  end

  def show(conn, %{"id" => id}) do
    area = Area.get!(id)
    render(conn, "show.json", area: area)
  end

  def update(conn, area_params = %{"id" => id}) do
    area = Area.get!(id)

    with {:ok, %Area{} = area} <-
           Area.update(area, Recase.Enumerable.convert_keys(area_params, &Recase.to_snake/1)) do
      render(conn, "show.json", area: area)
    end
  end

  def delete(conn, %{"id" => id}) do
    area = Area.get!(id)

    with {:ok, %Area{}} <- Area.delete(area) do
      send_resp(conn, :no_content, "")
    end
  end

  def attach_shop(conn, %{"shop_id" => shop_id, "area_id" => area_id}) do
    shop = Shop.get!(shop_id)

    with {:ok, %Shop{}} <- Shop.update(shop, %{area_id: area_id}) do
      send_resp(conn, :ok, "")
    end
  end

  def detach_shop(conn, %{"shop_id" => shop_id}) do
    shop = Shop.get!(shop_id)

    with {:ok, %Shop{}} <- Shop.update(shop, %{area_id: nil}) do
      send_resp(conn, :ok, "")
    end
  end
end
