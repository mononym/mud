defmodule Mud.Repo.Migrations.CreateCharacterTemplates do
  use Ecto.Migration

  def change do
    create table(:character_templates, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:name, :string)
      add(:description, :string)
      add(:template, :text)

      timestamps()
    end

    create(unique_index(:character_templates, [:name]))
  end
end
