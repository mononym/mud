defmodule MudWeb.CharacterWealthView do
  use MudWeb, :view
  alias MudWeb.CharacterWealthView

  def render("character_wealth.json", %{character_wealth: character_wealth}) do
    character_wealth
  end
end
