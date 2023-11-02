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
             :moved_at,
             :stow_home_id
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
    field(:moved_at, :utc_datetime_usec)
    belongs_to(:stow_home, Mud.Engine.Item, type: :binary_id)
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
      :worn_on_character,
      :stow_home_id
    ])
    |> foreign_key_constraint(:item_id)
    |> foreign_key_constraint(:area_id)
    |> foreign_key_constraint(:character_id)
    |> foreign_key_constraint(:relative_item_id)
  end

  def create(attrs \\ %{}) do
    Logger.debug("Creating item location with attrs: #{inspect(attrs)}")

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

  @spec get_by_item_id!(item_id :: binary) :: %__MODULE__{}
  def get_by_item_id!(item_id) when is_binary(item_id) do
    from(
      location in __MODULE__,
      where: location.item_id == ^item_id
    )
    |> Repo.one!()
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

  def update_relative_to_item!(location, item_id, relation) do
    update!(location, %{
      held_in_hand: false,
      on_ground: false,
      area_id: nil,
      character_id: nil,
      relative_item_id: item_id,
      relative_to_item: true,
      relation: relation,
      worn_on_character: false,
      moved_at: DateTime.utc_now()
    })
  end

  def update_held_item!(location, character_id, hand \\ "right") do
    update!(location, %{
      held_in_hand: true,
      hand: hand,
      on_ground: false,
      area_id: nil,
      character_id: character_id,
      relative_item_id: nil,
      relative_to_item: false,
      worn_on_character: false,
      moved_at: DateTime.utc_now()
    })
  end

  def update_on_ground_item!(location, area_id) do
    update!(location, %{
      held_in_hand: false,
      on_ground: true,
      area_id: area_id,
      character_id: nil,
      relative_item_id: nil,
      relative_to_item: false,
      worn_on_character: false,
      moved_at: DateTime.utc_now()
    })
  end

  def update_stow_home!(location, stow_home_id) do
    update!(location, %{
      stow_home_id: stow_home_id
    })
  end

  def update_worn_item!(location, character_id) do
    update!(location, %{
      held_in_hand: false,
      on_ground: false,
      area_id: nil,
      character_id: character_id,
      relative_item_id: nil,
      relative_to_item: false,
      worn_on_character: true,
      moved_at: DateTime.utc_now()
    })
  end
end
