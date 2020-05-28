defmodule Mud.Engine.CharacterSessionData do
  use Mud.Schema
  import Ecto.Changeset

  @primary_key {:character_id, :binary_id, autogenerate: false}
  schema "character_session_data" do
    field(:data, :binary)

    belongs_to(:character, Mud.Engine.Model.Character,
      type: :binary_id,
      foreign_key: :character_id,
      primary_key: true,
      define_field: false
    )

    timestamps()
  end

  @doc false
  def changeset(state, attrs) do
    state
    |> cast(attrs, [:character_id, :data])
    |> validate_required([:character_id, :data])
  end
end
