defmodule MudWeb.Views.Character.Settings.CommandsView do
  use MudWeb, :view

  def render("commands.json", %{commands: commands}) do
    %{
      id: commands.id,
      search_mode: commands.search_mode,
      multiple_matches_mode: commands.multiple_matches_mode,
      say_requires_exact_emote: commands.say_requires_exact_emote,
      say_default_emote: commands.say_default_emote
    }
  end
end
