defmodule Mud.Repo.Migrations.CreatePlayerStatusEnum do
  use Ecto.Migration

  def up do
    Mud.Account.Enums.PlayerStatus.create_type()
  end

  def down do
    Mud.Account.Enums.PlayerStatus.drop_type()
  end
end
