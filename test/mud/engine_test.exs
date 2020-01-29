defmodule Mud.EngineTest do
  use Mud.DataCase

  alias Mud.Engine

  describe "areas" do
    alias Mud.Engine.Area

    @valid_attrs %{description: "some description", name: "some name"}
    @update_attrs %{description: "some updated description", name: "some updated name"}
    @invalid_attrs %{description: nil, name: nil}

    def area_fixture(attrs \\ %{}) do
      {:ok, area} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Engine.create_area()

      area
    end

    test "list_areas/0 returns all areas" do
      area = area_fixture()
      assert Engine.list_areas() == [area]
    end

    test "get_area!/1 returns the area with given id" do
      area = area_fixture()
      assert Engine.get_area!(area.id) == area
    end

    test "create_area/1 with valid data creates a area" do
      assert {:ok, %Area{} = area} = Engine.create_area(@valid_attrs)
      assert area.description == "some description"
      assert area.name == "some name"
    end

    test "create_area/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Engine.create_area(@invalid_attrs)
    end

    test "update_area/2 with valid data updates the area" do
      area = area_fixture()
      assert {:ok, %Area{} = area} = Engine.update_area(area, @update_attrs)
      assert area.description == "some updated description"
      assert area.name == "some updated name"
    end

    test "update_area/2 with invalid data returns error changeset" do
      area = area_fixture()
      assert {:error, %Ecto.Changeset{}} = Engine.update_area(area, @invalid_attrs)
      assert area == Engine.get_area!(area.id)
    end

    test "delete_area/1 deletes the area" do
      area = area_fixture()
      assert {:ok, %Area{}} = Engine.delete_area(area)
      assert_raise Ecto.NoResultsError, fn -> Engine.get_area!(area.id) end
    end

    test "change_area/1 returns a area changeset" do
      area = area_fixture()
      assert %Ecto.Changeset{} = Engine.change_area(area)
    end
  end

  describe "links" do
    alias Mud.Engine.Link

    @valid_attrs %{text: "some text", type: "some type"}
    @update_attrs %{text: "some updated text", type: "some updated type"}
    @invalid_attrs %{text: nil, type: nil}

    def link_fixture(attrs \\ %{}) do
      {:ok, link} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Engine.create_link()

      link
    end

    test "list_links/0 returns all links" do
      link = link_fixture()
      assert Engine.list_links() == [link]
    end

    test "get_link!/1 returns the link with given id" do
      link = link_fixture()
      assert Engine.get_link!(link.id) == link
    end

    test "create_link/1 with valid data creates a link" do
      assert {:ok, %Link{} = link} = Engine.create_link(@valid_attrs)
      assert link.text == "some text"
      assert link.type == "some type"
    end

    test "create_link/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Engine.create_link(@invalid_attrs)
    end

    test "update_link/2 with valid data updates the link" do
      link = link_fixture()
      assert {:ok, %Link{} = link} = Engine.update_link(link, @update_attrs)
      assert link.text == "some updated text"
      assert link.type == "some updated type"
    end

    test "update_link/2 with invalid data returns error changeset" do
      link = link_fixture()
      assert {:error, %Ecto.Changeset{}} = Engine.update_link(link, @invalid_attrs)
      assert link == Engine.get_link!(link.id)
    end

    test "delete_link/1 deletes the link" do
      link = link_fixture()
      assert {:ok, %Link{}} = Engine.delete_link(link)
      assert_raise Ecto.NoResultsError, fn -> Engine.get_link!(link.id) end
    end

    test "change_link/1 returns a link changeset" do
      link = link_fixture()
      assert %Ecto.Changeset{} = Engine.change_link(link)
    end
  end

  describe "characters" do
    alias Mud.Engine.Character

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def character_fixture(attrs \\ %{}) do
      {:ok, character} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Engine.create_character()

      character
    end

    test "list_characters/0 returns all characters" do
      character = character_fixture()
      assert Engine.list_characters() == [character]
    end

    test "get_character!/1 returns the character with given id" do
      character = character_fixture()
      assert Engine.get_character!(character.id) == character
    end

    test "create_character/1 with valid data creates a character" do
      assert {:ok, %Character{} = character} = Engine.create_character(@valid_attrs)
      assert character.name == "some name"
    end

    test "create_character/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Engine.create_character(@invalid_attrs)
    end

    test "update_character/2 with valid data updates the character" do
      character = character_fixture()
      assert {:ok, %Character{} = character} = Engine.update_character(character, @update_attrs)
      assert character.name == "some updated name"
    end

    test "update_character/2 with invalid data returns error changeset" do
      character = character_fixture()
      assert {:error, %Ecto.Changeset{}} = Engine.update_character(character, @invalid_attrs)
      assert character == Engine.get_character!(character.id)
    end

    test "delete_character/1 deletes the character" do
      character = character_fixture()
      assert {:ok, %Character{}} = Engine.delete_character(character)
      assert_raise Ecto.NoResultsError, fn -> Engine.get_character!(character.id) end
    end

    test "change_character/1 returns a character changeset" do
      character = character_fixture()
      assert %Ecto.Changeset{} = Engine.change_character(character)
    end
  end
end
