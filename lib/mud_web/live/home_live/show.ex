defmodule MudWeb.HomeLive.Show do
  use MudWeb, :live_view

  alias Mud.Engine.Character

  require Logger

  @impl true
  def mount(_params, _session, socket) do
    characters = Character.list_by_player_id(socket.assigns.current_player.id)
    {:ok,
     assign(socket, characters: characters, page_title: "Home")}
  end
end
