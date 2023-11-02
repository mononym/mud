defmodule Mud.Account.PlayerRole do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "player_roles" do
    field :player_id, :binary_id
    field :role_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(player_role, attrs) do
    player_role
    |> cast(attrs, [])
    |> validate_required([])
  end
end
