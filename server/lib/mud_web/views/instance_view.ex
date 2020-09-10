defmodule MudWeb.InstanceView do
  use MudWeb, :view
  alias MudWeb.InstanceView

  def render("index.json", %{instances: instances}) do
    render_many(instances, InstanceView, "instance.json")
  end

  def render("instance.json", %{instance: instance}) do
    %{
      id: instance.id,
      inserted_at: instance.inserted_at,
      updated_at: instance.updated_at,
      name: instance.name,
      slug: instance.slug,
      description: instance.description
    }
  end
end
