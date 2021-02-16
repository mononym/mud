defmodule MudWeb.CharacterWealthView do
  use MudWeb, :view

  def render("character_wealth.json", %{character_wealth: character_wealth}) do
    character_wealth
  end
end
