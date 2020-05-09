defmodule Mud.Engine.Component.CharacterFeature do
  use Mud.Schema
  import Ecto.Changeset

  @primary_key {:character_id, :binary_id, autogenerate: false}
  schema "character_feature_components" do
    field(:name, :string)
    field(:description, :string)
    field(:type, :string)

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
    |> cast(attrs, [:object_id, :glance_description, :look_description, :examine_description])
    |> validate_required([
      :object_id,
      :glance_description,
      :look_description,
      :examine_description
    ])
  end
end
