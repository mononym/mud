defmodule Mud.Repo.Migrations.CreatePlayerSettings do
  use Ecto.Migration

  def change do
    create table(:player_settings, primary_key: false) do
      add(:developer_feature_on, :boolean, default: false, null: false)

      add(:player_id, references(:players, type: :binary_id, on_delete: :delete_all),
        primary_key: true
      )

      timestamps()
    end

    create(unique_index(:player_settings, [:player_id]))
    create(index(:player_settings, [:developer_feature_on]))
  end
end
