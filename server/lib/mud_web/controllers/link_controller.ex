defmodule MudWeb.LinkController do
  use MudWeb, :controller

  alias Mud.Engine.Link

  action_fallback(MudWeb.FallbackController)

  def create(conn, %{"link" => link_params}) do
    with {:ok, %Link{} = link} <-
           Link.create(Recase.Enumerable.convert_keys(link_params, &Recase.to_snake/1)) do
      conn
      |> put_status(:created)
      |> render("show.json", link: link)
    else
      {:error, :duplicate_link} ->
        conn
        |> send_resp(409, "Link already exists between two areas with the same type.")

      {:error, :unknown} ->
        conn
        |> send_resp(400, "Unknown error while creating Link. Zelda will not be pleased.")
    end
  end

  def list_by_map(conn, params) do
    links = Link.list_map_links(params["map_id"])
    render(conn, "index.json", links: links)
  end

  def show(conn, %{"id" => id}) do
    link = Link.get!(id)
    render(conn, "show.json", link: link)
  end

  def update(conn, %{"id" => id, "link" => link_params}) do
    link = Link.get!(id)

    with {:ok, %Link{} = link} <-
           Link.update(link, Recase.Enumerable.convert_keys(link_params, &Recase.to_snake/1)) do
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
