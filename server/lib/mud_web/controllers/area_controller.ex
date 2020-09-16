defmodule MudWeb.AreaController do
  use MudWeb, :controller

  alias Mud.Engine.Area

  action_fallback MudWeb.FallbackController

  def index(conn, _params) do
    areas = Area.list_all()
    render(conn, "index.json", areas: areas)
  end

  def get_areas_for_map(conn, %{"map_id" => map_id}) do
    areas = Area.list_by_map(map_id)
    render(conn, "index.json", areas: areas)
  end

  def create(conn, %{"area" => area_params}) do
    with {:ok, %Area{} = area} <- Area.create(area_params) do
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

  def update(conn, %{"id" => id, "area" => area_params}) do
    IO.inspect(id, label: "getting")
    area = Area.get!(id)
    IO.inspect(area, label: "gotarea")
    with {:ok, %Area{} = area} <- Area.update(area, area_params) do
      IO.inspect(area, label: "updated")
      render(conn, "show.json", area: area)
    end
  end

  def delete(conn, %{"id" => id}) do
    area = Area.get!(id)

    with {:ok, %Area{}} <- Area.delete(area) do
      send_resp(conn, :no_content, "")
    end
  end
end