defmodule MudWeb.LandingPageLive do
  use Phoenix.LiveView

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket, %{
       changeset: MudWeb.Schema.Email.new() |> MudWeb.Schema.Email.changeset(),
       has_email_error?: false
     })}
  end

  def render(assigns) do
    MudWeb.PageView.render("landing_page.html", assigns)
  end

  def handle_event("validate", _form = %{"email" => params}, socket) do
    changeset = MudWeb.Schema.Email.new(params) |> Map.put(:action, :insert)

    {:noreply,
     assign(socket,
       changeset: changeset,
       has_email_error?: Mud.Util.changeset_has_error?(changeset, :email)
     )}
  end

  def handle_event("authenticate", _form = %{"email" => email}, socket) do
    case Mud.Account.authenticate_via_email(email["email"]) do
      {:ok, :player_created} ->
        {:stop,
         socket
         |> put_flash(
           :success,
           "Welcome to the adventure! Please check your email for the log in token."
         )
         |> redirect(to: "/token")}

      {:ok, :player_found} ->
        {:stop,
         socket
         |> put_flash(
           :success,
           "Welcome back, adventurer!, Please check your email for the log in token."
         )
         |> redirect(to: "/token")}

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
