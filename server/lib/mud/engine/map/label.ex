defmodule Mud.Engine.Map.Label do
  use Mud.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Mud.Repo
  alias Mud.Engine.Map
  require Logger

  @type id :: String.t()

  @keys [
    :text,
    :x,
    :y,
    :vertical_offset,
    :horizontal_offset,
    :rotation,
    :color,
    :size,
    :weight,
    :map_id
  ]

  @derive Jason.Encoder
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "map_labels" do
    field(:text, :string, default: "")
    field(:x, :integer, default: 0)
    field(:y, :integer, default: 0)
    field(:vertical_offset, :integer, default: 0)
    field(:horizontal_offset, :integer, default: 0)
    field(:rotation, :integer, default: 0)
    field(:color, :string, default: "white")
    field(:size, :integer, default: 20)
    field(:weight, :integer, default: 50)

    belongs_to(:map, Map)

    timestamps()
  end

  @doc false
  def changeset(flags, attrs) do
    flags
    |> change()
    |> cast(attrs, @keys)
    |> foreign_key_constraint(:map_id)
    |> validate_required(@keys)
  end

  def create(attrs \\ %{}) do
    label =
      %__MODULE__{}
      |> changeset(attrs)
      |> Repo.insert!()

    {:ok, label}
  end

  @spec update!(
          {map, any} | %{__struct__: atom | %{__changeset__: any}},
          :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}
        ) :: any
  def update!(flags, attrs) do
    flags
    |> changeset(attrs)
    |> Repo.update!()
  end

  def update(flags, attrs) do
    flags
    |> changeset(attrs)
    |> Repo.update()
  end

  @spec get!(id :: binary) :: %__MODULE__{}
  def get!(id) when is_binary(id) do
    from(
      flags in __MODULE__,
      where: flags.id == ^id
    )
    |> Repo.one!()
  end

  @spec get(id :: binary) :: nil | %__MODULE__{}
  def get(id) when is_binary(id) do
    from(
      flags in __MODULE__,
      where: flags.id == ^id
    )
    |> Repo.one()
  end

  @doc """
  Get all the labels that belong to a single Map

  ## Examples

      iex> get_map_labels(good_map_id)
      [%__MODULE__{}]
  """
  @spec get_map_labels(map_id :: binary) :: [%__MODULE__{}]
  def get_map_labels(map_id) do
    from(
      label in __MODULE__,
      where: label.map_id == ^map_id
    )
    |> Repo.all()
  end

  @doc """
  Deletes a label.

  ## Examples

      iex> delete(label)
      {:ok, %__MODULE__{}}

      iex> delete(label)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete(area :: %__MODULE__{}) :: {:ok, %__MODULE__{}} | {:error, %Ecto.Changeset{}}
  def delete(%__MODULE__{} = label) do
    Repo.delete(label)
  end
end
