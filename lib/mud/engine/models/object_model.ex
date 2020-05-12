defmodule Mud.Engine.Model.ObjectModel do
  use Mud.Schema

  alias Mud.Engine.Component.Object.{Description, Furniture, Location, Scenery}

  import Ecto.Changeset

  schema "objects" do
    field(:key, :string)

    has_one(:description, Description, foreign_key: :object_id)
    has_one(:location, Location, foreign_key: :object_id)
    has_one(:furniture, Furniture, foreign_key: :object_id)
    has_one(:scenery, Scenery, foreign_key: :object_id)
  end

  @doc false
  def changeset(character, attrs) do
    character
    |> cast(attrs, [:key, :description, :location, :furniture, :scenery])
    |> validate_required([:key, :description, :location, :furniture, :scenery])
  end
end
