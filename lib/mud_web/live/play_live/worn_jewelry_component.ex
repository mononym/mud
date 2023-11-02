defmodule MudWeb.PlayLive.WornJewelryComponent do
  use MudWeb, :live_component

  import MudWeb.PlayLive.Util
  import MudWeb.PlayLive.Components

  @impl true
  def mount(socket) do
    {:ok,
     assign(socket,
     worn_jewelry_collapsed: false
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="flex">
        <div phx-click="toggle_worn_jewelry" phx-throttle="500" phx-target={@myself} class="relative w-1 h-1 mr-0.5 cursor-pointer">
          <i class={"fas fa-#{if @worn_jewelry_collapsed, do: "plus", else: "minus"} fa-lg"} style={"color:#{@inventory_settings.worn_jewelry_label}"}></i>
        </div>
        <p style={"color:#{@inventory_settings.worn_jewelry_label}"}>Worn Jewelry</p>
      </div>
      <div class={"ml-1 #{if @worn_jewelry_collapsed or not @inventory_settings.show_worn_jewelry, do: "hidden"}"}>
        <%= for item_id <- @worn_jewelry_ids do %>
          <.item item={@inventory[item_id]} colors_settings={@colors_settings} items={@inventory} parent_child_ids_map={@parent_child_ids_map} />
        <% end %>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("toggle_worn_jewelry", _params, socket) do
    {:noreply,
     assign(socket,
     worn_jewelry_collapsed: not socket.assigns.worn_jewelry_collapsed
     )}
  end
end
