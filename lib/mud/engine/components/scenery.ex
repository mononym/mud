defmodule Mud.Engine.Component.Scenery do
  use Mud.Schema
  import Ecto.Changeset

  @primary_key {:object_id, :binary_id, autogenerate: false}
  schema "scenery_components" do
    field(:hidden, :boolean, default: false)

    belongs_to(:object, Mud.Engine.Object,
      type: :binary_id,
      foreign_key: :object_id,
      primary_key: true,
      define_field: false
    )
  end

  @doc false
  def changeset(location, attrs) do
    location
    |> cast(attrs, [:object_id, :hidden])
    |> validate_required([:object_id, :hidden])
  end

  def from_object(object, attrs) do
    Ecto.build_assoc(object, :scenery, attrs)
  end
end
