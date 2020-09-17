defmodule MudWeb.LinkView do
  use MudWeb, :view
  alias MudWeb.LinkView

  def render("index.json", %{links: links}) do
    render_many(links, LinkView, "link.json")
  end

  def render("show.json", %{link: link}) do
    render_one(link, LinkView, "link.json")
  end

  def render("link.json", %{link: link}) do
    %{
      id: link.id,
      arrivalText: link.arrival_text,
      departureText: link.departure_text,
      shortDescription: link.short_description,
      longDescription: link.long_description,
      type: link.type,
      icon: link.icon,
      toId: link.to_id,
      fromId: link.from_id,
      insertedAt: link.inserted_at,
      updatedAt: link.updated_at
    }
  end
end
