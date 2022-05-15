defmodule Mud.Account.Auth do
  @moduledoc """
  All authentication for the Account system is handled via Auth0 which acts as the canonical "user info provider".
  """

  use Mud.Schema
  import Ecto.Changeset

  @all_fields [:email, :email_verified, :nickname, :picture, :player_id, :sub]

  @primary_key {:player_id, :binary_id, autogenerate: false}
  schema "account_auth" do
    field(:email, :binary)
    field(:email_verified, :boolean, default: false)
    field(:nickname, :string)
    field(:sub, :string)
    field(:picture, :string)

    belongs_to(:player, Mud.Account.Player,
      type: :binary_id,
      foreign_key: :player_id,
      primary_key: true,
      define_field: false
    )

    timestamps()
  end

  @doc """
  Gets a single auth struct by the sub id.

  ## Examples

      iex> get_by_sub(123)
      {:ok, %Auth{}}

      iex> get_by_sub(456)
      {:error, :not_found}

  """
  def get_by_sub(sub) do
    case Repo.get_by(Auth, sub: sub) do
      nil ->
        {:error, :not_found}

      player ->
        {:ok, player}
    end
  end

  @doc """
  Transform a struct into a changeset.
  """
  @spec changeset(struct()) :: Ecto.Changeset.t()
  def changeset(auth) when is_struct(auth) do
    change(auth)
  end

  @doc """
  Update an auth struct with the data in the passed in map.
  """
  @spec update(struct(), map()) :: Ecto.Changeset.t()
  def update(auth, attrs) when is_struct(auth) and is_map(attrs) do
    auth
    |> cast(attrs, @all_fields -- [:player_id, :sub])
    |> validate_required(@all_fields)
    |> validate()
  end

  @doc """
  Build a new auth struct with the data in the passed in map.
  """
  @spec new(map()) :: Ecto.Changeset.t()
  def new(attrs) when is_map(attrs) do
    %__MODULE__{}
    |> cast(attrs, @all_fields)
    |> validate_required(@all_fields)
    |> validate()
  end

  @spec validate(Ecto.Changeset.t(), boolean()) :: Ecto.Changeset.t()
  defp validate(auth, unsafe \\ false) when is_struct(auth) and is_boolean(unsafe) do
    auth =
      auth
      |> change()
      |> validate_format(:email, ~r/.+@.+/)
      |> validate_length(:email, min: 3, max: 254)
      |> unique_constraint(:email)

    if unsafe do
      unsafe_validate_unique(auth, [:email], Mud.Repo)
    else
      auth
    end
  end
end
