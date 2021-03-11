defmodule MudWeb.ItemController do
  use MudWeb, :controller

  alias Mud.Engine.Item

  action_fallback(MudWeb.FallbackController)

  def load_items_for_area(conn, %{"area_id" => area_id}) do
    items = Item.list_in_area(area_id)
    render(conn, "index.json", items: items)
  end

  def create(conn, %{"item" => item_params}) do
    with {:ok, %Item{} = item} <-
           Item.create(item_params) do
      conn
      |> put_status(:created)
      |> render("show.json", item: item)
    end
  end

  def show(conn, %{"id" => id}) do
    item = Item.get!(id)
    render(conn, "show.json", item: item)
  end

  def update(conn, %{"item_id" => id, "item" => item_params}) do
    item = Item.get!(id)

    with {:ok, %Item{} = item} <-
           Item.update(item, item_params) do
      render(conn, "show.json", item: item)
    end
  end

  def delete(conn, %{"item_id" => id}) do
    item = Item.get!(id)

    with {:ok, %Item{}} <- Item.delete(item) do
      send_resp(conn, :no_content, "")
    end
  end
end