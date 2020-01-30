defmodule Mud.Engine.Character do
  use Ecto.Schema
  import Ecto.Changeset

  schema "characters" do
    field(:name, :string)
    field(:location, :id)

    belongs_to(:player, Mud.Account.Player,
      type: :binary_id,
      foreign_key: :player_id
    )

    timestamps()
  end

  @doc false
  def changeset(character, attrs) do
    character
    |> cast(attrs, [:name, :player_id])
    |> validate_required([:name, :player_id])
    |> foreign_key_constraint(:player_id)
  end
end
