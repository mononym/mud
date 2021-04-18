defmodule Mud.Engine.Link.Flags do
  use Mud.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Mud.Repo
  require Logger

  @type id :: String.t()

  @derive {Jason.Encoder,
           only: [
             :id,
             :link_id,
             :closable,
             :portal,
             :direction,
             :object,
             :sound_travels_when_open,
             :sound_travels_when_closed
           ]}
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "link_flags" do
    belongs_to(:link, Mud.Engine.Link, type: :binary_id)
    field(:closable, :boolean, default: false)
    field(:portal, :boolean, default: false)
    field(:direction, :boolean, default: false)
    field(:object, :boolean, default: false)
    field(:sound_travels_when_open, :boolean, default: true)
    field(:sound_travels_when_closed, :boolean, default: false)
  end

  @doc false
  def changeset(flags, attrs) do
    flags
    |> change()
    |> cast(attrs, [
      :link_id,
      :closable,
      :portal,
      :direction,
      :object,
      :sound_travels_when_open,
      :sound_travels_when_closed
    ])
    |> foreign_key_constraint(:link_id)
  end

  def create(attrs \\ %{}) do
    %__MODULE__{}
    |> changeset(attrs)
    |> Repo.insert!()
  end

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
