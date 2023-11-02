defmodule MudWeb.CharacterContainersView do
  use MudWeb, :view

  def render("character_containers.json", %{character_containers: character_containers}) do
    character_containers
  end
end
