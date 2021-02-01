defmodule Mud.Engine.Link.Closable do
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
             :character_id,
             :open,
             :locked,
             :owned
           ]}
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "link_closables" do
    belongs_to(:link, Mud.Engine.Link, type: :binary_id)

    field(:open, :boolean, default: false)
    field(:locked, :boolean, default: false)

    #
    # Closables can have an owner in the case of merchants shops, houses, castle gates, etc...
    #
    field(:owned, :boolean, default: false)
    belongs_to(:character, Mud.Engine.Character, type: :binary_id)
  end

  @doc false
  def changeset(closable, attrs) do
    closable
    |> change()
    |> cast(attrs, [
      :link_id,
      :character_id,
      :open,
      :locked,
      :owned
    ])
    |> validate_required([:link_id])
    |> foreign_key_constraint(:link_id)
    |> foreign_key_constraint(:character_id)
  end

  def create(attrs \\ %{}) do
    %__MODULE__{}
    |> changeset(attrs)
    |> Repo.insert!()
  end

  def update!(closable, attrs) do
    closable
    |> changeset(attrs)
    |> Repo.update!()
  end

  def update(closable, attrs) do
    closable
    |> changeset(attrs)
    |> Repo.update()
  end

  @spec get!(id :: binary) :: %__MODULE__{}
  def get!(id) when is_binary(id) do
    from(
      closable in __MODULE__,
      where: closable.id == ^id
    )
    |> Repo.one!()
  end

  @spec get(id :: binary) :: nil | %__MODULE__{}
  def get(id) when is_binary(id) do
    from(
      closable in __MODULE__,
      where: closable.id == ^id
    )
    |> Repo.one()
  end
end
