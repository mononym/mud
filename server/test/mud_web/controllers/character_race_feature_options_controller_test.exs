defmodule MudWeb.CharacterRaceFeatureOptionControllerTest do
  use MudWeb.ConnCase

  alias Mud.Engine.CharacterRaceFeatureOption
  alias Mud.Engine.CharacterRaceFeatureOption.CharacterRaceFeatureOption

  @create_attrs %{
    conditions: %{},
    option: "some option"
  }
  @update_attrs %{
    conditions: %{},
    option: "some updated option"
  }
  @invalid_attrs %{conditions: nil, option: nil}

  def fixture(:character_race_feature_options) do
    {:ok, character_race_feature_options} =
      CharacterRaceFeatureOption.create_character_race_feature_options(@create_attrs)

    character_race_feature_options
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all character_race_feature_options", %{conn: conn} do
      conn = get(conn, Routes.character_race_feature_options_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create character_race_feature_options" do
    test "renders character_race_feature_options when data is valid", %{conn: conn} do
      conn =
        post(conn, Routes.character_race_feature_options_path(conn, :create),
          character_race_feature_options: @create_attrs
        )

      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.character_race_feature_options_path(conn, :show, id))

      assert %{
               "id" => id,
               "conditions" => %{},
               "option" => "some option"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn =
        post(conn, Routes.character_race_feature_options_path(conn, :create),
          character_race_feature_options: @invalid_attrs
        )

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update character_race_feature_options" do
    setup [:create_character_race_feature_options]

    test "renders character_race_feature_options when data is valid", %{
      conn: conn,
      character_race_feature_options:
        %CharacterRaceFeatureOption{id: id} = character_race_feature_options
    } do
      conn =
        put(
          conn,
          Routes.character_race_feature_options_path(
            conn,
            :update,
            character_race_feature_options
          ),
          character_race_feature_options: @update_attrs
        )

      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.character_race_feature_options_path(conn, :show, id))

      assert %{
               "id" => id,
               "conditions" => %{},
               "option" => "some updated option"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{
      conn: conn,
      character_race_feature_options: character_race_feature_options
    } do
      conn =
        put(
          conn,
          Routes.character_race_feature_options_path(
            conn,
            :update,
            character_race_feature_options
          ),
          character_race_feature_options: @invalid_attrs
        )

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete character_race_feature_options" do
    setup [:create_character_race_feature_options]

    test "deletes chosen character_race_feature_options", %{
      conn: conn,
      character_race_feature_options: character_race_feature_options
    } do
      conn =
        delete(
          conn,
          Routes.character_race_feature_options_path(
            conn,
            :delete,
            character_race_feature_options
          )
        )

      assert response(conn, 204)

      assert_error_sent(404, fn ->
        get(
          conn,
          Routes.character_race_feature_options_path(conn, :show, character_race_feature_options)
        )
      end)
    end
  end

  defp create_character_race_feature_options(_) do
    character_race_feature_options = fixture(:character_race_feature_options)
    %{character_race_feature_options: character_race_feature_options}
  end
end
