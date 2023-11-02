defmodule MudWeb.CommandControllerTest do
  use MudWeb.ConnCase

  alias Mud.Engine
  alias Mud.Engine.Command

  @create_attrs %{
    description: "some description",
    name: "some name",
    parts: []
  }
  @update_attrs %{
    description: "some updated description",
    name: "some updated name",
    parts: []
  }
  @invalid_attrs %{description: nil, name: nil, parts: nil}

  def fixture(:command) do
    {:ok, command} = Engine.create_command(@create_attrs)
    command
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all commands", %{conn: conn} do
      conn = get(conn, Routes.command_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create command" do
    test "renders command when data is valid", %{conn: conn} do
      conn = post(conn, Routes.command_path(conn, :create), command: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.command_path(conn, :show, id))

      assert %{
               "id" => id,
               "description" => "some description",
               "name" => "some name",
               "parts" => []
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.command_path(conn, :create), command: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update command" do
    setup [:create_command]

    test "renders command when data is valid", %{conn: conn, command: %Command{id: id} = command} do
      conn = put(conn, Routes.command_path(conn, :update, command), command: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.command_path(conn, :show, id))

      assert %{
               "id" => id,
               "description" => "some updated description",
               "name" => "some updated name",
               "parts" => []
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, command: command} do
      conn = put(conn, Routes.command_path(conn, :update, command), command: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete command" do
    setup [:create_command]

    test "deletes chosen command", %{conn: conn, command: command} do
      conn = delete(conn, Routes.command_path(conn, :delete, command))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.command_path(conn, :show, command))
      end
    end
  end

  defp create_command(_) do
    command = fixture(:command)
    %{command: command}
  end
end
