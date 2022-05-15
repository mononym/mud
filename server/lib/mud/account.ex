defmodule Mud.Account do
  @moduledoc """
  The API for the Account context.

  The constants or schemas can be used for pattern matching, but all Account functionality can be found here.

  ## Overview
  All functionality that is intrinsically tied to the existence of a Player can be found here. Something like Billing,
  while providing the ability for a Player to subscribe to a recurring payment, can be used anonymously by someone via
  the Store and so is in its own context.
  """

  import Ecto.Query, warn: false

  alias Mud.Account
  alias Mud.Account.{Auth, Player, Purchases, Settings}
  alias Mud.Repo

  require Logger

  @topic inspect(__MODULE__)

  @doc """
  Subscribe to the PubSub topic for all Account events.
  """
  @spec subscribe :: {:ok, :subscribed}
  def subscribe do
    :ok = Phoenix.PubSub.subscribe(Mud.PubSub, @topic)
    {:ok, :subscribed}
  end

  @doc """
  Subscribe to the PubSub topic for all Account events related to a single Player.
  """
  @spec subscribe(integer()) :: {:ok, :subscribed}
  def subscribe(player_id) when is_integer(player_id) do
    :ok = Phoenix.PubSub.subscribe(Mud.PubSub, @topic <> ":#{player_id}")
    {:ok, :subscribed}
  end

  @doc """
  Send a login or welcome email out based on whether or not a Player exists that uses the provided email.

  New Players will be directed to the TOS page. Returning Players will be directed to the Player Dashboard.
  """
  def authenticate_via_email(email_address) do
    auth_token = UUID.uuid4() |> String.replace("-", "")

    # TODO: Sort out what happens when email is submitted second time before account creation finished
    case lookup_player_by_auth_email(email_address) do
      {:ok, player_id} ->
        Logger.info(
          "Starting authentication for existing player `#{player_id}` with token `#{auth_token}` and expiry `#{Application.get_env(:mud, :login_token_ttl)}`"
        )

        redis_set_player_auth_token(
          auth_token,
          "login",
          player_id,
          Application.get_env(:mud, :login_token_ttl)
        )

        Mud.Account.Emails.login_email(
          email_address,
          Application.get_env(:mud, :no_reply_email_address),
          auth_token
        )
        |> Mud.Mailer.deliver_later()

        {:ok, :player_found}

      {:error, :not_found} ->
        signup_new_player(email_address, auth_token)
    end
  end

  defp signup_new_player(email_address, auth_token) do
    email_hash = hash_email(email_address)
    encrypted_email = Mud.Vault.encrypt!(email_address)

    player_changeset = Player.new(%{status: Account.Constants.PlayerStatus.pending()})

    Ecto.Multi.new()
    |> perform_email_hash_precheck(email_address, email_hash)
    |> Ecto.Multi.insert(:insert_player, player_changeset)
    |> insert_player_auth(encrypted_email, email_hash)
    |> insert_settings()
    |> insert_profile()
    |> Repo.transaction()
    |> case do
      {:ok, %{insert_player: player}} ->
        redis_set_player_auth_token(
          auth_token,
          "signup",
          player.id,
          Application.get_env(:mud, :create_player_token_ttl)
        )

        Mud.Account.Emails.welcome_email(
          email_address,
          Application.get_env(:mud, :no_reply_email_address),
          auth_token
        )
        |> Mud.Mailer.deliver_later()

        {:ok, :player_created}

      _error ->
        {:error, :player_not_created}
    end
  end

  defp perform_email_hash_precheck(multi, email_address, email_hash) do
    Ecto.Multi.run(multi, :precheck, fn _repo, _ ->
      Repo.all(
        from(auth_email in Mud.Account.AuthEmail,
          where: auth_email.hash == ^email_hash,
          select: auth_email.email
        )
      )
      |> Enum.filter(fn encrypted_email ->
        Mud.Vault.decrypt!(encrypted_email) === email_address
      end)
      |> case do
        [] ->
          {:ok, :not_found}

        [_] ->
          {:error, :email_in_use}
      end
    end)
  end

  defp insert_player_auth(multi, encrypted_email, email_hash) do
    multi
    |> UberMulti.run(
      :build_auth,
      [:insert_player, :auth_email, %{email: encrypted_email, hash: email_hash}],
      &Ecto.build_assoc/3,
      true
    )
    |> UberMulti.run(:insert_auth, [:build_auth], &Repo.insert/1)
  end

  defp insert_settings(multi) do
    multi
    |> UberMulti.run(
      :build_settings,
      [:insert_player, :settings, %{}],
      &Ecto.build_assoc/3,
      true
    )
    |> UberMulti.run(:insert_settings, [:build_settings], &Repo.insert/1)
  end

  defp insert_profile(multi) do
    multi
    |> UberMulti.run(
      :build_profile,
      [:insert_player, :profile, %{}],
      &Ecto.build_assoc/3,
      true
    )
    |> UberMulti.run(:insert_profile, [:build_profile], &Repo.insert/1)
  end

  defp redis_set_player_auth_token(auth_token, type, player_id, expiry) do
    Redix.command!(:redix, [
      "SET",
      "player-auth-token:#{auth_token}",
      "#{type}:#{player_id}",
      "EX",
      expiry
    ])
  end

  @doc """
  Verify an auth token and, if valid, return the Player it points to.

  ## Examples

      iex> validate_auth_token(token)
      {:ok, %Player{}}

      iex> validate_auth_token(bad_token)
      {:error, :invalid}
  """
  def validate_auth_token(auth_token) do
    case Redix.command!(:redix, ["GET", "player-auth-token:#{auth_token}"]) do
      nil ->
        {:error, :invalid}

      string ->
        Redix.command!(:redix, ["DEL", "player-auth-token:#{auth_token}"])

        [type, player_id] = String.split(string, ":")
        player_update_query = from(player in Account.Player, where: player.id == ^player_id)

        player_select_query =
          from(player in Account.Player,
            join: settings in Account.Settings,
            on: settings.player_id == player.id,
            join: profile in Account.Profile,
            on: profile.player_id == player.id,
            where: player.id == ^player_id,
            preload: [:profile, :settings]
          )

        case type do
          "signup" ->
            from(auth_email in Account.AuthEmail, where: auth_email.player_id == ^player_id)
            |> Mud.Repo.update_all(set: [email_verified: true])

            Mud.Repo.update_all(player_update_query,
              set: [status: Account.Constants.PlayerStatus.created()]
            )

            player = Mud.Repo.one!(player_select_query)

            {:ok, player}

          "login" ->
            player = Mud.Repo.one!(player_select_query)

            {:ok, player}
        end
    end
  end

  @doc """
  Facilitates the creation of a Player with an Email and Nickname.

  While the Player must supply the Email address and Nickname, these actually belong to the Profile rather than the
  Player. This function handles the creation and linking of the Player and Profile as well as the instantion of
  anything else required for an Account to work correctly, such as Roles etc...

  Will return a changeset if there was an error.

  ## Examples

      iex> create_player(params)
      {:ok, %Player{}}

      iex> create_player(bad_params)
      {:error, %Ecto.Changeset{}}
  """
  def create_player(params) when is_map(params) do
    params
    |> Player.new()
    |> Repo.insert()
    |> notify_subscribers([:player, :created])
  end

  @doc """
  Returns the list of players in a paginated manner, wrapped in a success tuple.

  ## Examples
      iex> list_players()
      {:ok, [%Player{}, ...]}
  """
  def list_players() do
    {:ok,
     Repo.all(
       from(player in Player,
         order_by: [asc: player.inserted_at],
         preload: :profile
       )
     )}
  end

  @doc """
  Returns the list of players in a paginated manner, wrapped in a success tuple.

  ## Examples
      iex> list_players(1, 100)
      {:ok, [%Player{}, ...]}
  """
  def list_players(page, page_size)
      when is_integer(page) and page > 0 and is_integer(page_size) and page_size > 0 do
    {:ok,
     Repo.all(
       from(player in Player,
         order_by: [asc: player.inserted_at],
         offset: ^((page - 1) * page_size),
         limit: ^page_size,
         preload: :profile
       )
     )}
  end

  @doc """
  Deletes a Player.

  ## Examples

      iex> delete_player(player)
      {:ok, %Player{}}

      iex> delete_player(player)
      {:error, %Ecto.Changeset{}}

  """
  def delete_player(%Player{} = player) do
    Repo.delete(player)
    |> notify_subscribers([:player, :deleted])
  end

  @doc """
  Updates a player.

  ## Examples

      iex> update_player(player, %{field: new_value})
      {:ok, %Player{}}

      iex> update_player(player, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_player(%Player{} = player, attrs) do
    player
    |> Player.update(attrs)
    |> Repo.update()
    |> notify_subscribers([:player, :updated])
  end

  alias Mud.Account.Profile

  @doc """
  Returns the list of profiles.

  ## Examples

      iex> list_profiles()
      {:ok, [%Profile{}, ...]}

  """
  def list_profiles do
    Profile
    |> Repo.all()
    |> (&{:ok, &1}).()
  end

  @doc """
  Gets a single profile.

  Raises `Ecto.NoResultsError` if the Profile does not exist.

  ## Examples

      iex> get_profile!(123)
      %Profile{}

      iex> get_profile!(456)
      ** (Ecto.NoResultsError)

  """
  def get_profile!(id), do: Repo.get!(Profile, id)

  @doc """
  Creates a profile.

  ## Examples

      iex> create_profile(%{field: value})
      {:ok, %Profile{}}

      iex> create_profile(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_profile(attrs \\ %{}) do
    Profile.new(attrs)
    |> Repo.insert()
    |> notify_subscribers([:profile, :created])
  end

  @doc """
  Updates a profile.

  ## Examples

      iex> update_profile(profile, %{field: new_value})
      {:ok, %Profile{}}

      iex> update_profile(profile, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_profile(%Profile{} = profile, attrs) do
    profile
    |> Profile.update(attrs)
    |> Repo.update()
    |> notify_subscribers([:profile, :updated])
  end

  @doc """
  Deletes a Profile.

  ## Examples

      iex> delete_profile(profile)
      {:ok, %Profile{}}

      iex> delete_profile(profile)
      {:error, %Ecto.Changeset{}}

  """
  def delete_profile(%Profile{} = profile) do
    Repo.delete(profile)
    |> notify_subscribers([:profile, :deleted])
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking profile changes.

  ## Examples

      iex> change_profile(profile)
      %Ecto.Changeset{source: %Profile{}}

  """
  def change_profile(%Profile{} = profile) do
    Profile.changeset(profile)
  end

  def save_player_settings(params) do
    case Repo.get!(Settings, params.player_id) do
      settings = %Settings{} ->
        Settings.update(settings, params)
        |> Repo.update()
        |> case do
          {:ok, settings} ->
            {:ok, settings}

          error = {:error, _} ->
            error
        end
    end
  end

  @doc """
  Create a new account or retrieve an existing one based on the OAuth2 data provided.
  """
  def from_auth(user) do
    Logger.debug(inspect(user["sub"]))
    # get id that should be checked
    # try to read account from db
    case Player.get_by_sub(user["sub"]) do
      ok_result = {:ok, _} ->
        ok_result

      _ ->
        args = %{
          profile: %Profile{
            email: user["email"] || "",
            email_verified: user["email_verified"] || false,
            nickname: user["nickname"] || "",
            picture: user["picture"] || ""
          },
          status: Account.Constants.PlayerStatus.created(),
          sub: user["sub"]
        }

        player = Player.new(args) |> Repo.insert!()

        profile =
          Ecto.build_assoc(player, :profile, %{
            email: user["email"] || "",
            email_verified: user["email_verified"] || false,
            nickname: user["nickname"] || "",
            picture: user["picture"] || ""
          })
          |> Repo.insert!()

        purchases = Ecto.build_assoc(player, :purchases, %{}) |> Repo.insert!()
        settings = Ecto.build_assoc(player, :settings, %{}) |> Repo.insert!()

        {:ok, %{player | profile: profile, purchases: purchases, settings: settings}}
    end
  end

  #
  # Private functions
  #

  defp hash_email(email_address), do: :crypto.hash(:sha, email_address) |> String.slice(0..4)

  defp lookup_player_by_auth_email(email) do
    email_hash = hash_email(email)

    Repo.all(
      from(player in Player,
        join: auth_email in Mud.Account.AuthEmail,
        where: player.id == auth_email.player_id and auth_email.hash == ^email_hash,
        select: %{player: player.id, email: auth_email.email}
      )
    )
    |> Enum.find(fn %{email: encrypted_email} ->
      Mud.Vault.decrypt!(encrypted_email) === email
    end)
    |> case do
      nil ->
        {:error, :not_found}

      %{player: player_id} ->
        {:ok, player_id}
    end
  end

  defp notify_subscribers(result, event, global_only \\ false)

  defp notify_subscribers({:ok, result}, event, global_only) do
    Phoenix.PubSub.broadcast(Mud.PubSub, @topic, {__MODULE__, event, result})

    if not global_only do
      Phoenix.PubSub.broadcast(
        Mud.PubSub,
        @topic <> ":#{get_id(result)}",
        {__MODULE__, event, result}
      )
    end

    {:ok, result}
  end

  defp notify_subscribers({:error, reason}, _event, _global_only), do: {:error, reason}

  defp get_id(%Account.Player{id: id}), do: id
  defp get_id(%{player_id: id}), do: id

  alias Mud.Account.Role

  @doc """
  Returns the list of roles.

  ## Examples

      iex> list_roles()
      [%Role{}, ...]

  """
  def list_roles do
    Repo.all(Role)
  end

  @doc """
  Gets a single role.

  Raises `Ecto.NoResultsError` if the Role does not exist.

  ## Examples

      iex> get_role!(123)
      %Role{}

      iex> get_role!(456)
      ** (Ecto.NoResultsError)

  """
  def get_role!(id), do: Repo.get!(Role, id)

  @doc """
  Creates a role.

  ## Examples

      iex> create_role(%{field: value})
      {:ok, %Role{}}

      iex> create_role(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_role(attrs \\ %{}) do
    %Role{}
    |> Role.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a role.

  ## Examples

      iex> update_role(role, %{field: new_value})
      {:ok, %Role{}}

      iex> update_role(role, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_role(%Role{} = role, attrs) do
    role
    |> Role.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a role.

  ## Examples

      iex> delete_role(role)
      {:ok, %Role{}}

      iex> delete_role(role)
      {:error, %Ecto.Changeset{}}

  """
  def delete_role(%Role{} = role) do
    Repo.delete(role)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking role changes.

  ## Examples

      iex> change_role(role)
      %Ecto.Changeset{data: %Role{}}

  """
  def change_role(%Role{} = role, attrs \\ %{}) do
    Role.changeset(role, attrs)
  end

  alias Mud.Account.PlayerRole

  @doc """
  Returns the list of player_roles.

  ## Examples

      iex> list_player_roles()
      [%PlayerRole{}, ...]

  """
  def list_player_roles do
    Repo.all(PlayerRole)
  end

  @doc """
  Gets a single player_role.

  Raises `Ecto.NoResultsError` if the Player role does not exist.

  ## Examples

      iex> get_player_role!(123)
      %PlayerRole{}

      iex> get_player_role!(456)
      ** (Ecto.NoResultsError)

  """
  def get_player_role!(id), do: Repo.get!(PlayerRole, id)

  @doc """
  Creates a player_role.

  ## Examples

      iex> create_player_role(%{field: value})
      {:ok, %PlayerRole{}}

      iex> create_player_role(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_player_role(attrs \\ %{}) do
    %PlayerRole{}
    |> PlayerRole.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a player_role.

  ## Examples

      iex> update_player_role(player_role, %{field: new_value})
      {:ok, %PlayerRole{}}

      iex> update_player_role(player_role, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_player_role(%PlayerRole{} = player_role, attrs) do
    player_role
    |> PlayerRole.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a player_role.

  ## Examples

      iex> delete_player_role(player_role)
      {:ok, %PlayerRole{}}

      iex> delete_player_role(player_role)
      {:error, %Ecto.Changeset{}}

  """
  def delete_player_role(%PlayerRole{} = player_role) do
    Repo.delete(player_role)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking player_role changes.

  ## Examples

      iex> change_player_role(player_role)
      %Ecto.Changeset{data: %PlayerRole{}}

  """
  def change_player_role(%PlayerRole{} = player_role, attrs \\ %{}) do
    PlayerRole.changeset(player_role, attrs)
  end
end
