defmodule Mud.Engine.Component.CharacterPhysicalStatus do
  use Mud.Schema
  import Ecto.Changeset

  @primary_key {:character_id, :binary_id, autogenerate: false}
  schema "character_physical_status_components" do
    # standing, sitting, prone
    field(:position, :string)
    # in, on, under, an object
    # initially created for allowing character to sit on furniture such as a bench, or in a fountain
    field(:relative_position, :string)

    # populated with the object the character is in/under/on/near
    belongs_to(:relative_object, Mud.Engine.Object,
      type: :binary_id,
      foreign_key: :relative_object_id,
      primary_key: false,
      define_field: true
    )

    belongs_to(:location, Mud.Engine.Area,
      type: :binary_id,
      foreign_key: :area_id,
      primary_key: false,
      define_field: true
    )

    belongs_to(:character, Mud.Engine.Character,
      type: :binary_id,
      foreign_key: :character_id,
      primary_key: true,
      define_field: false
    )
  end

  @doc false
  def changeset(description, attrs) do
    description
    |> cast(attrs, [:position, :area_id, :character_id])
    |> validate_required([:position, :area_id, :character_id])
  end
end
