defmodule MudWeb.Live.Component.CommandPrompt do
  use Phoenix.LiveComponent

  def render(assigns) do
    Phoenix.View.render(MudWeb.MudClientView, "command_prompt.html", assigns)
  end
end
