defmodule MudWeb.AreaFlagsView do
  use MudWeb, :view

  def render("area_flags.json", %{area_flags: area_flags}) do
    area_flags
  end
end
