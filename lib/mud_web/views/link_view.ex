defmodule MudWeb.LinkView do
  use MudWeb, :view
  alias MudWeb.LinkView

  alias MudWeb.{
    LinkView,
    LinkClosableView,
    LinkFlagsView
  }

  def render("index.json", %{links: links}) do
    render_many(links, LinkView, "link.json")
  end

  def render("show.json", %{link: link}) do
    render_one(link, LinkView, "link.json")
  end

  def render("link.json", %{link: link}) do
    %{
      id: link.id,
      from_id: link.from_id,
      to_id: link.to_id,
      closable:
        render_one(
          link.closable,
          LinkClosableView,
          "link_closable.json"
        ),
      flags:
        render_one(
          link.flags,
          LinkFlagsView,
          "link_flags.json"
        ),
      arrival_text: link.arrival_text,
      departure_text: link.departure_text,
      label: link.label,
      label_color: link.label_color,
      label_rotation: link.label_rotation,
      label_font_size: link.label_font_size,
      label_horizontal_offset: link.label_horizontal_offset,
      label_vertical_offset: link.label_vertical_offset,
      long_description: link.long_description,
      short_description: link.short_description,
      type: link.type,
      line_width: link.line_width,
      line_color: link.line_color,
      line_dash: link.line_dash,
      line_dashed: link.line_dashed,
      line_start_horizontal_offset: link.line_start_horizontal_offset,
      line_start_vertical_offset: link.line_start_vertical_offset,
      line_end_horizontal_offset: link.line_end_horizontal_offset,
      line_end_vertical_offset: link.line_end_vertical_offset,
      local_from_color: link.local_from_color,
      local_from_corners: link.local_from_corners,
      local_from_label: link.local_from_label,
      local_from_label_rotation: link.local_from_label_rotation,
      local_from_label_font_size: link.local_from_label_font_size,
      local_from_label_horizontal_offset: link.local_from_label_horizontal_offset,
      local_from_label_vertical_offset: link.local_from_label_vertical_offset,
      local_from_label_color: link.local_from_label_color,
      local_from_size: link.local_from_size,
      local_from_x: link.local_from_x,
      local_from_y: link.local_from_y,
      local_from_line_width: link.local_from_line_width,
      local_from_line_dash: link.local_from_line_dash,
      local_from_line_dashed: link.local_from_line_dashed,
      local_from_line_color: link.local_from_line_color,
      local_from_border_width: link.local_from_border_width,
      local_from_border_color: link.local_from_border_color,
      local_to_color: link.local_to_color,
      local_to_corners: link.local_to_corners,
      local_to_label: link.local_to_label,
      local_to_label_rotation: link.local_to_label_rotation,
      local_to_label_font_size: link.local_to_label_font_size,
      local_to_label_horizontal_offset: link.local_to_label_horizontal_offset,
      local_to_label_vertical_offset: link.local_to_label_vertical_offset,
      local_to_label_color: link.local_to_label_color,
      local_to_size: link.local_to_size,
      local_to_x: link.local_to_x,
      local_to_y: link.local_to_y,
      local_to_line_width: link.local_to_line_width,
      local_to_line_dash: link.local_to_line_dash,
      local_to_line_dashed: link.local_to_line_dashed,
      local_to_line_color: link.local_to_line_color,
      local_to_border_width: link.local_to_border_width,
      local_to_border_color: link.local_to_border_color,
      inserted_at: link.inserted_at,
      updated_at: link.local_to_border_color
    }
  end
end
