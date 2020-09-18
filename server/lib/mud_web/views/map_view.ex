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
      mapSize: map.map_size,
      gridSize: map.grid_size,
      maxZoom: map.min_zoom,
      minZoom: map.min_zoom,
      defaultZoom: map.default_zoom,
      inserted_at: map.inserted_at,
      updated_at: map.updated_at
    }
  end

  def render("data.json", data) do
    %{
      external_areas: external_areas,
      internal_areas: internal_areas,
      external_links: external_links,
      internal_links: internal_links
    } = data

    %{
      externalAreas: render_many(external_areas, AreaView, "area.json"),
      internalAreas: render_many(internal_areas, AreaView, "area.json"),
      externalLinks: render_many(external_links, LinkView, "link.json"),
      internalLinks: render_many(internal_links, LinkView, "link.json")
    }
  end
end
