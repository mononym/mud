defmodule MudWeb.LinkClosableView do
  use MudWeb, :view

  def render("link_closable.json", %{link_closable: link_closable}) do
    link_closable
  end
end
