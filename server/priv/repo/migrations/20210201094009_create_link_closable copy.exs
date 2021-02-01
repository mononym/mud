defmodule Mud.Repo.Migrations.CreateLinkClosable do
  use Ecto.Migration

  def change do
    create table(:link_closables, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:link_id, references(:links, on_delete: :delete_all, type: :binary_id))
      add(:character_id, references(:characters, on_delete: :delete_all, type: :binary_id))

      add(:open, :boolean, default: false)
      add(:locked, :boolean, default: false)
      add(:owned, :boolean, default: false)
    end

    create(index(:link_closables, [:open]))
    create(index(:link_closables, [:locked]))
    create(index(:link_closables, [:owned]))
    create(unique_index(:link_closables, [:link_id]))
    create(index(:link_closables, [:character_id]))
  end
end
