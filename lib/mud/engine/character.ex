defmodule Mud.Engine.Character do
  use Ecto.Schema
  import Ecto.Changeset

  schema "characters" do
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(character, attrs) do
    character
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
