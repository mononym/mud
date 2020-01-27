defmodule MudWeb.PageController do
  use MudWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
