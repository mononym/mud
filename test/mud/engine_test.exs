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

  describe "objects" do
    alias Mud.Engine.Object

    @valid_attrs %{key: "some key"}
    @update_attrs %{key: "some updated key"}
    @invalid_attrs %{key: nil}

    def object_fixture(attrs \\ %{}) do
      {:ok, object} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Engine.create_object()

      object
    end

    test "list_objects/0 returns all objects" do
      object = object_fixture()
      assert Engine.list_objects() == [object]
    end

    test "get_object!/1 returns the object with given id" do
      object = object_fixture()
      assert Engine.get_object!(object.id) == object
    end

    test "create_object/1 with valid data creates a object" do
      assert {:ok, %Object{} = object} = Engine.create_object(@valid_attrs)
      assert object.key == "some key"
    end

    test "create_object/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Engine.create_object(@invalid_attrs)
    end

    test "update_object/2 with valid data updates the object" do
      object = object_fixture()
      assert {:ok, %Object{} = object} = Engine.update_object(object, @update_attrs)
      assert object.key == "some updated key"
    end

    test "update_object/2 with invalid data returns error changeset" do
      object = object_fixture()
      assert {:error, %Ecto.Changeset{}} = Engine.update_object(object, @invalid_attrs)
      assert object == Engine.get_object!(object.id)
    end

    test "delete_object/1 deletes the object" do
      object = object_fixture()
      assert {:ok, %Object{}} = Engine.delete_object(object)
      assert_raise Ecto.NoResultsError, fn -> Engine.get_object!(object.id) end
    end

    test "change_object/1 returns a object changeset" do
      object = object_fixture()
      assert %Ecto.Changeset{} = Engine.change_object(object)
    end
  end

  describe "location_components" do
    alias Mud.Engine.Component.Location

    @valid_attrs %{
      contained: true,
      hand: "some hand",
      held: true,
      object_id: "some object_id",
      on_ground: true,
      reference: "some reference",
      worn: true
    }
    @update_attrs %{
      contained: false,
      hand: "some updated hand",
      held: false,
      object_id: "some updated object_id",
      on_ground: false,
      reference: "some updated reference",
      worn: false
    }
    @invalid_attrs %{
      contained: nil,
      hand: nil,
      held: nil,
      object_id: nil,
      on_ground: nil,
      reference: nil,
      worn: nil
    }

    def location_fixture(attrs \\ %{}) do
      {:ok, location} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Engine.create_location()

      location
    end

    test "list_location_components/0 returns all location_components" do
      location = location_fixture()
      assert Engine.list_location_components() == [location]
    end

    test "get_location!/1 returns the location with given id" do
      location = location_fixture()
      assert Engine.get_location!(location.id) == location
    end

    test "create_location/1 with valid data creates a location" do
      assert {:ok, %Location{} = location} = Engine.create_location(@valid_attrs)
      assert location.contained == true
      assert location.hand == "some hand"
      assert location.held == true
      assert location.object_id == "some object_id"
      assert location.on_ground == true
      assert location.reference == "some reference"
      assert location.worn == true
    end

    test "create_location/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Engine.create_location(@invalid_attrs)
    end

    test "update_location/2 with valid data updates the location" do
      location = location_fixture()
      assert {:ok, %Location{} = location} = Engine.update_location(location, @update_attrs)
      assert location.contained == false
      assert location.hand == "some updated hand"
      assert location.held == false
      assert location.object_id == "some updated object_id"
      assert location.on_ground == false
      assert location.reference == "some updated reference"
      assert location.worn == false
    end

    test "update_location/2 with invalid data returns error changeset" do
      location = location_fixture()
      assert {:error, %Ecto.Changeset{}} = Engine.update_location(location, @invalid_attrs)
      assert location == Engine.get_location!(location.id)
    end

    test "delete_location/1 deletes the location" do
      location = location_fixture()
      assert {:ok, %Location{}} = Engine.delete_location(location)
      assert_raise Ecto.NoResultsError, fn -> Engine.get_location!(location.id) end
    end

    test "change_location/1 returns a location changeset" do
      location = location_fixture()
      assert %Ecto.Changeset{} = Engine.change_location(location)
    end
  end

  describe "description_components" do
    alias Mud.Engine.Component.Description

    @valid_attrs %{
      examine_description: "some examine_description",
      glance_description: "some glance_description",
      look_description: "some look_description",
      object_id: "some object_id"
    }
    @update_attrs %{
      examine_description: "some updated examine_description",
      glance_description: "some updated glance_description",
      look_description: "some updated look_description",
      object_id: "some updated object_id"
    }
    @invalid_attrs %{
      examine_description: nil,
      glance_description: nil,
      look_description: nil,
      object_id: nil
    }

    def description_fixture(attrs \\ %{}) do
      {:ok, description} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Engine.create_description()

      description
    end

    test "list_description_components/0 returns all description_components" do
      description = description_fixture()
      assert Engine.list_description_components() == [description]
    end

    test "get_description!/1 returns the description with given id" do
      description = description_fixture()
      assert Engine.get_description!(description.id) == description
    end

    test "create_description/1 with valid data creates a description" do
      assert {:ok, %Description{} = description} = Engine.create_description(@valid_attrs)
      assert description.examine_description == "some examine_description"
      assert description.glance_description == "some glance_description"
      assert description.look_description == "some look_description"
      assert description.object_id == "some object_id"
    end

    test "create_description/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Engine.create_description(@invalid_attrs)
    end

    test "update_description/2 with valid data updates the description" do
      description = description_fixture()

      assert {:ok, %Description{} = description} =
               Engine.update_description(description, @update_attrs)

      assert description.examine_description == "some updated examine_description"
      assert description.glance_description == "some updated glance_description"
      assert description.look_description == "some updated look_description"
      assert description.object_id == "some updated object_id"
    end

    test "update_description/2 with invalid data returns error changeset" do
      description = description_fixture()
      assert {:error, %Ecto.Changeset{}} = Engine.update_description(description, @invalid_attrs)
      assert description == Engine.get_description!(description.id)
    end

    test "delete_description/1 deletes the description" do
      description = description_fixture()
      assert {:ok, %Description{}} = Engine.delete_description(description)
      assert_raise Ecto.NoResultsError, fn -> Engine.get_description!(description.id) end
    end

    test "change_description/1 returns a description changeset" do
      description = description_fixture()
      assert %Ecto.Changeset{} = Engine.change_description(description)
    end
  end
end
