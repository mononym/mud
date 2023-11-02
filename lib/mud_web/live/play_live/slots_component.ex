defmodule MudWeb.PlayLive.SlotsComponent do
  use MudWeb, :live_component

  import MudWeb.PlayLive.Util
  import MudWeb.PlayLive.Components

  @impl true
  def mount(socket) do
    {:ok,
     assign(socket,
     slots_collapsed: false,
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
  def render(assigns) do
    ~H"""
    <div>
      <div class="flex">
        <div phx-click="toggle_slots" phx-throttle="500" phx-target={@myself} class="relative w-1 h-1 mr-0.5 cursor-pointer">
          <i class={"fas fa-#{if @slots_collapsed, do: "plus", else: "minus"} fa-lg"} style={"color:#{@inventory_settings.slots_label}"}></i>
        </div>
        <p style={"color:#{@inventory_settings.slots_label}"}>Slots</p>
      </div>
      <div class={"ml-1 flex flex-col #{if @slots_collapsed or not @inventory_settings.show_slots, do: "hidden"}"}>
        <%# On Hair %>
        <div class="flex">
          <div phx-click="toggle_slot" phx-throttle="500" phx-target={@myself} phx-value-slot="on_hair" class="relative w-1 h-1 mr-0.5 cursor-pointer">
            <i class={"fas fa-#{if @slot_collapsed["on_hair"], do: "plus", else: "minus"} fa-lg"} style={"color:#{@inventory_settings.slots_label}"}></i>
          </div>
          <p style={"color:#{@inventory_settings.slots_label}"}>On Hair (<%= length(Map.get(@slots_ids, "on_hair", [])) %>/<%= @slots.on_hair %>)</p>
        </div>
        <div class={"ml-1 #{if @slot_collapsed["on_hair"], do: "hidden"}"}>
          <%= for item_id <- Map.get(@slots_ids, "on_hair", []) do %>
            <.item item={@inventory[item_id]} colors_settings={@colors_settings} items={@inventory} parent_child_ids_map={@parent_child_ids_map} />
          <% end %>
        </div>

        <%# In Hair %>
        <div class="flex">
          <div phx-click="toggle_slot" phx-throttle="500" phx-target={@myself} phx-value-slot="in_hair" class="relative w-1 h-1 mr-0.5 cursor-pointer">
            <i class={"fas fa-#{if @slot_collapsed["in_hair"], do: "plus", else: "minus"} fa-lg"} style={"color:#{@inventory_settings.slots_label}"}></i>
          </div>
          <p style={"color:#{@inventory_settings.slots_label}"}>In Hair (<%= length(Map.get(@slots_ids, "in_hair", [])) %>/<%= @slots.in_hair %>)</p>
        </div>
        <div class={"ml-1 #{if @slot_collapsed["in_hair"], do: "hidden"}"}>
          <%= for item_id <- Map.get(@slots_ids, "in_hair", []) do %>
            <.item item={@inventory[item_id]} colors_settings={@colors_settings} items={@inventory} parent_child_ids_map={@parent_child_ids_map} />
          <% end %>
        </div>

        <%# On Head %>
        <div class="flex">
          <div phx-click="toggle_slot" phx-throttle="500" phx-target={@myself} phx-value-slot="on_head" class="relative w-1 h-1 mr-0.5 cursor-pointer">
            <i class={"fas fa-#{if @slot_collapsed["on_head"], do: "plus", else: "minus"} fa-lg"} style={"color:#{@inventory_settings.slots_label}"}></i>
          </div>
          <p style={"color:#{@inventory_settings.slots_label}"}>On Head (<%= length(Map.get(@slots_ids, "on_head", [])) %>/<%= @slots.on_head %>)</p>
        </div>
        <div class={"ml-1 #{if @slot_collapsed["on_head"], do: "hidden"}"}>
          <%= for item_id <- Map.get(@slots_ids, "on_head", []) do %>
            <.item item={@inventory[item_id]} colors_settings={@colors_settings} items={@inventory} parent_child_ids_map={@parent_child_ids_map} />
          <% end %>
        </div>

        <%# Around Neck %>
        <div class="flex">
          <div phx-click="toggle_slot" phx-throttle="500" phx-target={@myself} phx-value-slot="around_neck" class="relative w-1 h-1 mr-0.5 cursor-pointer">
            <i class={"fas fa-#{if @slot_collapsed["around_neck"], do: "plus", else: "minus"} fa-lg"} style={"color:#{@inventory_settings.slots_label}"}></i>
          </div>
          <p style={"color:#{@inventory_settings.slots_label}"}>Around Neck (<%= length(Map.get(@slots_ids, "around_neck", [])) %>/<%= @slots.around_neck %>)</p>
        </div>
        <div class={"ml-1 #{if @slot_collapsed["around_neck"], do: "hidden"}"}>
          <%= for item_id <- Map.get(@slots_ids, "around_neck", []) do %>
            <.item item={@inventory[item_id]} colors_settings={@colors_settings} items={@inventory} parent_child_ids_map={@parent_child_ids_map} />
          <% end %>
        </div>

        <%# Over Shoulders %>
        <div class="flex">
          <div phx-click="toggle_slot" phx-throttle="500" phx-target={@myself} phx-value-slot="over_shoulders" class="relative w-1 h-1 mr-0.5 cursor-pointer">
            <i class={"fas fa-#{if @slot_collapsed["over_shoulders"], do: "plus", else: "minus"} fa-lg"} style={"color:#{@inventory_settings.slots_label}"}></i>
          </div>
          <p style={"color:#{@inventory_settings.slots_label}"}>Over Shoulders (<%= length(Map.get(@slots_ids, "over_shoulders", [])) %>/<%= @slots.over_shoulders %>)</p>
        </div>
        <div class={"ml-1 #{if @slot_collapsed["over_shoulders"], do: "hidden"}"}>
          <%= for item_id <- Map.get(@slots_ids, "over_shoulders", []) do %>
            <.item item={@inventory[item_id]} colors_settings={@colors_settings} items={@inventory} parent_child_ids_map={@parent_child_ids_map} />
          <% end %>
        </div>

        <%# Over Shoulder %>
        <div class="flex">
          <div phx-click="toggle_slot" phx-throttle="500" phx-target={@myself} phx-value-slot="over_shoulder" class="relative w-1 h-1 mr-0.5 cursor-pointer">
            <i class={"fas fa-#{if @slot_collapsed["over_shoulder"], do: "plus", else: "minus"} fa-lg"} style={"color:#{@inventory_settings.slots_label}"}></i>
          </div>
          <p style={"color:#{@inventory_settings.slots_label}"}>Over Shoulder (<%= length(Map.get(@slots_ids, "over_shoulder", [])) %>/<%= @slots.over_shoulder %>)</p>
        </div>
        <div class={"ml-1 #{if @slot_collapsed["over_shoulder"], do: "hidden"}"}>
          <%= for item_id <- Map.get(@slots_ids, "over_shoulder", []) do %>
            <.item item={@inventory[item_id]} colors_settings={@colors_settings} items={@inventory} parent_child_ids_map={@parent_child_ids_map} />
          <% end %>
        </div>

        <%# On Torso %>
        <div class="flex">
          <div phx-click="toggle_slot" phx-throttle="500" phx-target={@myself} phx-value-slot="on_torso" class="relative w-1 h-1 mr-0.5 cursor-pointer">
            <i class={"fas fa-#{if @slot_collapsed["on_torso"], do: "plus", else: "minus"} fa-lg"} style={"color:#{@inventory_settings.slots_label}"}></i>
          </div>
          <p style={"color:#{@inventory_settings.slots_label}"}>On Torso (<%= length(Map.get(@slots_ids, "on_torso", [])) %>/<%= @slots.on_torso %>)</p>
        </div>
        <div class={"ml-1 #{if @slot_collapsed["on_torso"], do: "hidden"}"}>
          <%= for item_id <- Map.get(@slots_ids, "on_torso", []) do %>
            <.item item={@inventory[item_id]} colors_settings={@colors_settings} items={@inventory} parent_child_ids_map={@parent_child_ids_map} />
          <% end %>
        </div>

        <%# On Back %>
        <div class="flex">
          <div phx-click="toggle_slot" phx-throttle="500" phx-target={@myself} phx-value-slot="on_back" class="relative w-1 h-1 mr-0.5 cursor-pointer">
            <i class={"fas fa-#{if @slot_collapsed["on_back"], do: "plus", else: "minus"} fa-lg"} style={"color:#{@inventory_settings.slots_label}"}></i>
          </div>
          <p style={"color:#{@inventory_settings.slots_label}"}>On Back (<%= length(Map.get(@slots_ids, "on_back", [])) %>/<%= @slots.on_back %>)</p>
        </div>
        <div class={"ml-1 #{if @slot_collapsed["on_back"], do: "hidden"}"}>
          <%= for item_id <- Map.get(@slots_ids, "on_back", []) do %>
            <.item item={@inventory[item_id]} colors_settings={@colors_settings} items={@inventory} parent_child_ids_map={@parent_child_ids_map} />
          <% end %>
        </div>

        <%# Around Waist %>
        <div class="flex">
          <div phx-click="toggle_slot" phx-throttle="500" phx-target={@myself} phx-value-slot="around_waist" class="relative w-1 h-1 mr-0.5 cursor-pointer">
            <i class={"fas fa-#{if @slot_collapsed["around_waist"], do: "plus", else: "minus"} fa-lg"} style={"color:#{@inventory_settings.slots_label}"}></i>
          </div>
          <p style={"color:#{@inventory_settings.slots_label}"}>Around Waist (<%= length(Map.get(@slots_ids, "around_waist", [])) %>/<%= @slots.around_waist %>)</p>
        </div>
        <div class={"ml-1 #{if @slot_collapsed["around_waist"], do: "hidden"}"}>
          <%= for item_id <- Map.get(@slots_ids, "around_waist", []) do %>
            <.item item={@inventory[item_id]} colors_settings={@colors_settings} items={@inventory} parent_child_ids_map={@parent_child_ids_map} />
          <% end %>
        </div>

        <%# On Belt %>
        <div class="flex">
          <div phx-click="toggle_slot" phx-throttle="500" phx-target={@myself} phx-value-slot="on_belt" class="relative w-1 h-1 mr-0.5 cursor-pointer">
            <i class={"fas fa-#{if @slot_collapsed["on_belt"], do: "plus", else: "minus"} fa-lg"} style={"color:#{@inventory_settings.slots_label}"}></i>
          </div>
          <p style={"color:#{@inventory_settings.slots_label}"}>On Belt (<%= length(Map.get(@slots_ids, "on_belt", [])) %>/<%= @slots.on_belt %>)</p>
        </div>
        <div class={"ml-1 #{if @slot_collapsed["on_belt"], do: "hidden"}"}>
          <%= for item_id <- Map.get(@slots_ids, "on_belt", []) do %>
            <.item item={@inventory[item_id]} colors_settings={@colors_settings} items={@inventory} parent_child_ids_map={@parent_child_ids_map} />
          <% end %>
        </div>
      </div>
    </div>
    """
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
end
