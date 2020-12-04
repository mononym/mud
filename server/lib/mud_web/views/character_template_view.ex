defmodule MudWeb.CharacterTemplateView do
  use MudWeb, :view
  alias MudWeb.CharacterTemplateView

  def render("index.json", %{character_templates: character_templates}) do
    render_many(character_templates, CharacterTemplateView, "character_template.json")
  end

  def render("show.json", %{character_template: character_template}) do
    render_one(character_template, CharacterTemplateView, "character_template.json")
  end

  def render("character_template.json", %{character_template: character_template}) do
    %{
      id: character_template.id,
      name: character_template.name,
      description: character_template.description,
      template: character_template.template
    }
  end
end
