defmodule MudWeb.MapView do
  use MudWeb, :view
  alias MudWeb.{AreaView, MapView}

  def render("index.json", %{maps: maps}) do
    IO.inspect(maps, label: "maps")
    render_many(maps, MapView, "map.json")
  end

  def render("show.json", %{map: map}) do
    render_one(map, MapView, "map.json")
  end

  def render("map.json", %{map: map}) do
    IO.inspect(map, label: "map")
    %{id: map.id,
      name: map.name,
      description: map.description,
      areas: render_many(map.areas, AreaView, "area.json"),
      inserted_at: map.inserted_at,
      updated_at: map.updated_at}
  end
end
