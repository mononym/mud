defmodule MudWeb.PlayLive.Util do
  @moduledoc """
  Helper functions for the various client components
  """

  def text_type_to_color(character, type) do
    Map.get(character.settings.colors, String.to_existing_atom(type))
  end

  def item_to_color(character, %{flags: %{gem: true}}) do
    character.settings.colors.gem
  end

  def item_to_color(character, %{flags: %{furniture: true}}) do
    character.settings.colors.furniture
  end

  def item_to_color(character, %{flags: %{is_equipment: true}}) do
    character.settings.colors.equipment
  end

  def item_to_color(character, %{flags: %{weapon: true}}) do
    character.settings.colors.weapon
  end

  def item_to_color(character, %{flags: %{armor: true}}) do
    character.settings.colors.armor
  end

  def item_to_color(character, %{flags: %{coin: true}}) do
    character.settings.colors.coin
  end

  def item_to_color(character, %{flags: %{shield: true}}) do
    character.settings.colors.shield
  end

  def item_to_color(character, %{flags: %{is_clothing: true}}) do
    character.settings.colors.clothing
  end

  def item_to_color(character, %{flags: %{is_structure: true}}) do
    character.settings.colors.structure
  end

  def item_to_color(character, %{flags: %{is_jewelry: true}}) do
    character.settings.colors.jewelry
  end

  def item_to_color(character, %{flags: %{is_misc: true}}) do
    character.settings.colors.misc
  end

  def item_to_color(character, _item) do
    character.settings.colors.misc
  end
end
