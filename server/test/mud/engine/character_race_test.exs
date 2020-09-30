defmodule Mud.Engine.CharacterRaceTest do
  use Mud.DataCase

  alias Mud.Engine.CharacterRace

  describe "character_races" do
    alias Mud.Engine.CharacterRace.CharacterRace

    @valid_attrs %{adjective: "some adjective", description: "some description", plural: "some plural", portrait: "some portrait", singular: "some singular"}
    @update_attrs %{adjective: "some updated adjective", description: "some updated description", plural: "some updated plural", portrait: "some updated portrait", singular: "some updated singular"}
    @invalid_attrs %{adjective: nil, description: nil, plural: nil, portrait: nil, singular: nil}

    def character_race_fixture(attrs \\ %{}) do
      {:ok, character_race} =
        attrs
        |> Enum.into(@valid_attrs)
        |> CharacterRace.create_character_race()

      character_race
    end

    test "list_character_races/0 returns all character_races" do
      character_race = character_race_fixture()
      assert CharacterRace.list_character_races() == [character_race]
    end

    test "get_character_race!/1 returns the character_race with given id" do
      character_race = character_race_fixture()
      assert CharacterRace.get_character_race!(character_race.id) == character_race
    end

    test "create_character_race/1 with valid data creates a character_race" do
      assert {:ok, %CharacterRace{} = character_race} = CharacterRace.create_character_race(@valid_attrs)
      assert character_race.adjective == "some adjective"
      assert character_race.description == "some description"
      assert character_race.plural == "some plural"
      assert character_race.portrait == "some portrait"
      assert character_race.singular == "some singular"
    end

    test "create_character_race/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = CharacterRace.create_character_race(@invalid_attrs)
    end

    test "update_character_race/2 with valid data updates the character_race" do
      character_race = character_race_fixture()
      assert {:ok, %CharacterRace{} = character_race} = CharacterRace.update_character_race(character_race, @update_attrs)
      assert character_race.adjective == "some updated adjective"
      assert character_race.description == "some updated description"
      assert character_race.plural == "some updated plural"
      assert character_race.portrait == "some updated portrait"
      assert character_race.singular == "some updated singular"
    end

    test "update_character_race/2 with invalid data returns error changeset" do
      character_race = character_race_fixture()
      assert {:error, %Ecto.Changeset{}} = CharacterRace.update_character_race(character_race, @invalid_attrs)
      assert character_race == CharacterRace.get_character_race!(character_race.id)
    end

    test "delete_character_race/1 deletes the character_race" do
      character_race = character_race_fixture()
      assert {:ok, %CharacterRace{}} = CharacterRace.delete_character_race(character_race)
      assert_raise Ecto.NoResultsError, fn -> CharacterRace.get_character_race!(character_race.id) end
    end

    test "change_character_race/1 returns a character_race changeset" do
      character_race = character_race_fixture()
      assert %Ecto.Changeset{} = CharacterRace.change_character_race(character_race)
    end
  end
end
