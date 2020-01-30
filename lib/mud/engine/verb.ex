defmodule Mud.Engine.Verb do
  use Mud.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "verbs" do
    field(:verb, :string)
    field(:callback_id, :binary_id)

    timestamps()
  end

  @doc false
  def changeset(verb, attrs) do
    verb
    |> cast(attrs, [:verb])
    |> validate_required([:verb])
  end
end
