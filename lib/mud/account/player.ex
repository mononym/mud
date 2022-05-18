defmodule Mud.Account.Player do
  use Ecto.Schema
  import Ecto.Changeset
  alias Mud.Account

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "players" do
    field :email, :string
    field :nickname, :string
    field :password, :string, virtual: true, redact: true
    field :hashed_password, :string, redact: true
    field :confirmed_at, :utc_datetime
    field :tos_accepted, :boolean
    field :tos_accepted_at, :utc_datetime

    has_one(:purchases, Account.Purchases)
    has_one(:settings, Account.Settings)
    many_to_many(:roles, Account.Role, join_through: "player_roles")

    timestamps()
  end

  @doc """
  A player changeset for logging in.

  It is important to validate the length of both email and password.
  Otherwise databases may truncate the email without warnings, which
  could lead to unpredictable or insecure behaviour. Long passwords may
  also be very expensive to hash for certain algorithms.
  """
  def login_changeset(player, attrs) do
    player
    |> cast(attrs, [:email, :password])
    |> validate_password([{:hash_password, false}, {:confirm_password, false}])
    |> validate_email(validate_unique: false)
  end

  @doc """
  A player changeset for registration.

  It is important to validate the length of both email and password.
  Otherwise databases may truncate the email without warnings, which
  could lead to unpredictable or insecure behaviour. Long passwords may
  also be very expensive to hash for certain algorithms.

  ## Options

    * `:hash_password` - Hashes the password so it can be stored securely
      in the database and ensures the password field is cleared to prevent
      leaks in the logs. If password hashing is not needed and clearing the
      password field is not desired (like when using this changeset for
      validations on a LiveView form), this option can be set to `false`.
      Defaults to `true`.
  """
  def registration_changeset(player, attrs, opts \\ []) do
    player
    |> cast(attrs, [:email, :nickname, :password, :tos_accepted, :tos_accepted_at])
    |> validate_required([:tos_accepted])
    |> validate_acceptance(:tos_accepted, message: "please accept the ToS")
    |> validate_email(validate_unique: true)
    |> validate_password(opts)
    |> validate_confirmation(:password, message: "does not match password")
    |> validate_nickname()
  end

  defp validate_email(changeset, opts) do
    changeset =
      changeset
      |> validate_required([:email])
      |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
      |> validate_length(:email, max: 160)

    validate_unique? = Keyword.get(opts, :validate_unique, true)

    if validate_unique? do
      changeset
      |> unsafe_validate_unique(:email, Mud.Repo)
      |> unique_constraint(:email)
    else
      changeset
    end
  end

  defp validate_nickname(changeset) do
    changeset
    |> validate_required([:nickname])
    |> validate_format(:nickname, ~r/^[a-zA-Z0-9]+[a-zA-Z0-9_\-]*[a-zA-Z0-9]+$/, message: "may only include letters, numbers, underscores, and dashes")
    |> validate_length(:nickname, min: 3, max: 30)
  end

  defp validate_password(changeset, opts) do
    changeset
    |> validate_required([:password])
    |> validate_length(:password, min: 12, max: 72)
    # |> validate_format(:password, ~r/[a-z]/, message: "at least one lower case character")
    # |> validate_format(:password, ~r/[A-Z]/, message: "at least one upper case character")
    # |> validate_format(:password, ~r/[!?@#$%^&*_0-9]/, message: "at least one digit or punctuation character")
    |> maybe_hash_password(opts)
  end

  defp maybe_hash_password(changeset, opts) do
    hash_password? = Keyword.get(opts, :hash_password, true)
    password = get_change(changeset, :password)

    if hash_password? && password && changeset.valid? do
      changeset
      # If using Bcrypt, then further validate it is at most 72 bytes long
      |> validate_length(:password, max: 72, count: :bytes)
      |> put_change(:hashed_password, Bcrypt.hash_pwd_salt(password))
      |> delete_change(:password)
    else
      changeset
    end
  end

  @doc """
  A player changeset for changing the email.

  It requires the email to change otherwise an error is added.
  """
  def email_changeset(player, attrs) do
    player
    |> cast(attrs, [:email])
    |> validate_email(validate_unique: true)
    |> case do
      %{changes: %{email: _}} = changeset -> changeset
      %{} = changeset -> add_error(changeset, :email, "did not change")
    end
  end

  @doc """
  A player changeset for changing the timezone.

  It requires the timezone to change otherwise an error is added.
  """
  def timezone_changeset(user, attrs) do
    user
    |> cast(attrs, [:timezone])
    |> validate_inclusion(:timezone, Tzdata.canonical_zone_list(), message: "must be a canonical timezone")
  end

  @doc """
  A player changeset for changing the password.

  ## Options

    * `:hash_password` - Hashes the password so it can be stored securely
      in the database and ensures the password field is cleared to prevent
      leaks in the logs. If password hashing is not needed and clearing the
      password field is not desired (like when using this changeset for
      validations on a LiveView form), this option can be set to `false`.
      Defaults to `true`.
  """
  def password_changeset(player, attrs, opts \\ []) do
    player
    |> cast(attrs, [:password])
    |> validate_confirmation(:password, message: "does not match password")
    |> validate_password(opts)
  end

  @doc """
  Confirms the account by setting `confirmed_at`.
  """
  def confirm_changeset(player) do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    change(player, confirmed_at: now)
  end

  @doc """
  Verifies the password.

  If there is no player or the player doesn't have a password, we call
  `Bcrypt.no_user_verify/0` to avoid timing attacks.
  """
  def valid_password?(%Mud.Account.Player{hashed_password: hashed_password}, password)
      when is_binary(hashed_password) and byte_size(password) > 0 do
    Bcrypt.verify_pass(password, hashed_password)
  end

  def valid_password?(_, _) do
    Bcrypt.no_user_verify()
    false
  end

  @doc """
  Validates the current password otherwise adds an error to the changeset.
  """
  def validate_current_password(changeset, password) do
    if valid_password?(changeset.data, password) do
      changeset
    else
      add_error(changeset, :current_password, "is not valid")
    end
  end
end
