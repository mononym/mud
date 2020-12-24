defmodule MudWeb.MudClientView do
  use MudWeb, :view

  def render("error.json", %{error: error}) do
    %{error: error}
  end

  def render("start_game_session.json", %{token: token}) do
    %{token: token}
  end
end
