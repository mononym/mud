defmodule Mud.Repo.Migrations.AddColorOptionsToSettings do
  use Ecto.Migration

  def change do
    alter table(:character_settings) do
      add(:area_name_text_color, :string)
      add(:area_description_text_color, :string)
      add(:character_text_color, :string)
      add(:furniture_text_color, :string)
      add(:exit_text_color, :string)
      add(:denizen_text_color, :string)
    end
  end
end
