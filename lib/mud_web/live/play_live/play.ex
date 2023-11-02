defmodule MudWeb.ClientLive.Play do
  use MudWeb, :client_live_view

  alias Mud.Engine.{Area, Character, Event, Item, Session}
  alias Mud.Engine

  alias Mud.Engine.Event.Client.{
    CloseSession,
    UpdateArea,
    UpdateCharacter,
    UpdateExploredArea,
    UpdateExploredMap,
    UpdateInventory,
    UpdateMap,
    UpdateTime
  }

  alias Mud.Engine.Message.StoryOutput
  alias Mud.Engine.Item.Closable
  alias Mud.Engine.Map.Label

  import MudWeb.PlayLive.Util

  require Logger

  @impl true
  def mount(%{"character_name" => character_name}, _session, socket) do
    character = Character.get_by_name(character_name)

    if not is_nil(character) and character.player_id == socket.assigns.current_player.id do
      if connected?(socket) do
        inventory =
          Item.list_held_or_worn_items_and_children(character.id)
          |> Enum.into(%{}, fn item -> {item.id, item} end)

        # Area the player is currently in
        character_area = Area.get!(character.area_id)
        # Map data for the map the player is currently in
        map_data = Engine.Map.fetch_character_data(character.id, character_area.map_id)
        map_areas = Enum.into(map_data.areas, %{}, &{&1.id, &1})
        map_links = Enum.into(map_data.links, %{}, &{&1.id, &1})
        map = Engine.Map.get!(character_area.map_id)
        map_labels = Label.get_map_labels(map.id)
        # All known maps for player
        maps = Enum.into(Character.load_known_maps(character.id), %{}, &{&1.id, &1})

        Engine.start_character_session(character.id)
        Engine.Session.subscribe(character.id)

        # Send a silent look command
        Engine.Session.cast_message_or_event(%Engine.Message.Input{
          id: UUID.uuid4(),
          to: character.id,
          text: "look",
          type: :silent
        })

        time = Mud.Engine.System.Time.get_time()

        {:ok,
         assign(socket,
           character: character,
           page_title: "#{character.name}",
           hour: 0,
           time_string: time.time_string,
           weather_string: "Clear Skies",
           story_output: [],
           current_area: %Area{},
           current_area_items: %{},
           current_area_characters: [],
           current_area_exits: [],
           map: character_area.map_id,
           map_current_area_id: character.area_id,
           maps: maps,
           map_labels: map_labels,
           map_areas: map_areas,
           map_links: map_links,
           map_explored_areas: MapSet.new(map_data.explored_areas),
           inventory: inventory
         ), temporary_assigns: [story_output: []]}
      else
        {:ok,
         assign(socket,
           character: character,
           page_title: "#{character.name}",
           hour: 0,
           time_string: "Unknown...",
           weather_string: "Clear Skies",
           story_output: [],
           current_area: %Area{},
           current_area_items: %{},
           current_area_characters: [],
           current_area_exits: [],
           map: "",
           maps: %{},
           map_labels: [],
           map_areas: %{},
           map_links: %{},
           map_explored_areas: MapSet.new(),
           map_current_area_id: "",
           inventory: %{}
         ), temporary_assigns: [story_output: []]}
      end
    else
      {:ok,
       socket
       |> put_flash(:error, "You can only play characters which belong to you.")
       |> push_redirect(to: Routes.home_show_path(socket, :show))}
    end
  end

  @impl true
  def handle_cast([%StoryOutput{} = output | _] = multiple_outputs, socket) do
    Logger.debug("Received multiple story outputs: #{inspect(multiple_outputs)}")
    {:noreply, assign(socket, story_output: multiple_outputs)}
  end

  @impl true
  def handle_cast(%StoryOutput{} = output, socket) do
    Logger.debug("Received story output: #{inspect(output)}")
    {:noreply, assign(socket, story_output: [output])}
  end

  @impl true
  def handle_cast(%UpdateArea{action: :look} = event, socket) do
    Logger.debug("Received update area with look action: #{inspect(event)}")
    all_items_map = Enum.into(event.items, %{}, &{&1.id, &1})

    {:noreply,
     assign(socket,
       current_area: event.area,
       current_area_characters: event.other_characters,
       current_area_items: all_items_map,
       current_area_exits: event.exits
     )}
  end

  @impl true
  def handle_cast(%UpdateArea{action: action} = event, socket) when action in [:add, :update] do
    Logger.debug("Received update area with add action: #{inspect(event)}")
    all_items_map = Enum.into(event.items, %{}, &{&1.id, &1})

    {:noreply,
     assign(socket,
       current_area_characters:
         Enum.uniq_by(event.other_characters ++ socket.assigns.current_area_characters, & &1),
       current_area_items: Map.merge(socket.assigns.current_area_items, all_items_map),
       current_area_exits: Enum.uniq_by(event.exits ++ socket.assigns.current_area_exits, & &1.id)
     )}
  end

  @impl true
  def handle_cast(%UpdateArea{action: :remove} = event, socket) do
    Logger.debug("Received update area with remove action: #{inspect(event)}")
    items_to_remove = Enum.map(event.items, & &1.id)
    characters_to_remove = Enum.map(event.other_characters, & &1.id)
    exits_to_remove = Enum.map(event.exits, & &1.id)

    {:noreply,
     assign(socket,
       current_area_characters:
         Enum.filter(socket.assigns.current_area_characters, &(&1.id not in characters_to_remove)),
       current_area_items: Map.drop(socket.assigns.current_area_items, items_to_remove),
       current_area_exits:
         Enum.filter(socket.assigns.current_area_exits, &(&1.id not in exits_to_remove))
     )}
  end

  @impl true
  def handle_cast(%UpdateInventory{action: action} = event, socket)
      when action in [:add, :update] do
    Logger.debug("Received update inventory with add action: #{inspect(event)}")
    new_inventory = Enum.into(event.items, %{}, &{&1.id, &1})
    {:noreply, assign(socket, inventory: Map.merge(socket.assigns.inventory, new_inventory))}
  end

  @impl true
  def handle_cast(%UpdateInventory{action: :remove} = event, socket) do
    Logger.debug("Received update inventory with remove action: #{inspect(event)}")
    old_inventory_ids = Enum.map(event.items, & &1.id)
    {:noreply, assign(socket, inventory: Map.drop(socket.assigns.inventory, old_inventory_ids))}
  end

  @impl true
  def handle_cast(%UpdateCharacter{action: :settings} = event, socket) do
    Logger.debug("Received update character: #{inspect(event)}")

    {:noreply,
     assign(socket, character: Map.put(socket.assigns.character, :settings, event.settings))}
  end

  @impl true
  def handle_cast(%UpdateCharacter{action: "character"} = event, socket) do
    Logger.debug("Received update character: #{inspect(event)}")
    {:noreply, assign(socket, character: event.character)}
  end

  @impl true
  def handle_cast(%UpdateCharacter{action: "wealth"} = event, socket) do
    Logger.debug("Received update character: #{inspect(event)}")

    {:noreply,
     assign(socket, character: Map.put(socket.assigns.character, :wealth, event.wealth))}
  end

  @impl true
  def handle_cast(%UpdateTime{time_string: time_string} = event, socket) do
    Logger.debug("Received update time: #{inspect(event)}")
    {:noreply, assign(socket, time_string: time_string)}
  end

  # @impl true
  # def handle_cast(%UpdateExploredMap{action: :add} = event, socket) do
  #   Logger.debug("Received update explored maps: #{inspect(event)}")
  #   maps = Enum.into(event.maps, %{}, &{&1.id, &1})
  #   {:noreply, assign(socket, maps: Map.merge(maps, socket.assigns.maps))}
  # end

  # @impl true
  # def handle_cast(%UpdateExploredArea{} = event, socket) do
  #   Logger.debug("Received UpdateExploredArea: #{inspect(event)}")

  #   new_explored_areas =
  #     Enum.reduce(event.explored, socket.assigns.map_explored_areas, fn explored, set ->
  #       MapSet.put(set, explored)
  #     end)

  #   areas = Enum.into(event.areas, %{}, &{&1.id, &1})
  #   links = Enum.into(event.links, %{}, &{&1.id, &1})

  #   {:noreply,
  #    assign(socket,
  #      map_explored_areas: new_explored_areas,
  #      map_areas: Map.merge(socket.assigns.map_areas, areas),
  #      map_links: Map.merge(socket.assigns.map_links, links)
  #    )}
  # end

  @impl true
  def handle_cast(%UpdateMap{action: :move} = event, socket) do
    Logger.debug("Received update map: #{inspect(event)}")

    if event.map_id != socket.assigns.map do
      areas = Enum.into(event.areas, %{}, &{&1.id, &1})
      links = Enum.into(event.links, %{}, &{&1.id, &1})
      explored_areas = MapSet.new(event.explored_areas)
      map_labels = Label.get_map_labels(event.map_id)
      maps = Enum.into(event.maps, %{}, &{&1.id, &1})

      {:noreply,
       assign(socket,
         maps: Map.merge(socket.assigns.maps, maps),
         map: event.map_id,
         map_areas: areas,
         map_links: links,
         map_explored_areas: explored_areas,
         map_labels: map_labels,
         map_current_area_id: event.area_id
       )}
    else
      areas = Enum.into(event.areas, %{}, &{&1.id, &1})
      links = Enum.into(event.links, %{}, &{&1.id, &1})

      new_explored_areas =
        Enum.reduce(event.explored_areas, socket.assigns.map_explored_areas, fn explored, set ->
          MapSet.put(set, explored)
        end)

      {:noreply,
       assign(socket,
         map_current_area_id: event.area_id,
         map_areas: Map.merge(socket.assigns.map_areas, areas),
         map_links: Map.merge(socket.assigns.map_links, links),
         map_explored_areas: new_explored_areas,
       )}
    end
  end

  @impl true
  def handle_cast(%CloseSession{action: :quit} = event, socket) do
    Logger.debug("Received close session: #{inspect(event)}")
    {:noreply, push_redirect(socket, to: Routes.home_show_path(socket, :show))}
  end

  @impl true
  def handle_cast(event, socket) do
    IO.inspect(event, label: :handle_event)
    {:noreply, socket}
  end

  @impl true
  def handle_event("toggle_item_close", %{"item_id" => item_id}, socket) do
    item = socket.assigns.inventory[item_id] || socket.assigns.current_area_items[item_id]
    closable = item.closable

    command =
      if closable.open do
        "close"
      else
        "open"
      end

    Engine.Session.cast_message_or_event(%Engine.Message.Input{
      id: UUID.uuid4(),
      to: socket.assigns.character.id,
      text: "#{command} #{item.id}",
      type: :silent
    })

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

  @impl true
  def handle_info(%UpdateCharacter{action: :settings} = event, socket) do
    Logger.debug("Received update character: #{inspect(event)}")

    {:noreply,
     assign(socket, character: Map.put(socket.assigns.character, :settings, event.settings))}
  end

  #
  # Internal functions
  #
end
