defmodule Mud.Engine.CharacterVerb do
  use Mud.Schema
  import Ecto.Changeset

  schema "character_verbs" do
    belongs_to(:verb, Mud.Engine.Verb,
      type: :binary_id,
      foreign_key: :verb_id
    )

    belongs_to(:callback, Mud.Engine.Callback,
      type: :binary_id,
      foreign_key: :callback_id
    )

    timestamps()
  end

  @doc false
  def changeset(character_verb, attrs) do
    character_verb
    |> cast(attrs, [:callback_id, :verb_id])
    |> validate_required([:callback_id, :verb_id])
    |> foreign_key_constraint(:callback_id)
    |> foreign_key_constraint(:verb_id)
  end
end
