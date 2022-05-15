defmodule MudWeb.Views.Character.Settings.EchoView do
  use MudWeb, :view

  def render("echo.json", %{echo: echo}) do
    %{
      id: echo.id,
      cli_commands_in_story: echo.cli_commands_in_story,
      hotkey_commands_in_story: echo.hotkey_commands_in_story,
      ui_commands_in_story: echo.ui_commands_in_story
    }
  end
end
