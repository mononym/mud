defmodule MudWeb.HomeLive.Show do
  use MudWeb, :live_view

  require Logger

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket, characters: [], page_title: "Home")}
  end
end
