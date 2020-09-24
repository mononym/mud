defmodule MudWeb.LuaScriptView do
  use MudWeb, :view
  alias MudWeb.LuaScriptView

  def render("index.json", %{lua_scripts: lua_scripts}) do
    %{
      "Commands" => render_many(lua_scripts["Command"], LuaScriptView, "lua_script.json"),
      "Systems" => render_many(lua_scripts["System"], LuaScriptView, "lua_script.json"),
      "Scripts" => render_many(lua_scripts["Script"], LuaScriptView, "lua_script.json"),
      "Modules" => render_many(lua_scripts["Module"], LuaScriptView, "lua_script.json")
    }
  end

  def render("show.json", %{lua_script: lua_script}) do
    %{data: render_one(lua_script, LuaScriptView, "lua_script.json")}
  end

  def render("lua_script.json", %{lua_script: lua_script}) do
    %{id: lua_script.id, name: lua_script.name, type: lua_script.type, code: lua_script.code}
  end
end
