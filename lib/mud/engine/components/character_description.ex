defmodule Mud.Engine.Component.CharacterDescription do
  use Mud.Schema
  import Ecto.Changeset

  @primary_key {:object_id, :binary_id, autogenerate: false}
  schema "character_description_components" do
    field(:examine_description, :string)
    field(:glance_description, :string)
    field(:look_description, :string)

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
