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
      localFromX: link.local_from_x,
      localFromY: link.local_from_y,
      localFromCorners: link.local_from_corners,
      localFromSize: link.local_from_size,
      localFromColor: link.local_from_color,
      localToX: link.local_to_x,
      localToY: link.local_to_y,
      localToSize: link.local_to_size,
      localToCorners: link.local_to_corners,
      localToColor: link.local_to_color,
      insertedAt: link.inserted_at,
      updatedAt: link.updated_at
    }
  end
end
