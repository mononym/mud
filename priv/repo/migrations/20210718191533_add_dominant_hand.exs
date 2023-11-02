defmodule Mud.Repo.Migrations.AddDominantHand do
  use Ecto.Migration

  def down do
    alter table(:physical_features) do
      remove(:dominant_hand)
    end
  end

  def up do
    alter table(:physical_features) do
      add(:dominant_hand, :string)
    end
  end
end
