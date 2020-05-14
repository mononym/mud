defmodule Mud.Engine.Component.Furniture do
  use Mud.Schema
  import Ecto.Changeset

  @primary_key {:object_id, :binary_id, autogenerate: false}
  schema "object_furniture_components" do
    field(:is_furniture, :boolean)

    belongs_to(:object, Mud.Engine.Component.Object,
      type: :binary_id,
      foreign_key: :object_id,
      primary_key: true,
      define_field: false
    )
  end

  @doc false
  def changeset(description, attrs) do
    description
    |> cast(attrs, [:object_id, :is_furniture])
    |> validate_required([
      :object_id,
      :is_furniture
    ])
    |> foreign_key_constraint(:object_id)
  end
end
