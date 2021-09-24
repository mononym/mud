defmodule MudWeb.Views.Character.Settings.DirectionsWindowView do
  use MudWeb, :view

  def render("directions_window.json", %{directions_window: directions_window}) do
    %{
      id: directions_window.id,
      active_direction_background_color: directions_window.active_direction_background_color,
      active_direction_icon_color: directions_window.active_direction_icon_color,
      inactive_direction_background_color: directions_window.inactive_direction_background_color,
      inactive_direction_icon_color: directions_window.inactive_direction_icon_color,
      background_color: directions_window.background_color
    }
  end
end
