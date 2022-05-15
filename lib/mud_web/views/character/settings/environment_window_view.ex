defmodule MudWeb.Views.Character.Settings.EnvironmentWindowView do
  use MudWeb, :view

  def render("environment_window.json", %{environment_window: environment_window}) do
    %{
      id: environment_window.id,
      background_color: environment_window.background_color,
      time_text_color: environment_window.time_text_color
    }
  end
end
