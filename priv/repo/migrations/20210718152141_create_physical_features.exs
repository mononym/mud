defmodule Mud.Repo.Migrations.CreatePhysicalFeatures do
  use Ecto.Migration

  def change do
    create table(:physical_features, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:character_id, references(:characters, on_delete: :delete_all, type: :binary_id))

      add(:birth_day, :integer, default: 1, null: false)
      add(:birth_season, :string, default: "spring", null: false)
      add(:birth_year, :integer, default: 1, null: false)

      add(:eye_shape, :string, default: "oval", null: false)
      add(:eye_feature, :string, default: "none", null: false)
      add(:eye_color, :string, default: "brown", null: false)

      add(:hair_type, :string, default: "oval", null: false)
      add(:hair_feature, :string, default: "none", null: false)
      add(:hair_color, :string, default: "brown", null: false)
      add(:hair_length, :string, default: "shoulder length", null: false)
      add(:hair_style, :string, default: "loose", null: false)

      add(:skin_tone, :string, default: "tanned", null: false)
      add(:height, :string, default: "average", null: false)
      add(:body_type, :string, default: "average", null: false)

      timestamps()
    end

    create(unique_index(:physical_features, [:character_id]))
  end
end
