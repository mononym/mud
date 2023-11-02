defmodule MudWeb.MapLabelView do
  use MudWeb, :view
  alias MudWeb.MapLabelView
  require Logger

  def render("index.json", %{map_labels: labels}) do
    render_many(labels, MapLabelView, "map_label.json")
  end

  def render("show.json", %{map_label: label}) do
    render_one(label, MapLabelView, "map_label.json")
  end

  def render("map_label.json", %{map_label: label}) do
    %{
      id: label.id,
      map_id: label.map_id,
      text: label.text,
      x: label.x,
      y: label.y,
      vertical_offset: label.vertical_offset,
      horizontal_offset: label.horizontal_offset,
      rotation: label.rotation,
      color: label.color,
      size: label.size,
      weight: label.weight,
      inserted_at: label.inserted_at,
      updated_at: label.updated_at
    }
  end
end
