defmodule MudWeb.AuthTokenLive do
  use Phoenix.LiveView

  alias Mud.Account.Player

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket, %{
       changeset: MudWeb.Schema.Token.new() |> MudWeb.Schema.Token.changeset(),
       has_email_error?: false
     })}
  end

  def render(assigns) do
    MudWeb.PageView.render("auth_token.html", assigns)
  end

  def handle_event("validate", form, socket) do
    IO.inspect(form)

    case Mud.Account.validate_auth_token(form["token"]) do
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

      {:error, :player_not_created} ->
        socket =
          socket
          |> put_flash(
            :error,
            "Something went wrong while creating account. Please try again. If error persists, please contact support."
          )
          |> assign(
            changeset: MudWeb.Schema.Email.new() |> MudWeb.Schema.Email.changeset(),
            has_email_error?: false
          )

        {:noreply, socket}
    end
  end
end
