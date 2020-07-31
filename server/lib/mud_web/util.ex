defmodule MudWeb.Util do
  def referrer_to_uri(referer) do
    referer
    |> String.split("/", parts: 4)
    |> Enum.at(3)
    |> (&"/#{&1}").()
  end
end
