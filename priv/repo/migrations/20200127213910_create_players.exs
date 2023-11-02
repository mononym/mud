defmodule Mud.Repo.Migrations.CreatePlayers do
  use Ecto.Migration

  def change do
    create table(:players, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:email, :citext, null: false)
      add(:nickname, :citext, null: false)
      add(:hashed_password, :string, null: false)
      add(:confirmed_at, :utc_datetime)
      add(:tos_accepted, :boolean, default: false, null: false)
      add(:tos_accepted_at, :utc_datetime)
      timestamps()
    end

    create(unique_index(:players, [:email]))
    create(unique_index(:players, [:nickname]))
    create(index(:players, [:tos_accepted]))

    create table(:players_tokens, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:player_id, references(:players, type: :binary_id, on_delete: :delete_all), null: false)
      add(:token, :binary, null: false)
      add(:context, :string, null: false)
      add(:sent_to, :string)
      timestamps(updated_at: false)
    end

    create(index(:players_tokens, [:player_id]))
    create(unique_index(:players_tokens, [:context, :token]))
  end
end
