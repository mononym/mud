defmodule MudWeb.AreaControllerTest do
  use MudWeb.ConnCase

  alias Mud.Engine
  alias Mud.Engine.Area

  @create_attrs %{
    description: "some description",
    name: "some name"
  }
  @update_attrs %{
    description: "some updated description",
    name: "some updated name"
  }
  @invalid_attrs %{description: nil, name: nil}

  def fixture(:area) do
    {:ok, area} = Engine.create_area(@create_attrs)
    area
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all areas", %{conn: conn} do
      conn = get(conn, Routes.area_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create area" do
    test "renders area when data is valid", %{conn: conn} do
      conn = post(conn, Routes.area_path(conn, :create), area: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.area_path(conn, :show, id))

      assert %{
               "id" => id,
               "description" => "some description",
               "name" => "some name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.area_path(conn, :create), area: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update area" do
    setup [:create_area]

    test "renders area when data is valid", %{conn: conn, area: %Area{id: id} = area} do
      conn = put(conn, Routes.area_path(conn, :update, area), area: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.area_path(conn, :show, id))

      assert %{
               "id" => id,
               "description" => "some updated description",
               "name" => "some updated name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, area: area} do
      conn = put(conn, Routes.area_path(conn, :update, area), area: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete area" do
    setup [:create_area]

    test "deletes chosen area", %{conn: conn, area: area} do
      conn = delete(conn, Routes.area_path(conn, :delete, area))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.area_path(conn, :show, area))
      end
    end
  end

  defp create_area(_) do
    area = fixture(:area)
    {:ok, area: area}
  end
end
