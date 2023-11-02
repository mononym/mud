defmodule MudWeb.PlayLive.Components do
  @moduledoc """
  Various stateless components used as part of the game client
  """
  use Phoenix.Component
  import MudWeb.PlayLive.Util

  def item(assigns) do
    ~H"""
    <div class="flex">
      <%= if @item.flags.is_closable and @item.flags.close do %>
        <div phx-click="toggle_item_close" phx-throttle="500" phx-value-item_id={@item.id} class="w-1 h-1 mr-0.5 cursor-pointer">
          <i class={"fas fa-#{if @item.closable.open, do: "minus", else: "plus"} fa-lg"} style={"color:#{item_to_color(@colors_settings, @item)}"}></i>
        </div>
      <% else %>
        <div class="w-1 h-1 mr-0.5" />
      <% end %>
      <p style={"color:#{item_to_color(@colors_settings, @item)}"}><%= @item.description.short %></p>
    </div>
    <div class={"ml-1 #{if @item.flags.is_closable and not @item.closable.open, do: "hidden"}"}>
      <%= for child_id <- Map.get(@parent_child_ids_map, @item.id, []) do %>
        <MudWeb.PlayLive.Components.item item={@items[child_id]} colors_settings={@colors_settings} items={@items} parent_child_ids_map={@parent_child_ids_map} />
      <% end %>
    </div>
    """
  end
end
