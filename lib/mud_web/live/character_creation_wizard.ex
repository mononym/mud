defmodule MudWeb.CharacterCreationWizardLive do
  alias MudWeb.Schema.CharacterCreationForm
  alias Mud.Engine.Model.Character
  use Phoenix.LiveView

  require Logger

  def mount(_params, session, socket) do
    character = Character.get_by_id!(session["character_id"])

    races =
      Mud.Engine.Rules.PlayerRaces.list_races()
      |> Enum.reduce(%{}, fn race, map -> Map.put(map, race.name, race) end)

    selected_race =
      if character.race != nil do
        races[character.race]
      else
        races
        |> Enum.random()
        |> elem(1)
      end

    socket =
      socket
      |> assign(:races, races)
      |> assign(:character, character)
      |> assign(:character_created, false)
      |> assign(:selected_race, selected_race)
      |> assign(:race_accepted, false)
      |> assign(:character_creation_form_changeset, CharacterCreationForm.new())

    {:ok, socket}
  end

  def render(assigns) do
    Logger.debug("Rendering CharacterCreationWizardLive")

    MudWeb.CharacterCreationWizardView.render("edit.html", assigns)
  end

  def handle_event("create_character", form_data, socket) do
    Logger.debug("create_character event received: #{inspect(form_data)}")

    attributes = %{
      race: socket.assigns.selected_race.name,
      eye_color: form_data["eye_color"],
      hair_color: form_data["hair_color"],
      skin_color: form_data["skin_color"],
      character_created: true
    }

    socket.assigns.character
    |> Character.changeset(attributes)
    |> Character.update()

    {:noreply, redirect(socket, to: "/play/#{socket.assigns.character.id}")}
  end

  def handle_event("hotkey", event, socket) do
    Logger.debug("hotkey event received: #{inspect(event)}")

    process_hotkey(event, socket)
  end

  def handle_event("previous_race", _, socket) do
    select_race(-1, socket)
  end

  def handle_event("next_race", _, socket) do
    select_race(1, socket)
  end

  def handle_event("accept_race", _, socket) do
    {:noreply, assign(socket, :race_accepted, true)}
  end

  defp select_race(index_adjustment, socket) do
    index =
      Enum.find_index(socket.assigns.races, fn {_, race} ->
        socket.assigns.selected_race.name == race.name
      end)

    race = get_race_at_index(Map.values(socket.assigns.races), index + index_adjustment)

    {:noreply, assign(socket, :selected_race, race)}
  end

  defp get_race_at_index(races, index) when index >= length(races) do
    Enum.at(races, 0)
  end

  defp get_race_at_index(races, index) do
    Logger.debug("index is #{inspect(index)}")
    Enum.at(races, index)
  end

  defp process_hotkey(%{"code" => "Enter"}, socket) do
    {:noreply, assign(socket, :race_accepted, true)}
  end

  defp process_hotkey(%{"code" => "ArrowLeft"}, socket) do
    select_race(-1, socket)
  end

  defp process_hotkey(%{"code" => "ArrowRight"}, socket) do
    select_race(1, socket)
  end

  defp process_hotkey(_, socket) do
    {:noreply, socket}
  end
end
