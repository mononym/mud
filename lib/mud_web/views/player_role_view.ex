defmodule MudWeb.PlayerRoleView do
  use MudWeb, :view
  alias MudWeb.PlayerRoleView

  def render("index.json", %{player_roles: player_roles}) do
    %{data: render_many(player_roles, PlayerRoleView, "player_role.json")}
  end

  def render("show.json", %{player_role: player_role}) do
    %{data: render_one(player_role, PlayerRoleView, "player_role.json")}
  end

  def render("player_role.json", %{player_role: player_role}) do
    %{id: player_role.id}
  end
end
