defmodule Mud.Repo.Migrations.CreateLinkFlags do
  use Ecto.Migration

  def change do
    create table(:link_flags, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:link_id, references(:links, on_delete: :delete_all, type: :binary_id))

      add(:closable, :boolean, default: false)
      add(:portal, :boolean, default: false)
      add(:direction, :boolean, default: false)
      add(:object, :boolean, default: false)
    end

    create(index(:link_flags, [:closable]))
    create(index(:link_flags, [:portal]))
    create(index(:link_flags, [:direction]))
    create(index(:link_flags, [:object]))
    create(unique_index(:link_flags, [:link_id]))
  end
end
