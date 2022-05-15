defmodule MudWeb.PlayerRoleController do
  use MudWeb, :controller

  alias Mud.Account
  alias Mud.Account.PlayerRole

  action_fallback MudWeb.FallbackController

  def index(conn, _params) do
    player_roles = Account.list_player_roles()
    render(conn, "index.json", player_roles: player_roles)
  end

  def create(conn, %{"player_role" => player_role_params}) do
    with {:ok, %PlayerRole{} = player_role} <- Account.create_player_role(player_role_params) do
      conn
      |> put_status(:created)
      # |> put_resp_header("location", Routes.player_role_path(conn, :show, player_role))
      |> render("show.json", player_role: player_role)
    end
  end

  def show(conn, %{"id" => id}) do
    player_role = Account.get_player_role!(id)
    render(conn, "show.json", player_role: player_role)
  end

  def update(conn, %{"id" => id, "player_role" => player_role_params}) do
    player_role = Account.get_player_role!(id)

    with {:ok, %PlayerRole{} = player_role} <- Account.update_player_role(player_role, player_role_params) do
      render(conn, "show.json", player_role: player_role)
    end
  end

  def delete(conn, %{"id" => id}) do
    player_role = Account.get_player_role!(id)

    with {:ok, %PlayerRole{}} <- Account.delete_player_role(player_role) do
      send_resp(conn, :no_content, "")
    end
  end
end
