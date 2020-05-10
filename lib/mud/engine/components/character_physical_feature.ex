defmodule Mud.Engine.Component.CharacterPhysicalFeatures do
  use Mud.Schema
  import Ecto.Changeset

  @primary_key {:character_id, :binary_id, autogenerate: false}
  schema "character_physical_features_components" do
    field(:race, :string)
    field(:eye_color, :string)
    field(:hair_color, :string)
    field(:skin_color, :string)

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
    |> cast(attrs, [:race, :eye_color, :hair_color, :skin_color])
    |> validate_required([:race, :eye_color, :hair_color, :skin_color])
  end
end
