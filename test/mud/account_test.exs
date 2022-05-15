defmodule Mud.AccountTest do
  use Mud.DataCase

  alias Mud.Account

  describe "players" do
    alias Mud.Account
    alias Mud.Account.Player

    @valid_attrs %{status: Account.Constants.PlayerStatus.pending(), tos_accepted: false}
    @update_attrs %{status: Account.Constants.PlayerStatus.created(), tos_accepted: true}
    @invalid_attrs %{status: nil, tos_accepted: nil}

    def player_fixture(attrs \\ %{}) do
      {:ok, player} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Account.create_player()

      player
    end

    test "list_players/0 returns all players" do
      player = player_fixture()
      {:ok, [returned_player]} = Account.list_players()
      assert returned_player == Map.put(player, :profile, nil)
    end

    test "get_player!/1 returns the player with given id" do
      player = player_fixture()
      assert Account.get_player!(player.id) == player
    end

    test "create_player/1 with valid data creates a player" do
      assert {:ok, %Player{} = player} = Account.create_player(@valid_attrs)
      assert player.status == Account.Constants.PlayerStatus.pending()
      assert player.tos_accepted == false
    end

    test "create_player/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Account.create_player(@invalid_attrs)
    end

    test "update_player/2 with valid data updates the player" do
      player = player_fixture()
      assert {:ok, %Player{} = player} = Account.update_player(player, @update_attrs)
      assert player.status == Account.Constants.PlayerStatus.created()
      assert player.tos_accepted == true
    end

    test "update_player/2 with invalid data returns error changeset" do
      player = player_fixture()
      assert {:error, %Ecto.Changeset{}} = Account.update_player(player, @invalid_attrs)
      assert player == Account.get_player!(player.id)
    end

    test "delete_player/1 deletes the player" do
      player = player_fixture()
      assert {:ok, %Player{}} = Account.delete_player(player)
      assert_raise Ecto.NoResultsError, fn -> Account.get_player!(player.id) end
    end
  end

  describe "profiles" do
    alias Mud.Account.Profile

    @valid_attrs %{
      email: "some@email",
      email_verified: true,
      nickname: "some name",
      player_id: nil
    }
    @update_attrs %{
      email: "some@updated.email",
      email_verified: false,
      nickname: "some updated name"
    }
    @invalid_attrs %{email: nil, email_verified: nil, nickname: nil, player_id: nil}

    def profile_fixture(attrs \\ %{}) do
      player = player_fixture()
      {:ok, profile} =
        attrs
        |> Enum.into(%{player_id: player.id})
        |> Enum.into(@valid_attrs)
        |> Account.create_profile()

      profile
    end

    test "list_profiles/0 returns all profiles" do
      profile = profile_fixture()
      assert Account.list_profiles() == {:ok, [profile]}
    end

    test "get_profile!/1 returns the profile with given id" do
      profile = profile_fixture()
      assert Account.get_profile!(profile.player_id) == profile
    end

    test "create_profile/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Account.create_profile(@invalid_attrs)
    end

    test "update_profile/2 with valid data updates the profile" do
      profile = profile_fixture()
      assert {:ok, %Profile{} = profile} = Account.update_profile(profile, @update_attrs)
      assert profile.email == "some@updated.email"
      assert profile.email_verified == false
      assert profile.nickname == "some updated name"
    end

    test "update_profile/2 with invalid data returns error changeset" do
      profile = profile_fixture()
      assert {:error, %Ecto.Changeset{}} = Account.update_profile(profile, @invalid_attrs)
      assert profile == Account.get_profile!(profile.player_id)
    end

    test "delete_profile/1 deletes the profile" do
      profile = profile_fixture()
      assert {:ok, %Profile{}} = Account.delete_profile(profile)
      assert_raise Ecto.NoResultsError, fn -> Account.get_profile!(profile.player_id) end
    end

    test "change_profile/1 returns a profile changeset" do
      profile = profile_fixture()
      assert %Ecto.Changeset{} = Account.change_profile(profile)
    end
  end

  describe "roles" do
    alias Mud.Account.Role

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def role_fixture(attrs \\ %{}) do
      {:ok, role} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Account.create_role()

      role
    end

    test "list_roles/0 returns all roles" do
      role = role_fixture()
      assert Account.list_roles() == [role]
    end

    test "get_role!/1 returns the role with given id" do
      role = role_fixture()
      assert Account.get_role!(role.id) == role
    end

    test "create_role/1 with valid data creates a role" do
      assert {:ok, %Role{} = role} = Account.create_role(@valid_attrs)
      assert role.name == "some name"
    end

    test "create_role/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Account.create_role(@invalid_attrs)
    end

    test "update_role/2 with valid data updates the role" do
      role = role_fixture()
      assert {:ok, %Role{} = role} = Account.update_role(role, @update_attrs)
      assert role.name == "some updated name"
    end

    test "update_role/2 with invalid data returns error changeset" do
      role = role_fixture()
      assert {:error, %Ecto.Changeset{}} = Account.update_role(role, @invalid_attrs)
      assert role == Account.get_role!(role.id)
    end

    test "delete_role/1 deletes the role" do
      role = role_fixture()
      assert {:ok, %Role{}} = Account.delete_role(role)
      assert_raise Ecto.NoResultsError, fn -> Account.get_role!(role.id) end
    end

    test "change_role/1 returns a role changeset" do
      role = role_fixture()
      assert %Ecto.Changeset{} = Account.change_role(role)
    end
  end

  describe "player_roles" do
    alias Mud.Account.PlayerRole

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def player_role_fixture(attrs \\ %{}) do
      {:ok, player_role} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Account.create_player_role()

      player_role
    end

    test "list_player_roles/0 returns all player_roles" do
      player_role = player_role_fixture()
      assert Account.list_player_roles() == [player_role]
    end

    test "get_player_role!/1 returns the player_role with given id" do
      player_role = player_role_fixture()
      assert Account.get_player_role!(player_role.id) == player_role
    end

    test "create_player_role/1 with valid data creates a player_role" do
      assert {:ok, %PlayerRole{} = player_role} = Account.create_player_role(@valid_attrs)
    end

    test "create_player_role/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Account.create_player_role(@invalid_attrs)
    end

    test "update_player_role/2 with valid data updates the player_role" do
      player_role = player_role_fixture()
      assert {:ok, %PlayerRole{} = player_role} = Account.update_player_role(player_role, @update_attrs)
    end

    test "update_player_role/2 with invalid data returns error changeset" do
      player_role = player_role_fixture()
      assert {:error, %Ecto.Changeset{}} = Account.update_player_role(player_role, @invalid_attrs)
      assert player_role == Account.get_player_role!(player_role.id)
    end

    test "delete_player_role/1 deletes the player_role" do
      player_role = player_role_fixture()
      assert {:ok, %PlayerRole{}} = Account.delete_player_role(player_role)
      assert_raise Ecto.NoResultsError, fn -> Account.get_player_role!(player_role.id) end
    end

    test "change_player_role/1 returns a player_role changeset" do
      player_role = player_role_fixture()
      assert %Ecto.Changeset{} = Account.change_player_role(player_role)
    end
  end
end
