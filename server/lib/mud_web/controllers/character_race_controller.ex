defmodule MudWeb.CharacterRaceController do
  use MudWeb, :controller

  alias Mud.Engine.CharacterRace

  action_fallback(MudWeb.FallbackController)

  def index(conn, _params) do
    character_races = CharacterRace.list()
    render(conn, "index.json", character_races: character_races)
  end

  def create(conn, %{"character_race" => character_race_params}) do
    with {:ok, %CharacterRace{} = character_race} <- CharacterRace.create(character_race_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.character_race_path(conn, :show, character_race))
      |> render("show.json", character_race: character_race)
    end
  end

  def show(conn, %{"id" => id}) do
    character_race = CharacterRace.get!(id)
    render(conn, "show.json", character_race: character_race)
  end

  def update(conn, %{"id" => id, "character_race" => character_race_params}) do
    character_race = CharacterRace.get!(id)

    with {:ok, %CharacterRace{} = character_race} <-
           CharacterRace.update(character_race, character_race_params) do
      render(conn, "show.json", character_race: character_race)
    end
  end

  def delete(conn, %{"id" => id}) do
    character_race = CharacterRace.get!(id)

    with {:ok, %CharacterRace{}} <- CharacterRace.delete(character_race) do
      send_resp(conn, :no_content, "")
    end
  end
end
