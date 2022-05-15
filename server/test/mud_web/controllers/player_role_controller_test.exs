defmodule MudWeb.PlayerRoleControllerTest do
  use MudWeb.ConnCase

  alias Mud.Account
  alias Mud.Account.PlayerRole

  @create_attrs %{

  }
  @update_attrs %{

  }
  @invalid_attrs %{}

  def fixture(:player_role) do
    {:ok, player_role} = Account.create_player_role(@create_attrs)
    player_role
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all player_roles", %{conn: conn} do
      conn = get(conn, Routes.player_role_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create player_role" do
    test "renders player_role when data is valid", %{conn: conn} do
      conn = post(conn, Routes.player_role_path(conn, :create), player_role: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.player_role_path(conn, :show, id))

      assert %{
               "id" => id
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.player_role_path(conn, :create), player_role: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update player_role" do
    setup [:create_player_role]

    test "renders player_role when data is valid", %{conn: conn, player_role: %PlayerRole{id: id} = player_role} do
      conn = put(conn, Routes.player_role_path(conn, :update, player_role), player_role: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.player_role_path(conn, :show, id))

      assert %{
               "id" => id
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, player_role: player_role} do
      conn = put(conn, Routes.player_role_path(conn, :update, player_role), player_role: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete player_role" do
    setup [:create_player_role]

    test "deletes chosen player_role", %{conn: conn, player_role: player_role} do
      conn = delete(conn, Routes.player_role_path(conn, :delete, player_role))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.player_role_path(conn, :show, player_role))
      end
    end
  end

  defp create_player_role(_) do
    player_role = fixture(:player_role)
    %{player_role: player_role}
  end
end
