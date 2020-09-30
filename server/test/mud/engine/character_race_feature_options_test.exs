defmodule Mud.Engine.CharacterRaceFeatureOptionTest do
  use Mud.DataCase

  alias Mud.Engine.CharacterRaceFeatureOption

  describe "character_race_feature_options" do
    alias Mud.Engine.CharacterRaceFeatureOption.CharacterRaceFeatureOption

    @valid_attrs %{conditions: %{}, option: "some option"}
    @update_attrs %{conditions: %{}, option: "some updated option"}
    @invalid_attrs %{conditions: nil, option: nil}

    def character_race_feature_options_fixture(attrs \\ %{}) do
      {:ok, character_race_feature_options} =
        attrs
        |> Enum.into(@valid_attrs)
        |> CharacterRaceFeatureOption.create_character_race_feature_options()

      character_race_feature_options
    end

    test "list_character_race_feature_options/0 returns all character_race_feature_options" do
      character_race_feature_options = character_race_feature_options_fixture()

      assert CharacterRaceFeatureOption.list_character_race_feature_options() == [
               character_race_feature_options
             ]
    end

    test "get_character_race_feature_options!/1 returns the character_race_feature_options with given id" do
      character_race_feature_options = character_race_feature_options_fixture()

      assert CharacterRaceFeatureOption.get_character_race_feature_options!(
               character_race_feature_options.id
             ) == character_race_feature_options
    end

    test "create_character_race_feature_options/1 with valid data creates a character_race_feature_options" do
      assert {:ok, %CharacterRaceFeatureOption{} = character_race_feature_options} =
               CharacterRaceFeatureOption.create_character_race_feature_options(@valid_attrs)

      assert character_race_feature_options.conditions == %{}
      assert character_race_feature_options.option == "some option"
    end

    test "create_character_race_feature_options/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               CharacterRaceFeatureOption.create_character_race_feature_options(@invalid_attrs)
    end

    test "update_character_race_feature_options/2 with valid data updates the character_race_feature_options" do
      character_race_feature_options = character_race_feature_options_fixture()

      assert {:ok, %CharacterRaceFeatureOption{} = character_race_feature_options} =
               CharacterRaceFeatureOption.update_character_race_feature_options(
                 character_race_feature_options,
                 @update_attrs
               )

      assert character_race_feature_options.conditions == %{}
      assert character_race_feature_options.option == "some updated option"
    end

    test "update_character_race_feature_options/2 with invalid data returns error changeset" do
      character_race_feature_options = character_race_feature_options_fixture()

      assert {:error, %Ecto.Changeset{}} =
               CharacterRaceFeatureOption.update_character_race_feature_options(
                 character_race_feature_options,
                 @invalid_attrs
               )

      assert character_race_feature_options ==
               CharacterRaceFeatureOption.get_character_race_feature_options!(
                 character_race_feature_options.id
               )
    end

    test "delete_character_race_feature_options/1 deletes the character_race_feature_options" do
      character_race_feature_options = character_race_feature_options_fixture()

      assert {:ok, %CharacterRaceFeatureOption{}} =
               CharacterRaceFeatureOption.delete_character_race_feature_options(
                 character_race_feature_options
               )

      assert_raise Ecto.NoResultsError, fn ->
        CharacterRaceFeatureOption.get_character_race_feature_options!(
          character_race_feature_options.id
        )
      end
    end

    test "change_character_race_feature_options/1 returns a character_race_feature_options changeset" do
      character_race_feature_options = character_race_feature_options_fixture()

      assert %Ecto.Changeset{} =
               CharacterRaceFeatureOption.change_character_race_feature_options(
                 character_race_feature_options
               )
    end
  end
end
