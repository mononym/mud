defmodule Mud.Account.Player do
  @moduledoc false

  use Mud.Schema

  import Ecto.Changeset

  alias Mud.Account
  alias Mud.Repo
  require Logger

  @derive {Jason.Encoder,
           only: [
             :id,
             :auth,
             :inserted_at,
             :profile,
             :settings,
             :status,
             :sub,
             :tos_accepted,
             :updated_at
           ]}
  schema "players" do
    field(:status, Account.Enums.PlayerStatus)
    field(:tos_accepted, :boolean, default: false)
    field(:sub, :string)

    has_one(:profile, Account.Profile)
    has_one(:settings, Account.Settings)

    timestamps()
  end

  @doc """
  Gets a single player struct by the id.

  ## Examples

      iex> get(123)
      {:ok, %Player{}}

      iex> get(456)
      {:error, :not_found}
  """
  def get(id) do
    case Repo.get(__MODULE__, id) do
      nil ->
        {:error, :not_found}

      player ->
        {:ok, preload(player)}
    end
  end

  @doc """
  Gets a single player struct by the id, throws an error if there is no player.

  ## Examples

      iex> get!(123)
      %Player{}
  """
  def get!(id) do
    player = Repo.get!(__MODULE__, id)

    preload(player)
  end

  @doc """
  Gets a single Player struct by the sub id.

  ## Examples

      iex> get_by_sub(123)
      {:ok, %Player{}}

      iex> get_by_sub(456)
      {:error, :not_found}

  """
  def get_by_sub(sub) do
    Logger.debug(sub)

    case Repo.get_by(__MODULE__, sub: sub) do
      nil ->
        {:error, :not_found}

      player ->
        {:ok, preload(player)}
    end
  end

  @spec new(map) :: Ecto.Changeset.t()
  def new(params) do
    %__MODULE__{}
    |> cast(params, [:status, :sub, :tos_accepted])
    |> validate()
  end

  @spec update(%Mud.Account.Player{}, map) :: Ecto.Changeset.t()
  def update(player = %__MODULE__{}, params) do
    player
    |> cast(params, [:status, :sub, :tos_accepted])
    |> validate()
  end

  defp preload(player), do: Repo.preload(player, [:profile, :settings])

  defp validate(player) do
    player
    |> validate_required([:status, :sub, :tos_accepted])
    |> validate_inclusion(:status, apply(Account.Enums.PlayerStatus, :__valid_values__, []))
    |> validate_change(:tos_accepted, fn _, term ->
      if is_boolean(term) do
        []
      else
        [tos_accepted: "must be a boolean value"]
      end
    end)
    |> validate_format(
      :id,
      ~r/^[0-9A-F]{8}-[0-9A-F]{4}-4[0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}$/
    )
  end
end
