defmodule MudWeb.MapController do
  use MudWeb, :controller

  alias Mud.Engine.{Map}

  action_fallback MudWeb.FallbackController

  def index(conn, _params) do
    maps = Map.list_all()
    render(conn, "index.json", maps: maps)
  end

  def create(conn, %{"map" => map_params}) do
    with {:ok, %Map{} = map} <- Map.create(map_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.map_path(conn, :show, map))
      |> render("show.json", map: map)
    end
  end

  def show(conn, %{"id" => id}) do
    map = Map.get!(id)
    render(conn, "show.json", map: map)
  end

  def update(conn, %{"id" => id, "map" => map_params}) do
    map = Map.get!(id)
    with {:ok, %Map{} = map} <- Map.update(map, map_params) do
      render(conn, "show.json", map: map)
    end
  end

  def delete(conn, %{"id" => id}) do
    map = Map.get!(id)

    with {:ok, %Map{}} <- Map.delete(map) do
      send_resp(conn, :no_content, "")
    end
  end

  def fetch_data(conn, %{"map_id" => map_id}) do
    render(conn, "data.json", Map.fetch_data(map_id))
  end
end
