defmodule MudWeb.TemplateController do
  use MudWeb, :controller

  alias Mud.Engine.Template

  action_fallback(MudWeb.FallbackController)

  def index(conn, _params) do
    templates = Template.list_all()
    render(conn, "index.json", templates: templates)
  end

  def create(conn, %{"template" => template_params}) do
    with {:ok, %Template{} = template} <-
           Template.create(template_params) do
      conn
      |> put_status(:created)
      |> render("show.json", template: template)
    end
  end

  def show(conn, %{"id" => id}) do
    template = Template.get!(id)
    render(conn, "show.json", template: template)
  end

  def update(conn, %{"template_id" => id, "template" => template_params}) do
    template = Template.get!(id)

    with {:ok, %Template{} = template} <-
           Template.update(template, template_params) do
      render(conn, "show.json", shop: template)
    end
  end

  def delete(conn, %{"template_id" => id}) do
    template = Template.get!(id)

    with {:ok, %Template{}} <- Template.delete(template) do
      send_resp(conn, :no_content, "")
    end
  end
end
