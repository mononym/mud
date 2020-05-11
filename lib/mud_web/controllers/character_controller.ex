defmodule MudWeb.CharacterController do
  use MudWeb, :controller

  alias Mud.Engine
  alias Mud.Engine.Character

  def index(conn, _params) do
    characters = Engine.list_characters()
    render(conn, "index.html", characters: characters)
  end

  def new(conn, _params) do
    changeset = Character.changeset(%Character{}, %{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"character" => character_params}) do
    starting_area =
      Mud.Engine.list_areas()
      |> Enum.random()

    params =
      character_params
      |> Map.put("player_id", conn.assigns.player.id)
      |> Map.put("area_id", starting_area.id)

    case Engine.create_character(params) do
      {:ok, character} ->
        conn
        |> put_flash(:info, "Character created successfully.")
        |> redirect(to: Routes.character_path(conn, :edit, character))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    character = Engine.Character.get_by_id!(id)
    render(conn, "show.html", character: character)
  end

  def edit(conn, %{"id" => character_id}) do
    conn
    |> put_session(:character_id, character_id)
    |> put_layout("liveview_client_page.html")
    |> live_render(MudWeb.CharacterCreationWizardLive, session: %{"character_id" => character_id})
  end

  def play(conn, %{"character" => character_id}) do
    character = Engine.Character.get_by_id!(character_id)

    if character.player_id === conn.assigns.player.id do
      Mud.Engine.start_character_session(character_id)

      # Send a silent look command
      Mud.Engine.cast_message_to_character_session(%Mud.Engine.Input{
        id: UUID.uuid4(),
        character_id: character_id,
        text: "look",
        type: :silent
      })

      conn
      |> put_session(:character_id, character_id)
      |> put_layout("liveview_client_page.html")
      |> live_render(MudWeb.MudClientLive, character_id: character.id)
    else
      conn
      |> put_flash(:error, "You do not have permission to access that Character.")
      |> redirect(to: "/home")
    end
  end

  def update(conn, %{"id" => id, "character" => character_params}) do
    character = Engine.Character.get_by_id!(id)

    case Engine.update_character(character, character_params) do
      {:ok, character} ->
        conn
        |> put_flash(:info, "Character updated successfully.")
        |> redirect(to: Routes.character_path(conn, :show, character))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", character: character, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    character = Engine.Character.get_by_id!(id)
    {:ok, _character} = Engine.delete_character(character)

    conn
    |> put_flash(:info, "Character deleted successfully.")
    |> redirect(to: Routes.character_path(conn, :index))
  end
end
