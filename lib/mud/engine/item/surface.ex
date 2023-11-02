defmodule Mud.Engine.Item.Surface do
  use Mud.Schema
  import Ecto.Changeset
  import Ecto.Query
  require Logger
  alias Mud.Repo

  @all_fields [
    :item_id,
    :can_hold_characters,
    :item_count_limit,
    :item_weight_limit,
    :character_limit,
    :show_item_contents,
    :show_item_limit,
    :show_detailed_items,
    :items_must_fit,
    :length,
    :width
  ]

  @derive {Jason.Encoder, only: [:id | @all_fields]}
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "item_surface" do
    belongs_to(:item, Mud.Engine.Item, type: :binary_id)
    field(:can_hold_characters, :boolean, default: false)
    field(:character_limit, :integer, default: 0)
    field(:item_count_limit, :integer, default: 0)
    field(:item_weight_limit, :integer, default: 0)
    field(:show_item_contents, :boolean, default: true)
    field(:show_detailed_items, :boolean, default: false)
    field(:show_item_limit, :integer, default: 0)
    field(:items_must_fit, :boolean, default: false)
    field(:length, :integer, default: 0)
    field(:width, :integer, default: 0)
  end

  @spec changeset(
          {map, any}
          | %{
              :__struct__ => atom | %{:__changeset__ => any, optional(any) => any},
              optional(any) => any
            },
          :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}
        ) :: Ecto.Changeset.t()
  @doc false
  def changeset(surface, attrs) do
    surface
    |> change()
    |> cast(attrs, @all_fields)
    |> validate_required(@all_fields)
    |> validate_number(:character_limit, greater_than_or_equal_to: 0)
    |> validate_number(:item_count_limit, greater_than_or_equal_to: 0)
    |> validate_number(:item_weight_limit, greater_than_or_equal_to: 0)
    |> validate_number(:show_item_limit, greater_than_or_equal_to: 0)
    |> validate_number(:length, greater_than_or_equal_to: 0)
    |> validate_number(:width, greater_than_or_equal_to: 0)
  end

  def create(attrs \\ %{}) do
    Logger.debug("Creating item surface with attrs: #{inspect(attrs)}")

    %__MODULE__{}
    |> changeset(attrs)
    |> Repo.insert!()
  end

  def update!(surface, attrs) do
    Logger.debug("Updating item surface #{inspect(surface)} with attrs: #{inspect(attrs)}")

    surface
    |> changeset(attrs)
    |> Repo.update!()
  end

  def update(surface, attrs) do
    Logger.debug("Updating item surface #{inspect(surface)} with attrs: #{inspect(attrs)}")

    surface
    |> changeset(attrs)
    |> Repo.update()
  end

  @spec get!(id :: binary) :: %__MODULE__{}
  def get!(id) when is_binary(id) do
    Logger.debug("Getting item surface with id: #{id}")

    from(
      surface in __MODULE__,
      where: surface.id == ^id
    )
    |> Repo.one!()
  end

  @spec get(id :: binary) :: nil | %__MODULE__{}
  def get(id) when is_binary(id) do
    Logger.debug("Getting item surface with id: #{id}")

    from(
      surface in __MODULE__,
      where: surface.id == ^id
    )
    |> Repo.one()
  end

  def character_slots_used(item_id, character_id) do
    characters =
      Mud.Engine.Character.Status.list_all_relative_to_item(item_id)
      |> Enum.filter(&(&1.character_id != character_id))

    length(characters)
  end
end
