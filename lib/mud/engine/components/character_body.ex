defmodule Mud.Engine.Component.CharacterBody do
  use Mud.Schema
  import Ecto.Changeset

  @primary_key {:character_id, :binary_id, autogenerate: false}
  schema "character_feature_components" do
    field(:race, :string)
    field(:biological_sex, :string)
    field(:features, :map)

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
    |> cast(attrs, [:character_id, :race, :features])
    |> validate_required([
      :character_id,
      :race,
      :features
    ])
  end
end
