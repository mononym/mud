defmodule MudWeb.MudClientView do
  use MudWeb, :view

  def render("error.json", %{error: error}) do
    %{error: error}
  end

  def render("start_game_session.json", %{token: token}) do
    %{token: token}
  end

  def render("init_client_data.json", %{
        current_map_data: map_data,
        inventory: inventory,
        maps: maps
      }) do
    %{
      mapData: %{
        areas: render_many(map_data.areas, MudWeb.AreaView, "area.json"),
        links: render_many(map_data.links, MudWeb.LinkView, "link.json")
      },
      inventory: render_many(inventory, MudWeb.ItemView, "item.json"),
      maps: render_many(maps, MudWeb.MapView, "map.json")
    }
  end

  def render("update_area.json", %{event: event = %Mud.Engine.Event.Client.UpdateArea{}}) do
    IO.inspect(event)

    %{
      area: render_one(event.area, MudWeb.AreaView, "area.json"),
      otherCharacters:
        render_many(event.other_characters, MudWeb.CharacterView, "character.json"),
      onGround: render_many(event.on_ground, MudWeb.ItemView, "item.json"),
      toi: render_many(event.toi, MudWeb.ItemView, "item.json")
    }
  end
end
