defmodule MudWeb.LinkController do
  use MudWeb, :controller

  alias Mud.Engine
  alias Mud.Engine.Link

  action_fallback MudWeb.FallbackController

  def index(conn, _params) do
    links = Engine.list_links()
    render(conn, "index.json", links: links)
  end

  def create(conn, %{"link" => link_params}) do
    with {:ok, %Link{} = link} <- Engine.create_link(link_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.link_path(conn, :show, link))
      |> render("show.json", link: link)
    end
  end

  def show(conn, %{"id" => id}) do
    link = Engine.get_link!(id)
    render(conn, "show.json", link: link)
  end

  def update(conn, %{"id" => id, "link" => link_params}) do
    link = Engine.get_link!(id)

    with {:ok, %Link{} = link} <- Engine.update_link(link, link_params) do
      render(conn, "show.json", link: link)
    end
  end

  def delete(conn, %{"id" => id}) do
    link = Engine.get_link!(id)

    with {:ok, %Link{}} <- Engine.delete_link(link) do
      send_resp(conn, :no_content, "")
    end
  end
end
