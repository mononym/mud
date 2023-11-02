defmodule Mud.Engine.Character.Containers do
  use Mud.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Mud.Repo
  require Logger

  @type id :: String.t()

  @derive {Jason.Encoder,
           only: [
             :id,
             :character_id,
             :default_id,
             :weapon_id,
             :armor_id,
             :gem_id,
             :ammunition_id,
             :shield_id,
             :clothing_id
           ]}
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "character_containers" do
    belongs_to(:character, Mud.Engine.Character, type: :binary_id)
    belongs_to(:default, Mud.Engine.Item, type: :binary_id)
    belongs_to(:weapon, Mud.Engine.Item, type: :binary_id)
    belongs_to(:armor, Mud.Engine.Item, type: :binary_id)
    belongs_to(:gem, Mud.Engine.Item, type: :binary_id)
    belongs_to(:ammunition, Mud.Engine.Item, type: :binary_id)
    belongs_to(:shield, Mud.Engine.Item, type: :binary_id)
    belongs_to(:clothing, Mud.Engine.Item, type: :binary_id)
  end

  @doc false
  def changeset(containers, attrs) do
    containers
    |> change()
    |> cast(attrs, [
      :character_id,
      :default_id,
      :weapon_id,
      :armor_id,
      :gem_id,
      :ammunition_id,
      :shield_id,
      :clothing_id
    ])
    |> foreign_key_constraint(:character_id)
  end

  def create(attrs \\ %{}) do
    %__MODULE__{}
    |> changeset(attrs)
    |> Repo.insert!()

    :ok
  end

  def update!(containers_id, attrs) when is_binary(containers_id) do
    keywords =
      attrs
      |> Keyword.new()
      |> Keyword.put_new(:updated_at, Timex.now())

    containers =
      from(containers in __MODULE__, where: containers.id == ^containers_id, select: containers)
      |> Repo.update_all(set: keywords)
      |> elem(1)
      |> List.first()

    containers
  end

  def update!(containers, attrs) do
    containers
    |> changeset(attrs)
    |> Repo.update!()
  end

  def update(containers, attrs) do
    containers
    |> changeset(attrs)
    |> Repo.update()
  end

  @spec get!(id :: binary) :: %__MODULE__{}
  def get!(id) when is_binary(id) do
    from(
      containers in __MODULE__,
      where: containers.id == ^id
    )
    |> Repo.one!()
  end

  @spec get(id :: binary) :: nil | %__MODULE__{}
  def get(id) when is_binary(id) do
    from(
      containers in __MODULE__,
      where: containers.id == ^id
    )
    |> Repo.one()
  end

  @spec list(id :: binary) :: nil | [%__MODULE__{}]
  def list(character_id) when is_binary(character_id) do
    from(
      containers in __MODULE__,
      where: containers.character_id == ^character_id
    )
    |> Repo.all()
  end
end
