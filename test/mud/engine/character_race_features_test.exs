defmodule Mud.Engine.CharacterRaceFeatureTest do
  use Mud.DataCase

  alias Mud.Engine.CharacterRaceFeature

  describe "character_race_feature" do
    alias Mud.Engine.CharacterRaceFeature.CharacterRaceFeature

    @valid_attrs %{name: "some name", type: "some type"}
    @update_attrs %{name: "some updated name", type: "some updated type"}
    @invalid_attrs %{name: nil, type: nil}

    def character_race_feature_fixture(attrs \\ %{}) do
      {:ok, character_race_feature} =
        attrs
        |> Enum.into(@valid_attrs)
        |> CharacterRaceFeature.create_character_race_feature()

      character_race_feature
    end

    test "list_character_race_feature/0 returns all character_race_feature" do
      character_race_feature = character_race_feature_fixture()
      assert CharacterRaceFeature.list_character_race_feature() == [character_race_feature]
    end

    test "get_character_race_feature!/1 returns the character_race_feature with given id" do
      character_race_feature = character_race_feature_fixture()

      assert CharacterRaceFeature.get_character_race_feature!(character_race_feature.id) ==
               character_race_feature
    end

    test "create_character_race_feature/1 with valid data creates a character_race_feature" do
      assert {:ok, %CharacterRaceFeature{} = character_race_feature} =
               CharacterRaceFeature.create_character_race_feature(@valid_attrs)

      assert character_race_feature.name == "some name"
      assert character_race_feature.type == "some type"
    end

    test "create_character_race_feature/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               CharacterRaceFeature.create_character_race_feature(@invalid_attrs)
    end

    test "update_character_race_feature/2 with valid data updates the character_race_feature" do
      character_race_feature = character_race_feature_fixture()

      assert {:ok, %CharacterRaceFeature{} = character_race_feature} =
               CharacterRaceFeature.update_character_race_feature(
                 character_race_feature,
                 @update_attrs
               )

      assert character_race_feature.name == "some updated name"
      assert character_race_feature.type == "some updated type"
    end

    test "update_character_race_feature/2 with invalid data returns error changeset" do
      character_race_feature = character_race_feature_fixture()

      assert {:error, %Ecto.Changeset{}} =
               CharacterRaceFeature.update_character_race_feature(
                 character_race_feature,
                 @invalid_attrs
               )

      assert character_race_feature ==
               CharacterRaceFeature.get_character_race_feature!(character_race_feature.id)
    end

    test "delete_character_race_feature/1 deletes the character_race_feature" do
      character_race_feature = character_race_feature_fixture()

      assert {:ok, %CharacterRaceFeature{}} =
               CharacterRaceFeature.delete_character_race_feature(character_race_feature)

      assert_raise Ecto.NoResultsError, fn ->
        CharacterRaceFeature.get_character_race_feature!(character_race_feature.id)
      end
    end

    test "change_character_race_feature/1 returns a character_race_feature changeset" do
      character_race_feature = character_race_feature_fixture()

      assert %Ecto.Changeset{} =
               CharacterRaceFeature.change_character_race_feature(character_race_feature)
    end
  end
end
