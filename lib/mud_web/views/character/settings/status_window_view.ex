defmodule MudWeb.Views.Character.Settings.StatusWindowView do
  use MudWeb, :view

  def render("status_window.json", %{status_window: status_window}) do
    %{
      id: status_window.id,
      posture_icon_color: status_window.posture_icon_color,
      background_color: status_window.background_color
    }
  end
end
