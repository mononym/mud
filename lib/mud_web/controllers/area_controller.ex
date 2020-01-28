defmodule MudWeb.AreaController do
  use MudWeb, :controller

  alias Mud.Engine
  alias Mud.Engine.Area

  action_fallback MudWeb.FallbackController

  def index(conn, _params) do
    areas = Engine.list_areas()
    render(conn, "index.json", areas: areas)
  end

  def create(conn, %{"area" => area_params}) do
    with {:ok, %Area{} = area} <- Engine.create_area(area_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.area_path(conn, :show, area))
      |> render("show.json", area: area)
    end
  end

  def show(conn, %{"id" => id}) do
    area = Engine.get_area!(id)
    render(conn, "show.json", area: area)
  end

  def update(conn, %{"id" => id, "area" => area_params}) do
    area = Engine.get_area!(id)

    with {:ok, %Area{} = area} <- Engine.update_area(area, area_params) do
      render(conn, "show.json", area: area)
    end
  end

  def delete(conn, %{"id" => id}) do
    area = Engine.get_area!(id)

    with {:ok, %Area{}} <- Engine.delete_area(area) do
      send_resp(conn, :no_content, "")
    end
  end
end
