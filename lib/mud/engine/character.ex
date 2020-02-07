defmodule Mud.Engine.Character do
  use Mud.Schema
  import Ecto.Changeset

  alias Mud.Engine.Component.{Attributes}

  schema "characters" do
    field(:name, :string)
    field(:active, :boolean, default: false)

    belongs_to(:location, Mud.Engine.Area,
      type: :binary_id,
      foreign_key: :location_id
    )

    belongs_to(:player, Mud.Account.Player,
      type: :binary_id,
      foreign_key: :player_id
    )

    has_one(:attributes, Attributes)

    timestamps()
  end

  @doc false
  def changeset(character, attrs) do
    character
    |> cast(attrs, [:active, :location_id, :name, :player_id])
    |> validate_required([:active, :location_id, :name, :player_id])
    |> foreign_key_constraint(:location_id)
    |> foreign_key_constraint(:player_id)
    |> validate_inclusion(:active, [true, false])
    |> unique_constraint(:name)
  end
end
