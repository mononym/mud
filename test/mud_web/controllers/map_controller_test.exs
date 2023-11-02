defmodule MudWeb.MapControllerTest do
  use MudWeb.ConnCase

  alias Mud.Engine
  alias Mud.Engine.Map

  @create_attrs %{
    description: "some description",
    name: "some name"
  }
  @update_attrs %{
    description: "some updated description",
    name: "some updated name"
  }
  @invalid_attrs %{description: nil, name: nil}

  def fixture(:map) do
    {:ok, map} = Engine.create_map(@create_attrs)
    map
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all maps", %{conn: conn} do
      conn = get(conn, Routes.map_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create map" do
    test "renders map when data is valid", %{conn: conn} do
      conn = post(conn, Routes.map_path(conn, :create), map: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.map_path(conn, :show, id))

      assert %{
               "id" => id,
               "description" => "some description",
               "name" => "some name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.map_path(conn, :create), map: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update map" do
    setup [:create_map]

    test "renders map when data is valid", %{conn: conn, map: %Map{id: id} = map} do
      conn = put(conn, Routes.map_path(conn, :update, map), map: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.map_path(conn, :show, id))

      assert %{
               "id" => id,
               "description" => "some updated description",
               "name" => "some updated name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, map: map} do
      conn = put(conn, Routes.map_path(conn, :update, map), map: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete map" do
    setup [:create_map]

    test "deletes chosen map", %{conn: conn, map: map} do
      conn = delete(conn, Routes.map_path(conn, :delete, map))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.map_path(conn, :show, map))
      end
    end
  end

  defp create_map(_) do
    map = fixture(:map)
    %{map: map}
  end
end
