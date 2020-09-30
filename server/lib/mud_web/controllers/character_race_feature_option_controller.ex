defmodule MudWeb.CharacterRaceFeatureOptionController do
  use MudWeb, :controller

  alias Mud.Engine.CharacterRaceFeatureOption

  action_fallback(MudWeb.FallbackController)

  def index(conn, _params) do
    character_race_feature_options = CharacterRaceFeatureOption.list()

    render(conn, "index.json", character_race_feature_options: character_race_feature_options)
  end

  def create(conn, character_race_feature_options_params) do
    with {:ok, %CharacterRaceFeatureOption{} = character_race_feature_options} <-
           CharacterRaceFeatureOption.create(character_race_feature_options_params) do
      conn
      |> put_status(:created)
      |> render("show.json", character_race_feature_options: character_race_feature_options)
    end
  end

  def show(conn, %{"id" => id}) do
    character_race_feature_options = CharacterRaceFeatureOption.get!(id)

    render(conn, "show.json", character_race_feature_options: character_race_feature_options)
  end

  def update(conn, character_race_feature_options_params = %{"id" => id}) do
    character_race_feature_options = CharacterRaceFeatureOption.get!(id)

    with {:ok, %CharacterRaceFeatureOption{} = character_race_feature_options} <-
           CharacterRaceFeatureOption.update(
             character_race_feature_options,
             character_race_feature_options_params
           ) do
      render(conn, "show.json", character_race_feature_options: character_race_feature_options)
    end
  end

  def delete(conn, %{"id" => id}) do
    character_race_feature_options = CharacterRaceFeatureOption.get!(id)

    with {:ok, %CharacterRaceFeatureOption{}} <-
           CharacterRaceFeatureOption.delete(character_race_feature_options) do
      send_resp(conn, :no_content, "")
    end
  end
end
