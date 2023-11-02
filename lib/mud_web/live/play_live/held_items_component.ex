defmodule MudWeb.PlayLive.HeldItemsComponent do
  use MudWeb, :live_component

  import MudWeb.PlayLive.Util
  import MudWeb.PlayLive.Components

  @impl true
  def mount(socket) do
    {:ok,
     assign(socket,
       held_items_collapsed: false
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="flex">
        <div phx-click="toggle_held_items" phx-throttle="500" phx-target={@myself} class="relative w-1 h-1 mr-0.5 cursor-pointer">
          <i class={"fas fa-#{if @held_items_collapsed, do: "plus", else: "minus"} fa-lg"} style={"color:#{@inventory_settings.held_items_label}"}></i>
        </div>
        <p style={"color:#{@inventory_settings.held_items_label}"}>Held Items</p>
      </div>
      <div class={"pl-1.5 #{if @held_items_collapsed or not @inventory_settings.show_held_items, do: "hidden"}"}>
        <div class="flex items-center">
          <i class="fa-solid fa-hand mr-0.5 scale-x-flip"></i>
          <%= if not is_nil(@held_item_left_hand_id) do %>
            <p style={"color:#{item_to_color(@colors_settings, @inventory[@held_item_left_hand_id])}"}><%= @inventory[@held_item_left_hand_id].description.short %></p>
          <% else %>
            <p style={"color:#{@inventory_settings.empty_hand}"}>Left Hand Empty</p>
          <% end %>
        </div>
        <div class="flex items-center">
          <i class="fa-solid fa-hand mr-0.5"></i>
          <%= if not is_nil(@held_item_right_hand_id) do %>
            <p style={"color:#{item_to_color(@colors_settings, @inventory[@held_item_right_hand_id])}"}><%= @inventory[@held_item_right_hand_id].description.short %></p>
          <% else %>
            <p style={"color:#{@inventory_settings.empty_hand}"}>Right Hand Empty</p>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("toggle_held_items", _params, socket) do
    {:noreply,
     assign(socket,
       held_items_collapsed: not socket.assigns.held_items_collapsed
     )}
  end
end
