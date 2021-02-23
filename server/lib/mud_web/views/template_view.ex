defmodule MudWeb.TemplateView do
  use MudWeb, :view
  alias MudWeb.TemplateView

  def render("index.json", %{templates: templates}) do
    render_many(templates, TemplateView, "template.json")
  end

  def render("show.json", %{template: template}) do
    render_one(template, TemplateView, "template.json")
  end

  def render("template.json", %{template: template}) do
    template
  end
end
