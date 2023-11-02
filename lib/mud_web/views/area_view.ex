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
      key: area.key,
      map_x: area.map_x,
      map_y: area.map_y,
      map_size: area.map_size,
      map_id: area.map_id,
      map_corners: area.map_corners,
      border_color: area.border_color,
      border_width: area.border_width,
      color: area.color,
      inserted_at: area.inserted_at,
      updated_at: area.updated_at,
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
