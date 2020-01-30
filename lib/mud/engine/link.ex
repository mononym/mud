defmodule Mud.Engine.Link do
  use Mud.Schema
  import Ecto.Changeset

  schema "links" do
    field(:text, :string)
    field(:type, :string)

    belongs_to(:from, Mud.Engine.Area,
      type: :binary_id,
      foreign_key: :from_id
    )

    belongs_to(:to, Mud.Engine.Area,
      type: :binary_id,
      foreign_key: :to_id
    )

    timestamps()
  end

  @doc false
  def changeset(link, attrs) do
    link
    |> cast(attrs, [:type, :text])
    |> validate_required([:type, :text])
  end
end
