defmodule MudWeb.MapController do
  use MudWeb, :controller

  alias Mud.Engine
  require Logger

  action_fallback(MudWeb.FallbackController)

  def index(conn, _params) do
    maps = Engine.Map.list_all()
    render(conn, "index.json", maps: maps)
  end

  def create(conn, map_params) do
    with {:ok, %Engine.Map{} = map} <- Engine.Map.create(map_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.map_path(conn, :show, map))
      |> render("show.json", map: map)
    end
  end

  def show(conn, %{"id" => id}) do
    map = Engine.Map.get!(id)
    render(conn, "show.json", map: map)
  end

  def update(conn, map_params = %{"id" => id}) do
    map = Engine.Map.get!(id)

    with {:ok, %Engine.Map{} = map} <- Engine.Map.update(map, map_params) do
      render(conn, "show.json", map: map)
    end
  end

  def delete(conn, %{"id" => id}) do
    map = Engine.Map.get!(id)

    with {:ok, %Engine.Map{}} <- Engine.Map.delete(map) do
      send_resp(conn, :no_content, "")
    end
  end

  def fetch_character_data(conn, %{"character_id" => character_id, "map_id" => map_id}) do
    render(conn, "character_data.json", Engine.Map.fetch_character_data(character_id, map_id))
  end

  def fetch_data(conn, %{"map_id" => map_id}) do
    Logger.debug("fetching data for map")
    data = Engine.Map.fetch_data(map_id)
    Logger.debug("fetched data for map")
    render(conn, "data.json", data)
  end
end
