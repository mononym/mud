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
    # %{
    #   id: link.id,
    #   arrivalText: link.arrival_text,
    #   departureText: link.departure_text,
    #   shortDescription: link.description.short,
    #   longDescription: link.long_description,
    #   lineWidth: link.line_width,
    #   lineDash: link.line_dash,
    #   lineColor: link.line_color,
    #   corners: link.corners,
    #   type: link.type,
    #   icon: link.icon,
    #   lineEndHorizontalOffset: link.line_end_horizontal_offset,
    #   lineEndVerticalOffset: link.line_end_vertical_offset,
    #   lineStartHorizontalOffset: link.line_start_horizontal_offset,
    #   lineStartVerticalOffset: link.line_start_vertical_offset,
    #   toId: link.to_id,
    #   fromId: link.from_id,
    #   label: link.label,
    #   labelColor: link.label_color,
    #   labelRotation: link.label_rotation,
    #   labelFontSize: link.label_font_size,
    #   labelHorizontalOffset: link.label_horizontal_offset,
    #   labelVerticalOffset: link.label_vertical_offset,
    #   localFromX: link.local_from_x,
    #   localFromY: link.local_from_y,
    #   localFromCorners: link.local_from_corners,
    #   localFromSize: link.local_from_size,
    #   localFromColor: link.local_from_color,
    #   localFromLabelRotation: link.local_from_label_rotation,
    #   localFromLabelFontSize: link.local_from_label_font_size,
    #   localFromLabelHorizontalOffset: link.local_from_label_horizontal_offset,
    #   localFromLabelVerticalOffset: link.local_from_label_vertical_offset,
    #   localFromLabelColor: link.local_from_label_vertical_offset,
    #   localFromLineWidth: link.local_from_line_width,
    #   localFromLineDash: link.local_from_line_dash,
    #   localFromLineColor: link.local_from_line_color,
    #   localToX: link.local_to_x,
    #   localToY: link.local_to_y,
    #   localToSize: link.local_to_size,
    #   localToCorners: link.local_to_corners,
    #   localToColor: link.local_to_color,
    #   localToLabelRotation: link.local_to_label_rotation,
    #   localToLabelFontSize: link.local_to_label_font_size,
    #   localToLabelHorizontalOffset: link.local_to_label_horizontal_offset,
    #   localToLabelVerticalOffset: link.local_to_label_vertical_offset,
    #   localToLabelColor: link.local_to_label_vertical_offset,
    #   localToLineWidth: link.local_to_line_width,
    #   localToLineDash: link.local_to_line_dash,
    #   localToLineColor: link.local_to_line_color,
    #   insertedAt: link.inserted_at,
    #   updatedAt: link.updated_at
    # }
    link
    |> Map.from_struct()
    |> Map.delete(:from)
    |> Map.delete(:to)
    |> Map.delete(:__meta__)
    |> Recase.Enumerable.convert_keys(&Recase.to_camel/1)
  end
end
