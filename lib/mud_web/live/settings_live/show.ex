defmodule MudWeb.SettingsLive.Show do
  use MudWeb, :live_view

  alias Mud.Account
  require Logger

  @impl true
  def mount(params, _session, socket) do
    player = socket.assigns.current_player

    if socket.assigns.live_action == :confirm_email do
      case Account.update_player_email(player, params["token"]) do
        :ok ->
          {:ok,
           socket
           |> put_flash(:info, "Email changed successfully.")
           |> push_redirect(to: Routes.settings_show_path(socket, :edit))}

        :error ->
          {:ok,
           socket
           |> put_flash(:error, "Email change link is invalid or it has expired.")
           |> push_redirect(to: Routes.settings_show_path(socket, :edit))}
      end
    else
      {:ok,
       socket
       |> assign(:email_changeset, Account.change_player_email(player))
       |> assign(:password_changeset, Account.change_player_password(player))
       |> assign(:timezone_changeset, Account.change_player_timezone(player))
       |> assign(:delete_player, false)}
    end
  end

  @impl true
  def handle_params(_params, uri, socket) do
    log_player_navigation_path(socket, uri)
    {:noreply, socket}
  end

  @impl true
  def handle_event("update_email", params, socket) do
    %{"current_password" => password, "player" => player_params} = params
    player = socket.assigns.current_player

    case Account.apply_player_email(player, password, player_params) do
      {:ok, applied_player} ->
        Account.deliver_update_email_instructions(
          applied_player,
          Map.get(player, :email),
          &Routes.settings_show_url(socket, :confirm_email, &1)
        )

        {:noreply,
         socket
         |> put_flash(
           :info,
           "A link to confirm your email change has been sent to the new address."
         )
         |> assign(:email_changeset, Account.change_player_email(player))}

      {:error, changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Encountered an error when trying to update your email.")
         |> assign(email_changeset: changeset)}
    end
  end

  @impl true
  def handle_event("update_password", params, socket) do
    %{"current_password" => password, "player" => player_params} = params
    player = socket.assigns.current_player

    case Account.update_player_password(player, password, player_params) do
      {:ok, _player} ->
        {:noreply,
         socket
         |> put_flash(:info, "Password updated successfully.")
         |> redirect(to: Routes.player_session_path(socket, :create))}

      {:error, changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Encountered an error when trying to update your password.")
         |> assign(password_changeset: changeset)}
    end
  end

  @impl true
  def handle_event("update_timezone", params, socket) do
    %{"player" => timezone_params} = params
    player = socket.assigns.current_player

    case Account.update_player_timezone(player, timezone_params) do
      {:ok, player} ->
        {:noreply,
         socket
         |> put_flash(:info, "Timezone updated successfully.")
         |> assign(timezone_changeset: Account.change_player_timezone(player))}

      {:error, changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Encountered an error when trying to update your timezone.")
         |> assign(timezone_changeset: changeset)}
    end
  end

  @impl true
  def handle_event("delete_player", _params, socket) do
    {:noreply, assign(socket, delete_player: true)}
  end

  @impl true
  def handle_event("close_modal", _params, socket) do
    {:noreply, assign(socket, delete_player: false)}
  end

  @impl true
  def handle_event("confirm_delete_player", _params, socket) do
    tokens = Account.list_session_tokens(socket.assigns.current_player.id)
    Account.delete_session_tokens(socket.assigns.current_player.id)

    Enum.each(tokens, fn token ->
      encoded_token = "player_sessions:#{token}"

      if encoded_token != socket.assigns.live_socket_id do
        MudWeb.Endpoint.broadcast("player_sessions:#{encoded_token}", "disconnect", %{})
      end
    end)

    Account.delete_player(socket.assigns.current_player)

    {:noreply,
     socket
     |> put_flash(:info, "Player has been deleted.")
     |> assign(delete_player: false)
     |> redirect(to: "/")}
  end
end
