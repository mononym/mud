defmodule MudWeb.PlayerResetPasswordLive.Finish do
  use MudWeb, :live_view

  alias Mud.Account
  alias Mud.Account.Player

  @impl true
  def mount(%{"token" => token}, _session, socket) do
    if player = Account.get_player_by_reset_password_token(token) do
      {:ok,
       socket
       |> assign(:player, player)
       |> assign(:token, token)
       |> assign(:changeset, Account.change_player_password(%Player{}))}
    else
      {:ok,
       socket
       |> put_flash(:error, "Reset password link is invalid or it has expired.")
       |> push_redirect(to: Routes.player_reset_password_start_path(socket, :reset_password_start), page_title: "Reset Password")}
    end
  end

  @impl true
  def handle_event("validate", %{"player" => player_params}, socket) do
    changeset =
      %Player{}
      |> Account.change_player_password(player_params)
      |> Map.put(:action, :insert)

    socket =
      socket
      |> assign(changeset: changeset)

    {:noreply, socket}
  end

  @impl true
  def handle_event("complete_password_reset", %{"player" => player_params}, socket) do
    case Account.reset_player_password(socket.assigns.player, player_params) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Password reset successfully.")
         |> push_redirect(to: Routes.player_session_new_path(socket, :login))}

      {:error, changeset} ->
        {:noreply,
         socket
         |> put_flash(:info, "There was an error resetting your password. Please try again.")
         |> assign(changeset: changeset)}
    end
  end
end
