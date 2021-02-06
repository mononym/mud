defmodule Mud.Repo.Migrations.CreateCharacterWealth do
  use Ecto.Migration

  def change do
    create table(:character_wealth, primary_key: false) do
      add(:id, :binary_id, primary_key: true)

      add(:character_id, references(:characters, on_delete: :delete_all, type: :binary_id))

      add(:copper, :bigint, default: 0)
      add(:bronze, :bigint, default: 0)
      add(:silver, :bigint, default: 0)
      add(:gold, :bigint, default: 0)
    endmix 

    create(unique_index(:character_wealth, [:character_id]))
    create(index(:character_wealth, [:copper]))
    create(index(:character_wealth, [:bronze]))
    create(index(:character_wealth, [:silver]))
    create(index(:character_wealth, [:gold]))
  end
end
