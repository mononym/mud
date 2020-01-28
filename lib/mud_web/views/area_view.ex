defmodule MudWeb.AreaView do
  use MudWeb, :view
  alias MudWeb.AreaView

  def render("index.json", %{areas: areas}) do
    %{data: render_many(areas, AreaView, "area.json")}
  end

  def render("show.json", %{area: area}) do
    %{data: render_one(area, AreaView, "area.json")}
  end

  def render("area.json", %{area: area}) do
    %{id: area.id,
      name: area.name,
      description: area.description}
  end
end
