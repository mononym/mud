defmodule MudWeb.PlayerView do
  use MudWeb, :view
  alias MudWeb.PlayerView

  def render("index.json", %{players: players}) do
    %{data: render_many(players, PlayerView, "player.json")}
  end

  def render("show.json", %{player: player}) do
    %{data: render_one(player, PlayerView, "player.json")}
  end

  def render("player.json", %{player: player}) do
    %{
      id: player.id,
      inserted_at: player.inserted_at,
      # Account.Role structs are turned into a list of role names when sent to client
      roles: Enum.map(player.roles, & &1.name),
      status: player.status,
      tos_accepted: player.tos_accepted,
      updated_at: player.updated_at
    }
  end
end
