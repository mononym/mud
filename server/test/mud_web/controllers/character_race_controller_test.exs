defmodule MudWeb.CharacterRaceControllerTest do
  use MudWeb.ConnCase

  alias Mud.Engine.CharacterRace
  alias Mud.Engine.CharacterRace.CharacterRace

  @create_attrs %{
    adjective: "some adjective",
    description: "some description",
    plural: "some plural",
    portrait: "some portrait",
    singular: "some singular"
  }
  @update_attrs %{
    adjective: "some updated adjective",
    description: "some updated description",
    plural: "some updated plural",
    portrait: "some updated portrait",
    singular: "some updated singular"
  }
  @invalid_attrs %{adjective: nil, description: nil, plural: nil, portrait: nil, singular: nil}

  def fixture(:character_race) do
    {:ok, character_race} = CharacterRace.create_character_race(@create_attrs)
    character_race
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all character_races", %{conn: conn} do
      conn = get(conn, Routes.character_race_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create character_race" do
    test "renders character_race when data is valid", %{conn: conn} do
      conn = post(conn, Routes.character_race_path(conn, :create), character_race: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.character_race_path(conn, :show, id))

      assert %{
               "id" => id,
               "adjective" => "some adjective",
               "description" => "some description",
               "plural" => "some plural",
               "portrait" => "some portrait",
               "singular" => "some singular"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.character_race_path(conn, :create), character_race: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update character_race" do
    setup [:create_character_race]

    test "renders character_race when data is valid", %{conn: conn, character_race: %CharacterRace{id: id} = character_race} do
      conn = put(conn, Routes.character_race_path(conn, :update, character_race), character_race: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.character_race_path(conn, :show, id))

      assert %{
               "id" => id,
               "adjective" => "some updated adjective",
               "description" => "some updated description",
               "plural" => "some updated plural",
               "portrait" => "some updated portrait",
               "singular" => "some updated singular"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, character_race: character_race} do
      conn = put(conn, Routes.character_race_path(conn, :update, character_race), character_race: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete character_race" do
    setup [:create_character_race]

    test "deletes chosen character_race", %{conn: conn, character_race: character_race} do
      conn = delete(conn, Routes.character_race_path(conn, :delete, character_race))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.character_race_path(conn, :show, character_race))
      end
    end
  end

  defp create_character_race(_) do
    character_race = fixture(:character_race)
    %{character_race: character_race}
  end
end
