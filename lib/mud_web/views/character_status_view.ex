defmodule MudWeb.CharacterStatusView do
  use MudWeb, :view

  def render("character_status.json", %{character_status: character_status}) do
    character_status
  end
end
