defmodule MudWeb.LuaScriptControllerTest do
  use MudWeb.ConnCase

  alias Mud.Engine
  alias Mud.Engine.LuaScript

  @create_attrs %{
    code: "some code",
    name: "some name",
    type: "some type"
  }
  @update_attrs %{
    code: "some updated code",
    name: "some updated name",
    type: "some updated type"
  }
  @invalid_attrs %{code: nil, name: nil, type: nil}

  def fixture(:lua_script) do
    {:ok, lua_script} = Engine.create_lua_script(@create_attrs)
    lua_script
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all lua_scripts", %{conn: conn} do
      conn = get(conn, Routes.lua_script_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create lua_script" do
    test "renders lua_script when data is valid", %{conn: conn} do
      conn = post(conn, Routes.lua_script_path(conn, :create), lua_script: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.lua_script_path(conn, :show, id))

      assert %{
               "id" => id,
               "code" => "some code",
               "name" => "some name",
               "type" => "some type"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.lua_script_path(conn, :create), lua_script: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update lua_script" do
    setup [:create_lua_script]

    test "renders lua_script when data is valid", %{conn: conn, lua_script: %LuaScript{id: id} = lua_script} do
      conn = put(conn, Routes.lua_script_path(conn, :update, lua_script), lua_script: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.lua_script_path(conn, :show, id))

      assert %{
               "id" => id,
               "code" => "some updated code",
               "name" => "some updated name",
               "type" => "some updated type"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, lua_script: lua_script} do
      conn = put(conn, Routes.lua_script_path(conn, :update, lua_script), lua_script: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete lua_script" do
    setup [:create_lua_script]

    test "deletes chosen lua_script", %{conn: conn, lua_script: lua_script} do
      conn = delete(conn, Routes.lua_script_path(conn, :delete, lua_script))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.lua_script_path(conn, :show, lua_script))
      end
    end
  end

  defp create_lua_script(_) do
    lua_script = fixture(:lua_script)
    %{lua_script: lua_script}
  end
end
