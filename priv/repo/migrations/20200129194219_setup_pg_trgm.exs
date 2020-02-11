defmodule App.Repo.Migrations.SetupPgTrgm do
  @moduledoc """
  Create postgres extension and indices
  """

  use Ecto.Migration

  def up do
    execute("CREATE EXTENSION pg_trgm")
  end

  def down do
    execute("DROP EXTENSION pg_trgm")
  end
end
