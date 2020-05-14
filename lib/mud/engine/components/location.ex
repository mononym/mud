defmodule Mud.Engine.Component.Location do
  use Mud.Schema
  import Ecto.Changeset

  @primary_key {:object_id, :binary_id, autogenerate: false}
  schema "location_components" do
    belongs_to(:object, Mud.Engine.Component.Object,
      type: :binary_id,
      foreign_key: :object_id,
      primary_key: true,
      define_field: false
    )

    belongs_to(:location, Mud.Engine.Component.Object,
      type: :binary_id,
      foreign_key: :location_id
    )
  end

  @doc false
  def changeset(location, attrs) do
    location
    |> cast(attrs, [:object_id, :location_id])
    |> validate_required([:object_id, :location_id])
  end
end
