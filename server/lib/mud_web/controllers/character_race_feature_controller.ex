defmodule MudWeb.CharacterRaceFeatureController do
  use MudWeb, :controller

  alias Mud.Engine.CharacterRaceFeature

  action_fallback(MudWeb.FallbackController)

  def index(conn, _params) do
    character_race_feature = CharacterRaceFeature.list()
    render(conn, "index.json", character_race_feature: character_race_feature)
  end

  def create(conn, character_race_feature_params) do
    with {:ok, %CharacterRaceFeature{} = character_race_feature} <-
           CharacterRaceFeature.create(character_race_feature_params) do
      conn
      |> put_status(:created)
      |> render("show.json", character_race_feature: character_race_feature)
    end
  end

  def show(conn, %{"id" => id}) do
    character_race_feature = CharacterRaceFeature.get!(id)
    render(conn, "show.json", character_race_feature: character_race_feature)
  end

  def update(conn, character_race_feature_params = %{"id" => id}) do
    character_race_feature = CharacterRaceFeature.get!(id)

    with {:ok, %CharacterRaceFeature{} = character_race_feature} <-
           CharacterRaceFeature.update(character_race_feature, character_race_feature_params) do
      render(conn, "show.json", character_race_feature: character_race_feature)
    end
  end

  def delete(conn, %{"id" => id}) do
    character_race_feature = CharacterRaceFeature.get!(id)

    with {:ok, %CharacterRaceFeature{}} <- CharacterRaceFeature.delete(character_race_feature) do
      send_resp(conn, :no_content, "")
    end
  end
end
