defmodule Mud.Account.Player do
  @moduledoc false

  use Mud.Schema

  import Ecto.Changeset

  alias Mud.Account

  schema "players" do
    field(:status, Account.Enums.PlayerStatus)
    field(:tos_accepted, :boolean, default: false)

    has_one(:auth_email, Account.AuthEmail)
    has_one(:profile, Account.Profile)
    has_one(:settings, Account.Settings)

    timestamps()
  end

  @spec new(map) :: Ecto.Changeset.t()
  def new(params) do
    %__MODULE__{}
    |> cast(params, [:status, :tos_accepted])
    |> validate()
  end

  @spec update(Mud.Account.Player.t(), map) :: Ecto.Changeset.t()
  def update(player = %__MODULE__{}, params) do
    player
    |> cast(params, [:status, :tos_accepted])
    |> validate()
  end

  defp validate(player) do
    player
    |> validate_required([:status, :tos_accepted])
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
