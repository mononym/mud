defmodule MudWeb.PlayerRegistrationLive.Confirm do
  use MudWeb, :live_view

  alias Mud.Account

  @impl true
  def mount(%{"token" => token}, _session, socket) do
    case Account.confirm_player(token) do
      {:ok, _} ->
        {:ok,
         socket
         |> put_flash(:info, "Player confirmed successfully.")
         |> push_redirect(to: Routes.home_show_path(socket, :show))}

      :error ->
        # If there is a current user and the account was already confirmed,
        # then odds are that the confirmation link was already visited, either
        # by some automation or by the user themselves, so we redirect without
        # a warning message.
        case socket.assigns do
          %{current_player: %{confirmed_at: confirmed_at}} when not is_nil(confirmed_at) ->
            {:ok,
              socket
              |> put_flash(:info, "Player has already been confirmed.")
              |> push_redirect(to: Routes.home_show_path(socket, :show))}

          %{} ->
            {:ok,
             socket
             |> put_flash(:error, "Player confirmation link is invalid or it has expired.")
             |> push_redirect(to: Routes.home_show_path(socket, :show))}
        end
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    """
  end
end
