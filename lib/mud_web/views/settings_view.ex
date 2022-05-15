defmodule MudWeb.SettingsView do
  use MudWeb, :view
  alias MudWeb.SettingsView

  def render("index.json", %{settings: settings}) do
    %{data: render_many(settings, SettingsView, "settings.json")}
  end

  def render("show.json", %{settings: settings}) do
    %{data: render_one(settings, SettingsView, "settings.json")}
  end

  def render("settings.json", %{settings: settings}) do
    %{
      player_id: settings.player_id,
      developer_feature_on: settings.developer_feature_on,
      inserted_at: settings.inserted_at,
      updated_at: settings.updated_at
    }
  end
end
