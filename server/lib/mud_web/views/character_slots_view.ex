defmodule MudWeb.CharacterSlotsView do
  use MudWeb, :view

  def render("character_slots.json", %{character_slots: character_slots}) do
    character_slots
  end
end
