defmodule MudWeb.CharacterView do
  use MudWeb, :view
  alias MudWeb.CharacterView
  alias MudWeb.CharacterSettingsView
  alias MudWeb.CharacterBankView
  alias MudWeb.CharacterContainersView
  alias MudWeb.CharacterSlotsView
  alias MudWeb.CharacterStatusView
  alias MudWeb.CharacterWealthView
  alias MudWeb.RaceView
  alias MudWeb.Views.Character.PhysicalFeaturesView

  def render("character-creation-data.json", %{races: races}) do
    render_many(races, RaceView, "race.json")
  end

  def render("index.json", %{character: characters}) do
    render_many(characters, CharacterView, "character.json")
  end

  def render("show.json", %{character: character}) do
    render_one(character, CharacterView, "character.json")
  end

  def render("character.json", %{character: character}) do
    %{
      bank:
        render_one(
          character.bank,
          CharacterBankView,
          "character_bank.json"
        ),
      containers:
        render_one(
          character.containers,
          CharacterContainersView,
          "character_containers.json"
        ),
      physical_features:
        render_one(
          character.physical_features,
          PhysicalFeaturesView,
          "physical_feature.json"
        ),
      settings:
        render_one(
          character.settings,
          CharacterSettingsView,
          "character_settings.json"
        ),
      slots:
        render_one(
          character.slots,
          CharacterSlotsView,
          "character_slots.json"
        ),
      status:
        render_one(
          character.status,
          CharacterStatusView,
          "character_status.json"
        ),
      wealth:
        render_one(
          character.wealth,
          CharacterWealthView,
          "character_wealth.json"
        ),
      id: character.id,
      name: character.name,
      active: character.active,
      pronoun: character.pronoun,
      race: character.race,
      area_id: character.area_id,
      player_id: character.player_id,
      moved_at: character.moved_at,
      inserted_at: character.inserted_at,
      updated_at: character.updated_at
    }
  end
end
