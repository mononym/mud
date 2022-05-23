defmodule MudWeb.ClientLive.Play do
  use MudWeb, :client_live_view

  alias Mud.Engine.{Area, Character, Event, Session}
  alias Mud.Engine
  alias Mud.Engine.Event.Client.{UpdateArea, UpdateCharacter, UpdateTime}
  alias Mud.Engine.Message.StoryOutput

  import MudWeb.PlayLive.Util

  require Logger

  @impl true
  def mount(%{"character_name" => character_name}, _session, socket) do
    character = Character.get_by_name(character_name)

    if not is_nil(character) and character.player_id == socket.assigns.current_player.id do
      Engine.start_character_session(character.id)
      Engine.Session.subscribe(character.id)

      # Send a silent look command
      Engine.Session.cast_message_or_event(%Engine.Message.Input{
        id: UUID.uuid4(),
        to: character.id,
        text: "look",
        type: :silent
      })

      {:ok,
       assign(socket,
         character: character,
         page_title: "#{character.name}",
         hour: 0,
         time_string: "Unknown...",
         weather_string: "Clear Skies",
         story_output: [],
         current_area: %Area{},
         current_area_items_of_interest: [],
         current_area_items_on_ground: [],
         current_area_characters: [],
         current_area_exits: []
       ), temporary_assigns: [story_output: []]}
    else
      {:ok,
       socket
       |> put_flash(:error, "You can only play characters which belong to you.")
       |> push_redirect(to: Routes.home_show_path(socket, :show))}
    end
  end

  @impl true
  def handle_cast(%StoryOutput{} = output, socket) do
    {:noreply, assign(socket, story_output: [output])}
  end

  @impl true
  def handle_cast(%UpdateArea{action: :look} = event, socket) do
    toi = Enum.filter(event.items, & &1.flags.scenery)
    items_on_ground = Enum.filter(event.items, & (not &1.flags.scenery))
    {:noreply,
     assign(socket,
       current_area: event.area,
       current_area_characters: event.other_characters,
       current_area_items_of_interest: toi,
       current_area_items_on_ground: items_on_ground,
       current_area_exits: event.exits
     )}
  end

  @impl true
  def handle_cast(%UpdateCharacter{} = event, socket) do
    {:noreply, assign(socket, character: event.character)}
  end

  @impl true
  def handle_cast(%UpdateTime{time_string: time_string}, socket) do
    {:noreply, assign(socket, time_string: time_string)}
  end

  @impl true
  def handle_cast(event, socket) do
    IO.inspect(event, label: :handle_event)
    {:noreply, socket}
  end

  @impl true
  def handle_event("submit_text_input", %{"input" => %{"text" => ""}}, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("submit_text_input", %{"input" => %{"text" => text_input}}, socket) do
    Session.cast_message_or_event(%Mud.Engine.Message.Input{
      to: socket.assigns.character.id,
      text: text_input,
      id: UUID.uuid4()
    })

    {:noreply, socket}
  end

  #
  # Internal functions
  #
end
