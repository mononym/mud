defmodule MudWeb.LinkFlagsView do
  use MudWeb, :view

  def render("link_flags.json", %{link_flags: link_flags}) do
    link_flags
  end
end
