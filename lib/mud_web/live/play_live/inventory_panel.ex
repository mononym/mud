defmodule MudWeb.PlayLive.InventoryPanel do
  use MudWeb, :live_component

  alias Ecto.Changeset
  alias Mud.Engine.{Area, Character}
  alias Mud.Engine.Character.Settings
  alias MudWeb.PlayLive.Util
  alias Mud.Engine.Event.Client.UpdateCharacter

  import MudWeb.PlayLive.Util
  import MudWeb.PlayLive.Components

  require Logger

  # held items
  # worn containers
  # worn items
  # slots

  @impl true
  def mount(socket) do
    {:ok,
     assign(socket,
       inventory: %{},
       held_item_left_hand_id: nil,
       held_item_right_hand_id: nil,
       worn_equipment_ids: [],
       worn_armor_ids: [],
       worn_clothes_ids: [],
       worn_weapons_ids: [],
       worn_jewelry_ids: [],
       held_items_collapsed: false,
       worn_equipment_collapsed: false,
       worn_items_collapsed: false,
       slots_collapsed: false,
       worn_armor_collapsed: false,
       worn_clothes_collapsed: false,
       worn_weapons_collapsed: false,
       worn_jewelry_collapsed: false,
       parent_child_ids_map: %{},
       slot_collapsed: %{
        "on_back" => false,
        "around_waist" => false,
        "on_belt" => false,
        "on_finger" => false,
        "over_shoulders" => false,
        "over_shoulder" => false,
        "on_head" => false,
        "in_hair" => false,
        "on_hair" => false,
        "around_neck" => false,
        "on_torso" => false,
        "on_legs" => false,
        "on_feet" => false,
        "on_hands" => false,
        "on_thigh" => false,
        "on_ankle" => false
       }
     )}
  end

  @impl true
  def update(assigns, socket) do
    socket = assign(socket, assigns)

    {:ok, process_inventory(socket)}
  end

  @impl true
  def handle_event("toggle_held_items", _params, socket) do
    {:noreply,
     assign(socket,
       held_items_collapsed: not socket.assigns.held_items_collapsed
     )}
  end

  @impl true
  def handle_event("toggle_worn_containers", _params, socket) do
    {:noreply,
     assign(socket,
     worn_containers_collapsed: not socket.assigns.worn_containers_collapsed
     )}
  end

  @impl true
  def handle_event("toggle_worn_weapons", _params, socket) do
    {:noreply,
     assign(socket,
     worn_weapons_collapsed: not socket.assigns.worn_weapons_collapsed
     )}
  end

  @impl true
  def handle_event("toggle_worn_armor", _params, socket) do
    {:noreply,
     assign(socket,
     worn_armor_collapsed: not socket.assigns.worn_armor_collapsed
     )}
  end

  @impl true
  def handle_event("toggle_worn_clothes", _params, socket) do
    {:noreply,
     assign(socket,
     worn_clothes_collapsed: not socket.assigns.worn_clothes_collapsed
     )}
  end

  @impl true
  def handle_event("toggle_worn_jewelry", _params, socket) do
    {:noreply,
     assign(socket,
     worn_jewelry_collapsed: not socket.assigns.worn_jewelry_collapsed
     )}
  end

  @impl true
  def handle_event("toggle_worn_equipment", _params, socket) do
    {:noreply,
     assign(socket,
     worn_equipment_collapsed: not socket.assigns.worn_equipment_collapsed
     )}
  end

  @impl true
  def handle_event("toggle_slots", _params, socket) do
    {:noreply,
     assign(socket,
     slots_collapsed: not socket.assigns.slots_collapsed
     )}
  end

  @impl true
  def handle_event("toggle_slot", %{"slot" => slot}, socket) do
    {:noreply,
     assign(socket,
     slot_collapsed: Map.put(socket.assigns.slot_collapsed, slot, not socket.assigns.slot_collapsed[slot])
     )}
  end

  @impl true
  def handle_event("toggle_show", %{"toggle" => toggle_field}, socket) do
    settings = socket.assigns.settings
    attrs = %{inventory_window: %{toggle_field => not Map.get(settings.inventory_window, String.to_existing_atom(toggle_field))}}
    updated_settings = Settings.update!(settings, attrs)

    send(self(), UpdateCharacter.new(%{action: :settings, settings: updated_settings}))

    {:noreply, socket}
  end

  #
  # Internal Functions
  #
  defp process_inventory(socket) do
    socket
    |> build_held_items_ids_list()
    |> build_worn_equipment_ids_list()
    |> build_parent_child_id_map()
    |> build_worn_clothes_ids_list()
    |> build_worn_armor_ids_list()
    |> build_worn_weapons_ids_list()
    |> build_worn_jewelry_ids_list()
    |> build_slots_ids_map()
  end

  defp build_parent_child_id_map(socket) do
    parent_child_map = Util.build_parent_child_map(socket.assigns.inventory)

    assign(socket, parent_child_ids_map: parent_child_map)
  end

  defp build_held_items_ids_list(socket) do
    held_items =
      socket.assigns.inventory
      |> Map.values()
      |> Enum.filter(& &1.location.held_in_hand)

    socket = assign(socket, held_item_left_hand_id: nil, held_item_right_hand_id: nil)

    Enum.reduce(held_items, socket, fn item, sock ->
      if item.location.hand == "left" do
        assign(sock, held_item_left_hand_id: item.id)
      else
        assign(sock, held_item_right_hand_id: item.id)
      end
    end)
  end

  defp build_worn_equipment_ids_list(socket) do
    worn_equipment_ids =
      socket.assigns.inventory
      |> Map.values()
      |> Enum.filter(& &1.flags.is_wearable and &1.flags.is_equipment and &1.location.worn_on_character)
      |> sort_by_moved_at()
      |> Enum.map(& &1.id)

    assign(socket, worn_equipment_ids: worn_equipment_ids)
  end

  defp build_worn_clothes_ids_list(socket) do
    worn_clothes_ids =
      socket.assigns.inventory
      |> Map.values()
      |> Enum.filter(& &1.flags.is_wearable and &1.flags.is_clothing and &1.location.worn_on_character)
      |> sort_by_moved_at()
      |> Enum.map(& &1.id)

    assign(socket, worn_clothes_ids: worn_clothes_ids)
  end

  defp build_worn_armor_ids_list(socket) do
    worn_armor_ids =
      socket.assigns.inventory
      |> Map.values()
      |> Enum.filter(& &1.flags.is_wearable and &1.flags.is_armor and &1.location.worn_on_character)
      |> sort_by_moved_at()
      |> Enum.map(& &1.id)

    assign(socket, worn_armor_ids: worn_armor_ids)
  end

  defp build_worn_weapons_ids_list(socket) do
    worn_weapons_ids =
      socket.assigns.inventory
      |> Map.values()
      |> Enum.filter(& &1.flags.is_wearable and &1.flags.is_weapon and &1.location.worn_on_character)
      |> sort_by_moved_at()
      |> Enum.map(& &1.id)

    assign(socket, worn_weapons_ids: worn_weapons_ids)
  end

  defp build_worn_jewelry_ids_list(socket) do
    worn_jewelry_ids =
      socket.assigns.inventory
      |> Map.values()
      |> Enum.filter(& &1.flags.is_wearable and &1.flags.is_jewelry and &1.location.worn_on_character)
      |> sort_by_moved_at()
      |> Enum.map(& &1.id)

    assign(socket, worn_jewelry_ids: worn_jewelry_ids)
  end

  defp build_slots_ids_map(socket) do
    slots_ids =
      socket.assigns.inventory
      |> Map.values()
      |> Enum.filter(& &1.flags.is_wearable and &1.location.worn_on_character)
      |> Enum.reduce(%{}, fn item, map ->
        children = Map.get(map, item.wearable.slot, [])
        Map.put(map, item.wearable.slot, [item | children])
      end)
      |> Enum.into(%{}, fn {key, children} ->
        sorted =
          Enum.sort(children, fn child1, child2 ->
            DateTime.compare(child1.location.moved_at, child2.location.moved_at) in [:gt, :eq]
          end)
          |> Enum.map(& &1.id)

        {key, sorted}
      end)

    assign(socket, slots_ids: slots_ids)
  end
end
