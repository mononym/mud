defmodule MudWeb.CharacterCreationWizardLive do
  alias Mud.Engine.Model.Character
  use Phoenix.LiveView

  require Logger

  defmodule State do
    defstruct races: [],
              character: nil,
              character_created: false,
              selected_race: nil,
              race_chosen: false,
              name_chosen: false,
              changeset: nil,
              validating_name: false
  end

  def mount(_params, session, socket) do
    races =
      Mud.Engine.Rules.PlayerRaces.list_races()
      |> Enum.reduce(%{}, fn race, map -> Map.put(map, race.name, race) end)

    selected_race =
      races
      |> Enum.random()
      |> elem(1)

    state = %State{
      changeset: Character.new() |> Character.change(),
      races: races,
      selected_race: selected_race
    }

    socket =
      socket
      |> assign(:state, state)
      |> assign(:player, session["player"])

    {:ok, socket}
  end

  def render(assigns) do
    Logger.debug("Rendering CharacterCreationWizardLive")

    MudWeb.CharacterCreationWizardView.render("edit.html", assigns)
  end

  def handle_event("choose_name", form_data, socket) do
    Logger.debug("choose_name event received: #{inspect(form_data)}")

    attrs = Map.put(form_data["data"], "player_id", socket.assigns.player.id)

    case Character.create(attrs) do
      {:ok, character} ->
        Logger.debug(inspect(character))

        {:noreply,
         assign(socket,
           state: %{
             socket.assigns.state
             | character: character,
               name_chosen: true,
               validating_name: false,
               changeset: Character.change(character)
           }
         )}

      {:error, changeset} ->
        Logger.debug(inspect(changeset))

        {:noreply, update_state(socket, :changeset, changeset)}
    end
  end

  def handle_event("choose_features", form_data, socket) do
    Logger.debug("choose_features event received: #{inspect(form_data)}")

    attributes = %{
      eye_color: form_data["eye_color"],
      hair_color: form_data["hair_color"],
      skin_color: form_data["skin_color"],
      character_created: true
    }

    character =
      socket.assigns.state.character
      |> Character.update!(attributes)

    socket = update_state(socket, :character, character)

    {:noreply, redirect(socket, to: "/play/#{socket.assigns.state.character.id}")}
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

  def handle_event("choose_race", _, socket) do
    attributes = %{
      race: socket.assigns.state.selected_race.name
    }

    character =
      socket.assigns.state.character
      |> Character.update!(attributes)

    socket = update_state(socket, :character, character)

    {:noreply, update_state(socket, :race_chosen, true)}
  end

  defp select_race(index_adjustment, socket) do
    index =
      Enum.find_index(socket.assigns.state.races, fn {_, race} ->
        socket.assigns.state.selected_race.name == race.name
      end)

    race = get_race_at_index(Map.values(socket.assigns.state.races), index + index_adjustment)

    {:noreply, update_state(socket, :selected_race, race)}
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

  defp update_state(socket, key, value) do
    assign(socket, state: Map.put(socket.assigns.state, key, value))
  end
end
