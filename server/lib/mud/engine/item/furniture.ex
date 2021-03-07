defmodule Mud.Engine.Item.Furniture do
  use Mud.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Mud.Repo
  alias Mud.Engine.Character.Status
  require Logger

  @type id :: String.t()

  @derive {Jason.Encoder,
           only: [
             :id,
             :external_surface_can_hold_characters,
             :external_surface_size,
             :has_external_surface,
             :internal_surface_can_hold_characters,
             :internal_surface_size,
             :has_internal_surface,
             :item_id
           ]}
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "item_furniture" do
    belongs_to(:item, Mud.Engine.Item, type: :binary_id)
    field(:external_surface_can_hold_characters, :boolean, default: false)
    field(:external_surface_size, :integer, default: 1)
    field(:has_external_surface, :boolean, default: false)
    field(:internal_surface_can_hold_characters, :boolean, default: false)
    field(:internal_surface_size, :integer, default: 1)
    field(:has_internal_surface, :boolean, default: false)
  end

  @doc false
  def changeset(furniture, attrs) do
    furniture
    |> change()
    |> cast(attrs, [
      :item_id,
      :external_surface_can_hold_characters,
      :external_surface_size,
      :has_external_surface,
      :internal_surface_can_hold_characters,
      :internal_surface_size,
      :has_internal_surface
    ])
    |> foreign_key_constraint(:item_id)
  end

  def create(attrs \\ %{}) do
    %__MODULE__{}
    |> changeset(attrs)
    |> Repo.insert!()
  end

  def update!(furniture, attrs) do
    furniture
    |> changeset(attrs)
    |> Repo.update!()
  end

  def update(furniture, attrs) do
    furniture
    |> changeset(attrs)
    |> Repo.update()
  end

  @spec get!(id :: binary) :: %__MODULE__{}
  def get!(id) when is_binary(id) do
    from(
      furniture in __MODULE__,
      where: furniture.id == ^id
    )
    |> Repo.one!()
  end

  @spec get(id :: binary) :: nil | %__MODULE__{}
  def get(id) when is_binary(id) do
    from(
      furniture in __MODULE__,
      where: furniture.id == ^id
    )
    |> Repo.one()
  end

  def slots_used(item_id, character_id) do
    characters =
      Status.list_all_relative_to_item(item_id) |> Enum.filter(&(&1.character_id != character_id))

    Enum.reduce(characters, 0, fn char, slots_used ->
      if char.position == "lying" do
        slots_used + 3
      else
        slots_used + 1
      end
    end)
  end
end
