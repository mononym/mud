defmodule MudWeb.CharacterTemplateControllerTest do
  use MudWeb.ConnCase

  alias Mud.Mud.Engine
  alias Mud.Mud.Engine.CharacterTemplate

  @create_attrs %{
    description: "some description",
    name: "some name",
    template: "some template"
  }
  @update_attrs %{
    description: "some updated description",
    name: "some updated name",
    template: "some updated template"
  }
  @invalid_attrs %{description: nil, name: nil, template: nil}

  def fixture(:character_template) do
    {:ok, character_template} = Engine.create_character_template(@create_attrs)
    character_template
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all character_templates", %{conn: conn} do
      conn = get(conn, Routes.character_template_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create character_template" do
    test "renders character_template when data is valid", %{conn: conn} do
      conn = post(conn, Routes.character_template_path(conn, :create), character_template: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.character_template_path(conn, :show, id))

      assert %{
               "id" => id,
               "description" => "some description",
               "name" => "some name",
               "template" => "some template"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.character_template_path(conn, :create), character_template: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update character_template" do
    setup [:create_character_template]

    test "renders character_template when data is valid", %{conn: conn, character_template: %CharacterTemplate{id: id} = character_template} do
      conn = put(conn, Routes.character_template_path(conn, :update, character_template), character_template: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.character_template_path(conn, :show, id))

      assert %{
               "id" => id,
               "description" => "some updated description",
               "name" => "some updated name",
               "template" => "some updated template"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, character_template: character_template} do
      conn = put(conn, Routes.character_template_path(conn, :update, character_template), character_template: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete character_template" do
    setup [:create_character_template]

    test "deletes chosen character_template", %{conn: conn, character_template: character_template} do
      conn = delete(conn, Routes.character_template_path(conn, :delete, character_template))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.character_template_path(conn, :show, character_template))
      end
    end
  end

  defp create_character_template(_) do
    character_template = fixture(:character_template)
    %{character_template: character_template}
  end
end
