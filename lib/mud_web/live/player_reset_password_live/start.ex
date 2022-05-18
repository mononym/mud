defmodule MudWeb.PlayerResetPasswordLive.Start do
  use MudWeb, :live_view

  alias Mud.Account
  alias Mud.Account.Player

  @impl true
  def mount(_params, _session, socket) do
    changeset = Account.change_player_password(%Player{})
    {:ok, assign(socket, changeset: changeset, trigger_submit: false, page_title: "Reset Password")}
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
  def handle_event("start_password_reset", %{"player" => %{"email" => email}}, socket) do
    if player = Account.get_player_by_email(email) do
      Account.deliver_player_reset_password_instructions(
        player,
        &Routes.player_reset_password_finish_url(socket, :reset_password_finish, &1)
      )
    end

    {:noreply,
     socket
     |> put_flash(
       :info,
       "If your email is in our system, you will receive instructions to reset your password shortly."
     )
     |> push_redirect(to: "/")}
  end
end
