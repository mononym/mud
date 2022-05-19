defmodule MudWeb.CharacterLive.New do
  use MudWeb, :live_view

  require Logger

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       page_title: "Character Creation"
     )}
  end
end
