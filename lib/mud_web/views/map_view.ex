defmodule MudWeb.MapView do
  use MudWeb, :view
  alias MudWeb.AreaView
  alias MudWeb.LinkView
  alias MudWeb.MapLabelView
  alias MudWeb.MapView
  require Logger

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
      key: map.key,
      view_size: map.view_size,
      grid_size: map.grid_size,
      inserted_at: map.inserted_at,
      updated_at: map.updated_at
    }
  end

  def render("character_data.json", data) do
    %{
      areas: render_many(data.areas, AreaView, "area.json"),
      links: render_many(data.links, LinkView, "link.json"),
      explored_areas: data.explored_areas
    }
  end

  def render("data.json", data) do
    areas = render_many(data.areas, AreaView, "area.json")
    labels = render_many(data.labels, MapLabelView, "map_label.json")
    links = render_many(data.links, LinkView, "link.json")

    %{
      areas: areas,
      labels: labels,
      links: links
    }
  end
end
