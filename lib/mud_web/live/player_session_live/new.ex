defmodule MudWeb.PlayerSessionLive.New do
  use MudWeb, :live_view

  alias Mud.Account
  alias Mud.Account.Player

  @impl true
  def mount(_params, _session, socket) do
    changeset = Account.change_player_login(%Player{})
    {:ok, assign(socket, changeset: changeset, trigger_submit: false, page_title: "Log in")}
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    if socket.assigns.live_action == :login do
      {:noreply, socket}
    else
      {:noreply,
       socket
       |> put_flash(:error, "Invalid email or password.")
       |> push_patch(to: Routes.player_session_new_path(socket, :login))}
    end
  end

  @impl true
  def handle_event("validate", %{"player" => player_params}, socket) do
    changeset =
      %Player{}
      |> Account.change_player_login(player_params)
      |> Map.put(:action, :insert)

    socket =
      socket
      |> assign(changeset: changeset)

    {:noreply, socket}
  end

  @impl true
  def handle_event("save", %{"player" => player_params}, socket) do
    changeset =
      %Player{}
      |> Account.change_player_login(player_params)
      |> Map.put(:action, :insert)

    if changeset.valid? do
      socket =
        socket
        |> assign(changeset: changeset)
        |> assign(trigger_submit: true)

      {:noreply, socket}
    else
      socket =
        socket
        |> assign(changeset: changeset)

      {:noreply, socket}
    end
  end
end
