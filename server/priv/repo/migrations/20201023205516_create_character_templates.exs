defmodule Mud.Repo.Migrations.CreateCharacterTemplates do
  use Ecto.Migration

  def change do
    create table(:character_templates, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:name, :string)
      add(:description, :string)
      add(:template, :text)
      add(:instance_id, references(:instances, on_delete: :nothing, type: :binary_id))

      timestamps()
    end

    create(index(:character_templates, [:instance_id]))
    create(unique_index(:character_templates, [:name, :instance_id]))
  end
end
