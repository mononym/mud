defmodule MudWeb.AreaView do
  use MudWeb, :view
  alias MudWeb.AreaView
  alias MudWeb.AreaFlagsView
  alias MudWeb.ShopView

  def render("index.json", %{areas: areas}) do
    render_many(areas, AreaView, "area.json")
  end

  def render("show.json", %{area: area}) do
    render_one(area, AreaView, "area.json")
  end

  def render("area.json", %{area: area}) do
    shops =
      if is_list(area.shops) do
        render_many(
          area.shops,
          ShopView,
          "shop.json"
        )
      else
        []
      end

    %{
      id: area.id,
      name: area.name,
      description: area.description,
      mapX: area.map_x,
      mapY: area.map_y,
      mapSize: area.map_size,
      mapId: area.map_id,
      mapCorners: area.map_corners,
      borderColor: area.border_color,
      borderWidth: area.border_width,
      color: area.color,
      insertedAt: area.inserted_at,
      updatedAt: area.updated_at,
      flags:
        render_one(
          area.flags,
          AreaFlagsView,
          "area_flags.json"
        ),
      shops: shops
    }
  end
end
