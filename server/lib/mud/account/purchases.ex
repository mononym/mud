defmodule Mud.Account.Purchases do
  @moduledoc """
  Data for keeping track of the purchases for a Player.

  Created initially for tracking the Crowns for a Player so that they could be accessed from all characters.
  """

  use Mud.Schema
  import Ecto.Changeset
  alias Mud.Repo

  @all_fields [:crowns, :player_id]

  @derive {Jason.Encoder,
           only: [
             :inserted_at,
             :player_id,
             :crowns,
             :updated_at
           ]}
  @primary_key {:player_id, :binary_id, autogenerate: false}
  schema "player_purchases" do
    field(:crowns, :integer, default: 0)

    belongs_to(:player, Mud.Account.Player,
      type: :binary_id,
      foreign_key: :player_id,
      primary_key: true,
      define_field: false
    )

    timestamps()
  end

  @doc """
  Gets a single purchases struct by the id, throws an error if there are no purchases.

  ## Examples

      iex> get!(123)
      %Purchases{}
  """
  def get!(player_id) do
    Repo.get!(__MODULE__, player_id)
  end

  @doc """
  Transform a struct into a changeset.
  """
  @spec changeset(struct()) :: Ecto.Changeset.t()
  def changeset(purchases) when is_struct(purchases) do
    change(purchases)
  end

  @doc """
  Update an purchases struct with the data in the passed in map.
  """
  @spec update(struct(), map()) :: Ecto.Changeset.t()
  def update(purchases, attrs) when is_struct(purchases) and is_map(attrs) do
    purchases
    |> cast(attrs, @all_fields -- [:player_id])
    |> validate_required(@all_fields)
    |> validate()
  end

  @doc """
  Build a new purchases struct with the data in the passed in map.
  """
  @spec new(map()) :: Ecto.Changeset.t()
  def new(attrs) when is_map(attrs) do
    %__MODULE__{}
    |> cast(attrs, @all_fields)
    |> validate_required(@all_fields)
    |> validate()
  end

  @spec validate(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  defp validate(purchases) when is_struct(purchases) do
    purchases
  end
end
