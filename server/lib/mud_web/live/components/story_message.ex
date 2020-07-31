defmodule MudWeb.Live.Component.StoryMessage do
  use Phoenix.LiveComponent

  def render(assigns) do
    Phoenix.View.render(MudWeb.MudClientView, "story_message.html", assigns)
  end
end
