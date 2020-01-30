defmodule Mud.Engine.Callback do
  use Mud.Schema
  import Ecto.Changeset

  schema "callbacks" do
    field :module, :string
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(callback, attrs) do
    callback
    |> cast(attrs, [:name, :module])
    |> validate_required([:name, :module])
  end
end
