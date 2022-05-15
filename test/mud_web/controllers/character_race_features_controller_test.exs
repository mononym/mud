defmodule MudWeb.CharacterRaceFeatureControllerTest do
  use MudWeb.ConnCase

  alias Mud.Engine.CharacterRaceFeature
  alias Mud.Engine.CharacterRaceFeature.CharacterRaceFeature

  @create_attrs %{
    name: "some name",
    type: "some type"
  }
  @update_attrs %{
    name: "some updated name",
    type: "some updated type"
  }
  @invalid_attrs %{name: nil, type: nil}

  def fixture(:character_race_feature) do
    {:ok, character_race_feature} =
      CharacterRaceFeature.create_character_race_feature(@create_attrs)

    character_race_feature
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all character_race_feature", %{conn: conn} do
      conn = get(conn, Routes.character_race_feature_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create character_race_feature" do
    test "renders character_race_feature when data is valid", %{conn: conn} do
      conn =
        post(conn, Routes.character_race_feature_path(conn, :create),
          character_race_feature: @create_attrs
        )

      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.character_race_feature_path(conn, :show, id))

      assert %{
               "id" => id,
               "name" => "some name",
               "type" => "some type"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn =
        post(conn, Routes.character_race_feature_path(conn, :create),
          character_race_feature: @invalid_attrs
        )

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update character_race_feature" do
    setup [:create_character_race_feature]

    test "renders character_race_feature when data is valid", %{
      conn: conn,
      character_race_feature: %CharacterRaceFeature{id: id} = character_race_feature
    } do
      conn =
        put(conn, Routes.character_race_feature_path(conn, :update, character_race_feature),
          character_race_feature: @update_attrs
        )

      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.character_race_feature_path(conn, :show, id))

      assert %{
               "id" => id,
               "name" => "some updated name",
               "type" => "some updated type"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{
      conn: conn,
      character_race_feature: character_race_feature
    } do
      conn =
        put(conn, Routes.character_race_feature_path(conn, :update, character_race_feature),
          character_race_feature: @invalid_attrs
        )

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete character_race_feature" do
    setup [:create_character_race_feature]

    test "deletes chosen character_race_feature", %{
      conn: conn,
      character_race_feature: character_race_feature
    } do
      conn =
        delete(conn, Routes.character_race_feature_path(conn, :delete, character_race_feature))

      assert response(conn, 204)

      assert_error_sent(404, fn ->
        get(conn, Routes.character_race_feature_path(conn, :show, character_race_feature))
      end)
    end
  end

  defp create_character_race_feature(_) do
    character_race_feature = fixture(:character_race_feature)
    %{character_race_feature: character_race_feature}
  end
end
