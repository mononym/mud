defmodule MudWeb.CharacterTemplateController do
  use MudWeb, :controller

  alias Mud.Engine.CharacterTemplate
  alias Mud.Engine.TemplateFeature

  action_fallback(MudWeb.FallbackController)

  def index(conn, _params) do
    character_templates = CharacterTemplate.list()
    render(conn, "index.json", character_templates: character_templates)
  end

  def create(conn, character_template_params) do
    with {:ok, %CharacterTemplate{} = character_template} <-
           CharacterTemplate.create(character_template_params) do
      conn
      |> put_status(:created)
      |> put_resp_header(
        "location",
        Routes.character_template_path(conn, :show, character_template)
      )
      |> render("show.json", character_template: character_template)
    end
  end

  def show(conn, %{"id" => id}) do
    character_template = CharacterTemplate.get!(id)
    render(conn, "show.json", character_template: character_template)
  end

  def preview(conn, %{"template_id" => template_id, "features" => features}) do
    character_template = CharacterTemplate.get!(template_id)
    template = character_template.template

    features =
      Map.to_list(features)
      |> Enum.map(fn {key, value} ->
        {String.to_atom(key), value}
      end)

    text = EEx.eval_string(template, [{:pronoun, "they"}] ++ features)

    json(conn, %{preview: text})
  end

  def update(conn, character_template_params = %{"id" => id}) do
    character_template = CharacterTemplate.get!(id)

    with {:ok, %CharacterTemplate{} = character_template} <-
           CharacterTemplate.update(character_template, character_template_params) do
      render(conn, "show.json", character_template: character_template)
    end
  end

  def delete(conn, %{"id" => id}) do
    character_template = CharacterTemplate.get!(id)

    with {:ok, %CharacterTemplate{}} <- CharacterTemplate.delete(character_template) do
      send_resp(conn, :no_content, "")
    end
  end

  def link_feature(conn, %{
        "character_template_feature_id" => feature_id,
        "character_template_id" => template_id
      }) do
    with {:ok, _} <- TemplateFeature.link(template_id, feature_id),
         %CharacterTemplate{} = character_template <- CharacterTemplate.get!(template_id) do
      conn
      |> put_status(:ok)
      |> render("show.json", character_template: character_template)
    end
  end

  def unlink_feature(conn, %{
        "character_template_feature_id" => feature_id,
        "character_template_id" => template_id
      }) do
    TemplateFeature.unlink(template_id, feature_id)

    character_template = CharacterTemplate.get!(template_id)

    conn
    |> put_status(:ok)
    |> render("show.json", character_template: character_template)
  end
end
