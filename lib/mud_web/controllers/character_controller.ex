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
    starting_location =
      Mud.Engine.list_areas()
      |> Enum.random()

    params =
      character_params
      |> Map.put("player_id", conn.assigns.player.id)
      |> Map.put("location_id", starting_location.id)

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
    character = Engine.get_character!(id)
    render(conn, "show.html", character: character)
  end

  def edit(conn, %{"id" => id}) do
    character = Engine.get_character!(id)
    changeset = Engine.change_character(character)
    render(conn, "edit.html", character: character, changeset: changeset)
  end

  def update(conn, %{"id" => id, "character" => character_params}) do
    character = Engine.get_character!(id)

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
    character = Engine.get_character!(id)
    {:ok, _character} = Engine.delete_character(character)

    conn
    |> put_flash(:info, "Character deleted successfully.")
    |> redirect(to: Routes.character_path(conn, :index))
  end
end
