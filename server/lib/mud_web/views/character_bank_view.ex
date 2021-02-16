defmodule MudWeb.CharacterBankView do
  use MudWeb, :view

  def render("character_bank.json", %{character_bank: character_bank}) do
    character_bank
  end
end
