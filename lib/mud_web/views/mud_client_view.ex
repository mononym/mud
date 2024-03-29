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
        maps: maps,
        shops: shops,
        time: time,
        time_string: time_string
      }) do
    %{
      mapData: %{
        areas: render_many(map_data.areas, MudWeb.AreaView, "area.json"),
        links: render_many(map_data.links, MudWeb.LinkView, "link.json"),
        explored_areas: map_data.explored_areas
      },
      inventory: render_many(inventory, MudWeb.ItemView, "item.json"),
      maps: render_many(maps, MudWeb.MapView, "map.json"),
      shops: render_many(shops, MudWeb.ShopView, "shop.json"),
      time: time,
      time_string: time_string
    }
  end

  def render("update_area.json", %{event: event = %Mud.Engine.Event.Client.UpdateArea{}}) do
    %{
      action: event.action,
      area: render_one(event.area, MudWeb.AreaView, "area.json"),
      other_characters:
        render_many(event.other_characters, MudWeb.CharacterView, "character.json"),
      items: render_many(event.items, MudWeb.ItemView, "item.json"),
      exits: render_many(event.exits, MudWeb.LinkView, "link.json")
    }
  end

  def render("update_explored_area.json", %{
        event: event = %Mud.Engine.Event.Client.UpdateExploredArea{}
      }) do
    %{
      action: event.action,
      areas: render_many(event.areas, MudWeb.AreaView, "area.json"),
      links: render_many(event.links, MudWeb.LinkView, "link.json"),
      explored: event.explored
    }
  end

  def render("update_explored_map.json", %{
        event: event = %Mud.Engine.Event.Client.UpdateExploredMap{}
      }) do
    %{
      action: event.action,
      maps: render_many(event.maps, MudWeb.MapView, "map.json")
    }
  end

  def render("update_inventory.json", %{event: event = %Mud.Engine.Event.Client.UpdateInventory{}}) do
    %{
      action: event.action,
      items: render_many(event.items, MudWeb.ItemView, "item.json")
    }
  end

  def render("update_map.json", %{event: event = %Mud.Engine.Event.Client.UpdateMap{}}) do
    %{
      action: event.action,
      areas: render_many(event.areas, MudWeb.AreaView, "area.json"),
      links: render_many(event.links, MudWeb.LinkView, "link.json")
    }
  end

  def render("update_shop.json", %{event: event = %Mud.Engine.Event.Client.UpdateShops{}}) do
    %{
      action: event.action,
      shops: render_many(event.shops, MudWeb.ShopView, "shop.json")
    }
  end

  def render("update_character.json", %{event: event = %Mud.Engine.Event.Client.UpdateCharacter{}}) do
    %{
      action: event.action,
      character: render_one(event.character, MudWeb.CharacterView, "character.json"),
      status: render_one(event.status, MudWeb.CharacterStatusView, "character_status.json"),
      wealth: render_one(event.wealth, MudWeb.CharacterWealthView, "character_wealth.json")
    }
  end

  def render("update_time.json", %{event: event = %Mud.Engine.Event.Client.UpdateTime{}}) do
    %{
      action: event.action,
      hour: event.hour,
      time_string: event.time_string
    }
  end
end
