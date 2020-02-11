defmodule Mud.Engine.Component.Location do
  use Mud.Schema
  import Ecto.Changeset

  @primary_key {:object_id, :binary_id, autogenerate: false}
  schema "location_components" do
    field(:contained, :boolean, default: false)
    field(:hand, :string)
    field(:held, :boolean, default: false)
    field(:on_ground, :boolean, default: false)
    field(:reference, :string)
    field(:worn, :boolean, default: false)

    belongs_to(:object, Mud.Engine.Object,
      type: :binary_id,
      foreign_key: :object_id,
      primary_key: true,
      define_field: false
    )

    timestamps()
  end

  @doc false
  def changeset(location, attrs) do
    location
    |> cast(attrs, [:object_id, :on_ground, :held, :worn, :hand, :contained, :reference])
    |> validate_required([:object_id, :on_ground, :held, :worn, :hand, :contained, :reference])
  end
end
