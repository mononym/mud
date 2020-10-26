defmodule Mud.Mud.EngineTest do
  use Mud.DataCase

  alias Mud.Mud.Engine

  describe "character_templates" do
    alias Mud.Mud.Engine.CharacterTemplate

    @valid_attrs %{description: "some description", name: "some name", template: "some template"}
    @update_attrs %{description: "some updated description", name: "some updated name", template: "some updated template"}
    @invalid_attrs %{description: nil, name: nil, template: nil}

    def character_template_fixture(attrs \\ %{}) do
      {:ok, character_template} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Engine.create_character_template()

      character_template
    end

    test "list_character_templates/0 returns all character_templates" do
      character_template = character_template_fixture()
      assert Engine.list_character_templates() == [character_template]
    end

    test "get_character_template!/1 returns the character_template with given id" do
      character_template = character_template_fixture()
      assert Engine.get_character_template!(character_template.id) == character_template
    end

    test "create_character_template/1 with valid data creates a character_template" do
      assert {:ok, %CharacterTemplate{} = character_template} = Engine.create_character_template(@valid_attrs)
      assert character_template.description == "some description"
      assert character_template.name == "some name"
      assert character_template.template == "some template"
    end

    test "create_character_template/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Engine.create_character_template(@invalid_attrs)
    end

    test "update_character_template/2 with valid data updates the character_template" do
      character_template = character_template_fixture()
      assert {:ok, %CharacterTemplate{} = character_template} = Engine.update_character_template(character_template, @update_attrs)
      assert character_template.description == "some updated description"
      assert character_template.name == "some updated name"
      assert character_template.template == "some updated template"
    end

    test "update_character_template/2 with invalid data returns error changeset" do
      character_template = character_template_fixture()
      assert {:error, %Ecto.Changeset{}} = Engine.update_character_template(character_template, @invalid_attrs)
      assert character_template == Engine.get_character_template!(character_template.id)
    end

    test "delete_character_template/1 deletes the character_template" do
      character_template = character_template_fixture()
      assert {:ok, %CharacterTemplate{}} = Engine.delete_character_template(character_template)
      assert_raise Ecto.NoResultsError, fn -> Engine.get_character_template!(character_template.id) end
    end

    test "change_character_template/1 returns a character_template changeset" do
      character_template = character_template_fixture()
      assert %Ecto.Changeset{} = Engine.change_character_template(character_template)
    end
  end
end
