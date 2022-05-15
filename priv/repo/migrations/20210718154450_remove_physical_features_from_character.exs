defmodule Mud.Repo.Migrations.RemovePhysicalFeaturesFromCharacter do
  use Ecto.Migration

  def up do
    alter table(:characters) do
      remove(:eye_color)
      remove(:eye_accent_color)
      remove(:eye_color_type)
      remove(:hair_color)
      remove(:hair_style)
      remove(:hair_length)
      remove(:skin_tone)
      remove(:height)
    end

    drop_if_exists(index(:characters, [:eye_color]))
    drop_if_exists(index(:characters, [:eye_accent_color]))
    drop_if_exists(index(:characters, [:eye_color_type]))
    drop_if_exists(index(:characters, [:hair_color]))
    drop_if_exists(index(:characters, [:hair_style]))
    drop_if_exists(index(:characters, [:hair_length]))
    drop_if_exists(index(:characters, [:skin_tone]))
    drop_if_exists(index(:characters, [:height]))
  end

  def down do
    alter table(:characters) do
      add(:eye_color, :string)
      add(:eye_accent_color, :string)
      add(:eye_color_type, :string)
      add(:hair_color, :string)
      add(:hair_style, :string)
      add(:hair_length, :string)
      add(:skin_tone, :string)
      add(:height, :string)
    end

    create(index(:characters, [:eye_color]))
    create(index(:characters, [:eye_accent_color]))
    create(index(:characters, [:eye_color_type]))
    create(index(:characters, [:hair_color]))
    create(index(:characters, [:hair_length]))
    create(index(:characters, [:hair_style]))
    create(index(:characters, [:skin_tone]))
    create(index(:characters, [:height]))
  end
end
