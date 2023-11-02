defmodule MudWeb.PlayerRegistrationLive.New do
  use MudWeb, :live_view

  alias Mud.Account
  alias Mud.Account.Player

  def mount(_params, _session, socket) do
    changeset = Account.change_player_registration(%Player{})
    {:ok, assign(socket, changeset: changeset, trigger_submit: false, page_title: "Player Registration")}
  end

  def handle_event("validate", %{"player" => player_params}, socket) do
    changeset =
      %Player{}
      |> Account.change_player_registration(player_params)
      |> Map.put(:action, :insert)

    socket =
      socket
      |> assign(changeset: changeset)

    {:noreply, socket}
  end

  def handle_event("save", %{"player" => player_params}, socket) do
    changeset =
      %Player{}
      |> Account.change_player_registration(player_params)
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
