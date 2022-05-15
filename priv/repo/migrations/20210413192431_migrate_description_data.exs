defmodule Mud.Repo.Migrations.MigrateDescriptiopnData do
  use Ecto.Migration

  def up do
    Ecto.Adapters.SQL.query!(
      Mud.Repo,
      "UPDATE item_descriptions SET details = long;"
    )
  end

  def down do
    Ecto.Adapters.SQL.query!(
      Mud.Repo,
      "UPDATE item_descriptions SET long = details;"
    )
  end
end
