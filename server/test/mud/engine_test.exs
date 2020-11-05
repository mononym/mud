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

  describe "lua_scripts" do
    alias Mud.Engine.LuaScript

    @valid_attrs %{code: "some code", name: "some name", type: "some type"}
    @update_attrs %{code: "some updated code", name: "some updated name", type: "some updated type"}
    @invalid_attrs %{code: nil, name: nil, type: nil}

    def lua_script_fixture(attrs \\ %{}) do
      {:ok, lua_script} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Engine.create_lua_script()

      lua_script
    end

    test "list_lua_scripts/0 returns all lua_scripts" do
      lua_script = lua_script_fixture()
      assert Engine.list_lua_scripts() == [lua_script]
    end

    test "get_lua_script!/1 returns the lua_script with given id" do
      lua_script = lua_script_fixture()
      assert Engine.get_lua_script!(lua_script.id) == lua_script
    end

    test "create_lua_script/1 with valid data creates a lua_script" do
      assert {:ok, %LuaScript{} = lua_script} = Engine.create_lua_script(@valid_attrs)
      assert lua_script.code == "some code"
      assert lua_script.name == "some name"
      assert lua_script.type == "some type"
    end

    test "create_lua_script/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Engine.create_lua_script(@invalid_attrs)
    end

    test "update_lua_script/2 with valid data updates the lua_script" do
      lua_script = lua_script_fixture()
      assert {:ok, %LuaScript{} = lua_script} = Engine.update_lua_script(lua_script, @update_attrs)
      assert lua_script.code == "some updated code"
      assert lua_script.name == "some updated name"
      assert lua_script.type == "some updated type"
    end

    test "update_lua_script/2 with invalid data returns error changeset" do
      lua_script = lua_script_fixture()
      assert {:error, %Ecto.Changeset{}} = Engine.update_lua_script(lua_script, @invalid_attrs)
      assert lua_script == Engine.get_lua_script!(lua_script.id)
    end

    test "delete_lua_script/1 deletes the lua_script" do
      lua_script = lua_script_fixture()
      assert {:ok, %LuaScript{}} = Engine.delete_lua_script(lua_script)
      assert_raise Ecto.NoResultsError, fn -> Engine.get_lua_script!(lua_script.id) end
    end

    test "change_lua_script/1 returns a lua_script changeset" do
      lua_script = lua_script_fixture()
      assert %Ecto.Changeset{} = Engine.change_lua_script(lua_script)
    end
  end

  describe "commands" do
    alias Mud.Engine.Command

    @valid_attrs %{description: "some description", name: "some name", parts: []}
    @update_attrs %{description: "some updated description", name: "some updated name", parts: []}
    @invalid_attrs %{description: nil, name: nil, parts: nil}

    def command_fixture(attrs \\ %{}) do
      {:ok, command} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Engine.create_command()

      command
    end

    test "list_commands/0 returns all commands" do
      command = command_fixture()
      assert Engine.list_commands() == [command]
    end

    test "get_command!/1 returns the command with given id" do
      command = command_fixture()
      assert Engine.get_command!(command.id) == command
    end

    test "create_command/1 with valid data creates a command" do
      assert {:ok, %Command{} = command} = Engine.create_command(@valid_attrs)
      assert command.description == "some description"
      assert command.name == "some name"
      assert command.parts == []
    end

    test "create_command/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Engine.create_command(@invalid_attrs)
    end

    test "update_command/2 with valid data updates the command" do
      command = command_fixture()
      assert {:ok, %Command{} = command} = Engine.update_command(command, @update_attrs)
      assert command.description == "some updated description"
      assert command.name == "some updated name"
      assert command.parts == []
    end

    test "update_command/2 with invalid data returns error changeset" do
      command = command_fixture()
      assert {:error, %Ecto.Changeset{}} = Engine.update_command(command, @invalid_attrs)
      assert command == Engine.get_command!(command.id)
    end

    test "delete_command/1 deletes the command" do
      command = command_fixture()
      assert {:ok, %Command{}} = Engine.delete_command(command)
      assert_raise Ecto.NoResultsError, fn -> Engine.get_command!(command.id) end
    end

    test "change_command/1 returns a command changeset" do
      command = command_fixture()
      assert %Ecto.Changeset{} = Engine.change_command(command)
    end
  end
end
