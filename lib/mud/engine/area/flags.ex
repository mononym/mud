defmodule Mud.Engine.Area.Flags do
  use Mud.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Mud.Repo
  require Logger

  @type id :: String.t()

  @derive {Jason.Encoder,
           only: [
             :id,
             :area_id,
             :bank
           ]}
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "area_flags" do
    belongs_to(:area, Mud.Engine.Area, type: :binary_id)
    field(:bank, :boolean, default: false)
    field(:permanently_explored, :boolean, default: false)
  end

  @doc false
  def changeset(flags, attrs) do
    flags
    |> change()
    |> cast(attrs, [
      :area_id,
      :bank,
      :permanently_explored
    ])
    |> foreign_key_constraint(:area_id)
  end

  def create(attrs \\ %{}) do
    %__MODULE__{}
    |> changeset(attrs)
    |> Repo.insert!()
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
end
