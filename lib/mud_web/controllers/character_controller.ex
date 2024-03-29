defmodule MudWeb.CharacterController do
  use MudWeb, :controller

  alias Mud.Engine.{Character}
  alias Mud.Engine.Character.Settings

  require Logger

  action_fallback(MudWeb.FallbackController)

  def index(conn, _params) do
    characters = Character.list_all()
    render(conn, "index.html", characters: characters)
  end

  def list_player_characters(conn, %{"player_id" => player_id}) do
    characters = Character.list_by_player_id(player_id)
    render(conn, "index.json", characters: characters)
  end

  def new(conn, _params) do
    conn
    |> put_layout("liveview_client_page.html")
    |> live_render(
      MudWeb.CharacterCreationWizardLive,
      session: %{"player" => conn.assigns.player}
    )
  end

  def create(conn, character_params) do
    params =
      character_params
      |> Recase.Enumerable.convert_keys(&Recase.to_snake/1)
      |> Map.put("player_id", conn.assigns.player_id)

    case Character.create(params) do
      {:ok, character} ->
        conn
        |> put_status(201)
        |> render("show.json", character: character)

      {:error, changeset} ->
        if Mud.Util.changeset_has_error?(changeset, :player_id, "does not exist") do
          resp(conn, 401, "invalid session")
        else
          resp(conn, 400, "error")
        end
    end
  end

  @spec show(Plug.Conn.t(), map) :: Plug.Conn.t()
  def show(conn, %{"id" => id}) do
    character = Character.get_by_id!(id)
    render(conn, "show.html", character: character)
  end

  def edit(conn, %{"id" => character_id}) do
    character = Character.get_by_id!(character_id)
    render(conn, "edit.html", character: character)
  end

  # def play(conn, %{"character" => character_id}) do
  #   character = Character.get_by_id!(character_id)

  #   if character.player_id === conn.assigns.player.id do
  #     Session.start(character_id)

  #     Logger.debug("sending silent look")

  #     # Send a silent look command
  #     Session.cast_message_or_event(%Mud.Engine.Message.Input{
  #       id: UUID.uuid4(),
  #       to: character_id,
  #       text: "look",
  #       type: :silent
  #     })

  #     conn
  #     |> put_session(:character_id, character_id)
  #     |> put_layout("liveview_client_page.html")
  #     |> live_render(MudWeb.MudClientLive, character_id: character.id)
  #   else
  #     conn
  #     |> redirect(to: "/home")
  #   end
  # end

  def update_settings(conn, %{"settings_id" => id, "settings" => character_settings}) do
    settings = Settings.get!(id)

    case Settings.update(
           settings,
           Recase.Enumerable.convert_keys(character_settings, &Recase.to_snake/1)
         ) do
      {:ok, settings} ->
        conn
        |> put_view(MudWeb.CharacterSettingsView)
        |> render("character_settings.json", character_settings: settings)

      {:error, _changeset} ->
        resp(conn, 400, "error")
    end
  end

  # def update(conn, %{"id" => id, "character" => character_params}) do
  #   character = Character.get_by_id!(id)

  #   case Character.update(character, character_params) do
  #     {:ok, character} ->
  #       conn
  #       |> put_flash(:info, "Character updated successfully.")
  #       |> redirect(to: Routes.character_path(conn, :show, character))

  #     {:error, %Ecto.Changeset{} = changeset} ->
  #       render(conn, "edit.html", character: character, changeset: changeset)
  #   end
  # end

  def delete(conn, %{"character_id" => id}) do
    character = Character.get_by_id!(id)
    {:ok, _character} = Character.delete(character)

    conn
    |> resp(200, "ok")
    |> send_resp()
  end

  def get_creation_data(conn, _) do
    races = Mud.Engine.Rules.PlayerRaces.races()

    conn
    |> put_status(200)
    |> render("character-creation-data.json", races: Map.values(races))
  end
end
