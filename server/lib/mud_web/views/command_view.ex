defmodule MudWeb.CommandView do
  use MudWeb, :view
  alias MudWeb.CommandView

  def render("index.json", %{commands: commands}) do
    render_many(commands, CommandView, "command.json")
  end

  def render("show.json", %{command: command}) do
    render_one(command, CommandView, "command.json")
  end

  def render("command.json", %{command: command}) do
    %{id: command.id,
      name: command.name,
      description: command.description,
      parts: command.parts}
  end
end
