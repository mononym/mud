defmodule Mud.Engine.Component.CharacterAttributes do
  use Mud.Schema

  @primary_key {:character_id, :binary_id, autogenerate: false}
  schema "attributes" do
    field(:strength, :integer, default: 10)
    field(:stamina, :integer, default: 10)
    field(:constitution, :integer, default: 10)
    field(:dexterity, :integer, default: 10)
    field(:agility, :integer, default: 10)
    field(:reflexes, :integer, default: 10)
    field(:intelligence, :integer, default: 10)
    field(:wisdom, :integer, default: 10)
    field(:charisma, :integer, default: 10)

    belongs_to(:character, Mud.Engine.Character,
      type: :binary_id,
      foreign_key: :character_id,
      primary_key: true,
      define_field: false
    )
  end
end
