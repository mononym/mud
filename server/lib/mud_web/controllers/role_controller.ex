defmodule MudWeb.RoleController do
  use MudWeb, :controller

  alias Mud.Account
  alias Mud.Account.Role

  action_fallback MudWeb.FallbackController

  def index(conn, _params) do
    roles = Account.list_roles()
    render(conn, "index.json", roles: roles)
  end

  def create(conn, %{"role" => role_params}) do
    with {:ok, %Role{} = role} <- Account.create_role(role_params) do
      conn
      |> put_status(:created)
      # |> put_resp_header("location", Routes.role_path(conn, :show, role))
      |> render("show.json", role: role)
    end
  end

  def show(conn, %{"id" => id}) do
    role = Account.get_role!(id)
    render(conn, "show.json", role: role)
  end

  def update(conn, %{"id" => id, "role" => role_params}) do
    role = Account.get_role!(id)

    with {:ok, %Role{} = role} <- Account.update_role(role, role_params) do
      render(conn, "show.json", role: role)
    end
  end

  def delete(conn, %{"id" => id}) do
    role = Account.get_role!(id)

    with {:ok, %Role{}} <- Account.delete_role(role) do
      send_resp(conn, :no_content, "")
    end
  end
end
