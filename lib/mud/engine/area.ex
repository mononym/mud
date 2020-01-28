defmodule Mud.Engine.Area do
  use Ecto.Schema
  import Ecto.Changeset

  schema "areas" do
    field :description, :string
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(area, attrs) do
    area
    |> cast(attrs, [:name, :description])
    |> validate_required([:name, :description])
  end
end
