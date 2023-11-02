defmodule Mud.Repo.Migrations.CreateAccountPurchases do
  use Ecto.Migration

  def change do
    create table(:player_purchases, primary_key: false) do
      add(:crowns, :integer, default: 0, null: false)

      add(:player_id, references(:players, type: :binary_id, on_delete: :delete_all),
        primary_key: true
      )

      timestamps()
    end

    create(unique_index(:player_purchases, [:player_id]))
    create(index(:player_purchases, [:crowns]))
  end
end
