defmodule MudWeb.MudClientLive do
  use Phoenix.LiveView

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    <div id="mudClientWrapper">
      <section id="mudClientMainSection">
        <div id="mudClientStoryWindow">
        </div>
      </section>
      <section id="mudClientCommandSection">
        <div id="mudClientCommandInputContainer">
            <div id="mudClientCommandInput" contenteditable="true"></div>
        </div>
      </footer>
    </div>
    """
  end
end
