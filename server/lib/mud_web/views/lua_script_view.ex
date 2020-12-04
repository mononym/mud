defmodule MudWeb.LuaScriptView do
  use MudWeb, :view
  alias MudWeb.LuaScriptView

  def render("index.json", %{lua_scripts: lua_scripts}) do
    render_many(lua_scripts, LuaScriptView, "lua_script.json")
  end

  def render("show.json", %{lua_script: lua_script}) do
    render_one(lua_script, LuaScriptView, "lua_script.json")
  end

  def render("lua_script.json", %{lua_script: lua_script}) do
    %{id: lua_script.id, name: lua_script.name, type: lua_script.type, code: lua_script.code}
  end
end
