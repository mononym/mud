defmodule MudWeb.MapView do
  use MudWeb, :view
  alias MudWeb.AreaView
  alias MudWeb.LinkView
  alias MudWeb.MapView

  def render("index.json", %{maps: maps}) do
    render_many(maps, MapView, "map.json")
  end

  def render("show.json", %{map: map}) do
    render_one(map, MapView, "map.json")
  end

  def render("map.json", %{map: map}) do
    %{
      id: map.id,
      name: map.name,
      description: map.description,
      viewSize: map.view_size,
      gridSize: map.grid_size,
      labels: map.labels,
      minimumZoomIndex: map.minimum_zoom_index,
      maximumZoomIndex: map.maximum_zoom_index,
      permanently_explored: map.permanently_explored,
      inserted_at: map.inserted_at,
      updated_at: map.updated_at
    }
  end

  def render("character_data.json", data) do
    %{
      areas: render_many(data.areas, AreaView, "area.json"),
      links: render_many(data.links, LinkView, "link.json"),
      exploredAreas: data.explored_areas
    }
  end

  def render("data.json", data) do
    %{
      areas: render_many(data.areas, AreaView, "area.json"),
      links: render_many(data.links, LinkView, "link.json")
    }
  end
end
