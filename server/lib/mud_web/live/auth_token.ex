defmodule MudWeb.AuthTokenLive do
  use Phoenix.LiveView

  alias Mud.Account.Player

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket, %{
       changeset: MudWeb.Schema.Token.new() |> MudWeb.Schema.Token.changeset()
     })}
  end

  def render(assigns) do
    MudWeb.PageView.render("auth_token.html", assigns)
  end

  def handle_event("validate", _form = %{"token" => token}, socket) do
    changeset = MudWeb.Schema.Token.new(token) |> Map.put(:action, :insert)

    {:noreply,
     assign(socket,
       changeset: changeset
     )}
  end

  def handle_event("submit", _form = %{"token" => token}, socket) do
    case Mud.Account.validate_auth_token(token["token"]) do
      {:ok, %Player{} = player} ->
        {:stop,
         socket
         |> put_flash(
           :success,
           "Token validated!"
         )
         |> assign(
           player: player,
           player_authenticated?: true
         )
         |> redirect(to: "/home")}

      {:error, :invalid} ->
        socket =
          socket
          |> put_flash(
            :error,
            "The Auth token submitted has either expired or has already been used."
          )
          |> assign(changeset: MudWeb.Schema.Token.new() |> MudWeb.Schema.Token.changeset())

        {:noreply, socket}
    end
  end
end
