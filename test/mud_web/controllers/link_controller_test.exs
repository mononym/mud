defmodule MudWeb.LinkControllerTest do
  use MudWeb.ConnCase

  alias Mud.Engine
  alias Mud.Engine.Link

  @create_attrs %{
    text: "some text",
    type: "some type"
  }
  @update_attrs %{
    text: "some updated text",
    type: "some updated type"
  }
  @invalid_attrs %{text: nil, type: nil}

  def fixture(:link) do
    {:ok, link} = Engine.create_link(@create_attrs)
    link
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all links", %{conn: conn} do
      conn = get(conn, Routes.link_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create link" do
    test "renders link when data is valid", %{conn: conn} do
      conn = post(conn, Routes.link_path(conn, :create), link: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.link_path(conn, :show, id))

      assert %{
               "id" => id,
               "text" => "some text",
               "type" => "some type"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.link_path(conn, :create), link: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update link" do
    setup [:create_link]

    test "renders link when data is valid", %{conn: conn, link: %Link{id: id} = link} do
      conn = put(conn, Routes.link_path(conn, :update, link), link: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.link_path(conn, :show, id))

      assert %{
               "id" => id,
               "text" => "some updated text",
               "type" => "some updated type"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, link: link} do
      conn = put(conn, Routes.link_path(conn, :update, link), link: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete link" do
    setup [:create_link]

    test "deletes chosen link", %{conn: conn, link: link} do
      conn = delete(conn, Routes.link_path(conn, :delete, link))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.link_path(conn, :show, link))
      end
    end
  end

  defp create_link(_) do
    link = fixture(:link)
    {:ok, link: link}
  end
end
