defmodule Mud.EngineTest do
  use Mud.DataCase

  alias Mud.Engine

  describe "maps" do
    alias Mud.Engine.Map

    @valid_attrs %{description: "some description", name: "some name"}
    @update_attrs %{description: "some updated description", name: "some updated name"}
    @invalid_attrs %{description: nil, name: nil}

    def map_fixture(attrs \\ %{}) do
      {:ok, map} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Engine.create_map()

      map
    end

    test "list_maps/0 returns all maps" do
      map = map_fixture()
      assert Engine.list_maps() == [map]
    end

    test "get_map!/1 returns the map with given id" do
      map = map_fixture()
      assert Engine.get_map!(map.id) == map
    end

    test "create_map/1 with valid data creates a map" do
      assert {:ok, %Map{} = map} = Engine.create_map(@valid_attrs)
      assert map.description == "some description"
      assert map.name == "some name"
    end

    test "create_map/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Engine.create_map(@invalid_attrs)
    end

    test "update_map/2 with valid data updates the map" do
      map = map_fixture()
      assert {:ok, %Map{} = map} = Engine.update_map(map, @update_attrs)
      assert map.description == "some updated description"
      assert map.name == "some updated name"
    end

    test "update_map/2 with invalid data returns error changeset" do
      map = map_fixture()
      assert {:error, %Ecto.Changeset{}} = Engine.update_map(map, @invalid_attrs)
      assert map == Engine.get_map!(map.id)
    end

    test "delete_map/1 deletes the map" do
      map = map_fixture()
      assert {:ok, %Map{}} = Engine.delete_map(map)
      assert_raise Ecto.NoResultsError, fn -> Engine.get_map!(map.id) end
    end

    test "change_map/1 returns a map changeset" do
      map = map_fixture()
      assert %Ecto.Changeset{} = Engine.change_map(map)
    end
  end
end
