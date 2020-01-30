defmodule Mud.Engine.Character do
  use Mud.Schema
  import Ecto.Changeset

  schema "characters" do
    field(:name, :string)

    belongs_to(:location, Mud.Engine.Area,
      type: :binary_id,
      foreign_key: :location_id
    )

    belongs_to(:player, Mud.Account.Player,
      type: :binary_id,
      foreign_key: :player_id
    )

    timestamps()
  end

  @doc false
  def changeset(character, attrs) do
    character
    |> cast(attrs, [:location_id, :name, :player_id])
    |> validate_required([:location_id, :name, :player_id])
    |> foreign_key_constraint(:location_id)
    |> foreign_key_constraint(:player_id)
    |> unique_constraint(:name)
  end
end
