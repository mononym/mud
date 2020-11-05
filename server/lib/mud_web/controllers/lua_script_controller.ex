defmodule MudWeb.LuaScriptController do
  use MudWeb, :controller

  alias Mud.Engine.LuaScript

  action_fallback(MudWeb.FallbackController)

  def index(conn, _params) do
    lua_scripts = LuaScript.list()

    groups = Enum.group_by(lua_scripts, & &1.type)

    render(conn, "index.json", lua_scripts: groups)
  end

  def list_by_instance(conn, %{"instance_id" => instance_id}) do
    lua_scripts = LuaScript.list_by_instance(instance_id)
    render(conn, "index.json", lua_scripts: lua_scripts)
  end

  def create(conn, %{"lua_script" => lua_script_params}) do
    with {:ok, %LuaScript{} = lua_script} <- LuaScript.create(lua_script_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.lua_script_path(conn, :show, lua_script))
      |> render("show.json", lua_script: lua_script)
    end
  end

  def show(conn, %{"id" => id}) do
    lua_script = LuaScript.get!(id)
    render(conn, "show.json", lua_script: lua_script)
  end

  def update(conn, %{"id" => id, "lua_script" => lua_script_params}) do
    lua_script = LuaScript.get!(id)

    with {:ok, %LuaScript{} = lua_script} <- LuaScript.update(lua_script, lua_script_params) do
      render(conn, "show.json", lua_script: lua_script)
    end
  end

  def delete(conn, %{"id" => id}) do
    lua_script = LuaScript.get!(id)

    with {:ok, %LuaScript{}} <- LuaScript.delete(lua_script) do
      send_resp(conn, :no_content, "")
    end
  end
end
