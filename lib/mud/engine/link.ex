defmodule Mud.Engine.Link do
  use Ecto.Schema
  import Ecto.Changeset

  schema "links" do
    field :text, :string
    field :type, :string
    field :from, :id
    field :to, :id

    timestamps()
  end

  @doc false
  def changeset(link, attrs) do
    link
    |> cast(attrs, [:type, :text])
    |> validate_required([:type, :text])
  end
end
