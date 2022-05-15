defmodule MudWeb.MapLabelController do
  use MudWeb, :controller

  alias Mud.Engine.Map.Label

  action_fallback(MudWeb.FallbackController)

  def fetch_for_map(conn, %{"map_id" => map_id}) do
    labels = Label.get_map_labels(map_id)
    render(conn, "index.json", map_labels: labels)
  end

  def create(conn, label_params) do
    with {:ok, %Label{} = label} <- Label.create(label_params) do
      conn
      |> put_status(:created)
      |> render("show.json", map_label: label)
    end
  end

  def show(conn, %{"id" => id}) do
    label = Label.get!(id)
    render(conn, "show.json", map_label: label)
  end

  def update(conn, label_params = %{"id" => id}) do
    label = Label.get!(id)

    with {:ok, %Label{} = label} <-
           Label.update(label, label_params) do
      render(conn, "show.json", map_label: label)
    end
  end

  def delete(conn, %{"id" => id}) do
    label = Label.get!(id)

    with {:ok, %Label{}} <- Label.delete(label) do
      send_resp(conn, :no_content, "")
    end
  end
end
