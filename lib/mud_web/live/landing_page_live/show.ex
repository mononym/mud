defmodule MudWeb.LandingPageLive.Show do
  use MudWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Welcome")}
  end
end
