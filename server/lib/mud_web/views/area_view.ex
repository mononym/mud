defmodule MudWeb.AreaView do
  use MudWeb, :view
  alias MudWeb.AreaView

  def render("index.json", %{areas: areas}) do
    render_many(areas, AreaView, "area.json")
  end

  def render("show.json", %{area: area}) do
    render_one(area, AreaView, "area.json")
  end

  def render("area.json", %{area: area}) do
    %{id: area.id,
      name: area.name,
      description: area.description,
      mapX: area.map_x,
      mapY: area.map_y,
      mapSize: area.map_size,
      mapId: area.map_id,
      instanceId: area.instance_id,
      insertedAt: area.inserted_at,
      updatedAt: area.updated_at}
  end
end
