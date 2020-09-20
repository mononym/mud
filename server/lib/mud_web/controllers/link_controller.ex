defmodule MudWeb.LinkController do
  use MudWeb, :controller

  alias Mud.Engine.Link

  action_fallback(MudWeb.FallbackController)

  def create(conn, %{"link" => link_params}) do
    with {:ok, %Link{} = link} <- Link.create(link_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.link_path(conn, :show, link))
      |> render("show.json", link: link)
    end
  end

  def show(conn, %{"id" => id}) do
    link = Link.get!(id)
    render(conn, "show.json", link: link)
  end

  def update(conn, %{"id" => id, "link" => link_params}) do
    IO.inspect(id, label: "getting")
    link = Link.get!(id)
    IO.inspect(link, label: "gotlink")

    with {:ok, %Link{} = link} <- Link.update(link, link_params) do
      IO.inspect(link, label: "updated")
      render(conn, "show.json", link: link)
    end
  end

  def delete(conn, %{"id" => id}) do
    link = Link.get!(id)

    with {:ok, %Link{}} <- Link.delete(link) do
      send_resp(conn, :no_content, "")
    end
  end
end
