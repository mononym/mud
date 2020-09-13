defmodule MudWeb.MapView do
  use MudWeb, :view
  alias MudWeb.MapView

  def render("index.json", %{maps: maps}) do
    render_many(maps, MapView, "map.json")
  end

  def render("show.json", %{map: map}) do
    render_one(map, MapView, "map.json")
  end

  def render("map.json", %{map: map}) do
    %{id: map.id,
      name: map.name,
      description: map.description,
      inserted_at: map.inserted_at,
      updated_at: map.updated_at}
  end
end
