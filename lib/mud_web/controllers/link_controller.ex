defmodule MudWeb.LinkController do
  use MudWeb, :controller

  alias Mud.Engine
  alias Mud.Engine.Link

  def index(conn, _params) do
    links = Engine.list_links()
    render(conn, "index.html", links: links)
  end

  def new(conn, _params) do
    changeset = Engine.change_link(%Link{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"link" => link_params}) do
    case Engine.create_link(link_params) do
      {:ok, link} ->
        conn
        |> put_flash(:info, "Link created successfully.")
        |> redirect(to: Routes.link_path(conn, :show, link))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    link = Engine.get_link!(id)
    render(conn, "show.html", link: link)
  end

  def edit(conn, %{"id" => id}) do
    link = Engine.get_link!(id)
    changeset = Engine.change_link(link)
    render(conn, "edit.html", link: link, changeset: changeset)
  end

  def update(conn, %{"id" => id, "link" => link_params}) do
    link = Engine.get_link!(id)

    case Engine.update_link(link, link_params) do
      {:ok, link} ->
        conn
        |> put_flash(:info, "Link updated successfully.")
        |> redirect(to: Routes.link_path(conn, :show, link))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", link: link, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    link = Engine.get_link!(id)
    {:ok, _link} = Engine.delete_link(link)

    conn
    |> put_flash(:info, "Link deleted successfully.")
    |> redirect(to: Routes.link_path(conn, :index))
  end
end
