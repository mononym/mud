defmodule Mud.Engine.Link do
  use Mud.Schema
  import Ecto.Changeset

  schema "links" do
    field(:departure_direction, :string)
    field(:arrival_direction, :string)
    field(:type, :string)

    belongs_to(:from, Mud.Engine.Area,
      type: :binary_id,
      foreign_key: :from_id
    )

    belongs_to(:to, Mud.Engine.Area,
      type: :binary_id,
      foreign_key: :to_id
    )

    timestamps()
  end

  @doc false
  def changeset(link, attrs) do
    link
    |> cast(attrs, [:type, :arrival_direction, :departure_direction, :from_id, :to_id])
    |> validate_required([:type, :arrival_direction, :departure_direction, :from_id, :to_id])
  end
end
