defmodule Mud.Engine.Item.Location do
  use Mud.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Mud.Repo
  require Logger

  @type id :: String.t()

  @derive {Jason.Encoder,
           only: [
             :id,
             :hand,
             :held_in_hand,
             :item_id,
             :area_id,
             :on_ground,
             :relation,
             :relative_to_item,
             :relative_item_id,
             :worn_on_character,
             :character_id,
             :moved_at
           ]}
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "item_locations" do
    belongs_to(:item, Mud.Engine.Item, type: :binary_id)
    field(:hand, :string, default: "right")
    field(:held_in_hand, :boolean, default: false)
    belongs_to(:area, Mud.Engine.Area, type: :binary_id)
    field(:on_ground, :boolean, default: false)
    field(:relation, :string, default: "in")
    field(:relative_to_item, :boolean, default: false)
    belongs_to(:relative_item, Mud.Engine.Item, type: :binary_id)
    field(:worn_on_character, :boolean, default: false)
    belongs_to(:character, Mud.Engine.Character, type: :binary_id)
    field(:moved_at, :utc_datetime_usec, required: true)
  end

  @doc false
  def changeset(location, attrs) do
    location
    |> change()
    |> cast(attrs, [
      :item_id,
      :hand,
      :held_in_hand,
      :area_id,
      :character_id,
      :relative_item_id,
      :moved_at,
      :on_ground,
      :relation,
      :relative_to_item,
      :worn_on_character
    ])
    |> foreign_key_constraint(:item_id)
    |> foreign_key_constraint(:area_id)
    |> foreign_key_constraint(:character_id)
    |> foreign_key_constraint(:relative_item_id)
  end

  def create(attrs \\ %{}) do
    %__MODULE__{}
    |> changeset(attrs)
    |> changeset(Map.put(attrs, :moved_at, DateTime.utc_now()))
    |> Repo.insert!()
  end

  def update!(location, attrs) do
    location
    |> changeset(attrs)
    |> Repo.update!()
  end

  def update(location, attrs) do
    location
    |> changeset(attrs)
    |> Repo.update()
  end

  @spec get!(id :: binary) :: %__MODULE__{}
  def get!(id) when is_binary(id) do
    from(
      location in __MODULE__,
      where: location.id == ^id
    )
    |> Repo.one!()
  end

  @spec get(id :: binary) :: nil | %__MODULE__{}
  def get(id) when is_binary(id) do
    from(
      location in __MODULE__,
      where: location.id == ^id
    )
    |> Repo.one()
  end
end
