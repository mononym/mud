defmodule MudWeb.PlayLive.WornEquipmentComponent do
  use MudWeb, :live_component

  import MudWeb.PlayLive.Util
  import MudWeb.PlayLive.Components

  @impl true
  def mount(socket) do
    {:ok,
     assign(socket,
     worn_equipment_collapsed: false
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="flex">
        <div phx-click="toggle_worn_equipment" phx-throttle="500" phx-target={@myself} class="relative w-1 h-1 mr-0.5 cursor-pointer">
          <i class={"fas fa-#{if @worn_equipment_collapsed, do: "plus", else: "minus"} fa-lg"} style={"color:#{@inventory_settings.worn_equipment_label}"}></i>
        </div>
        <p style={"color:#{@inventory_settings.worn_equipment_label}"}>Worn Equipment</p>
      </div>
      <div class={"ml-1 #{if @worn_equipment_collapsed or not @inventory_settings.show_worn_equipment, do: "hidden"}"}>
        <%= for item_id <- @worn_equipment_ids do %>
          <.item item={@inventory[item_id]} colors_settings={@colors_settings} items={@inventory} parent_child_ids_map={@parent_child_ids_map} />
        <% end %>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("toggle_worn_equipment", _params, socket) do
    {:noreply,
     assign(socket,
     worn_equipment_collapsed: not socket.assigns.worn_equipment_collapsed
     )}
  end
end
