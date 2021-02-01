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
    link
    |> Map.from_struct()
    |> Map.delete(:from)
    |> Map.delete(:to)
    |> Map.delete(:__meta__)
    |> Map.put(
      :flags,
      render_one(
        link.flags,
        LinkFlagsView,
        "link_flags.json"
      )
    )
    |> Map.put(
      :closable,
      render_one(
        link.closable,
        LinkClosableView,
        "link_closable.json"
      )
    )
    |> Recase.Enumerable.convert_keys(&Recase.to_camel/1)
  end
end
