defmodule MudWeb.Views.Character.Settings.MapWindowView do
  use MudWeb, :view

  def render("map_window.json", %{map_window: map_window}) do
    %{
      id: map_window.id,
      unexplored_link_color: map_window.unexplored_link_color,
      background_color: map_window.background_color,
      highlighted_area_color: map_window.highlighted_area_color
    }
  end
end
