defmodule MudWeb.LiveHelpers do
  @moduledoc """
  Various helper functions to aid with live functionality.
  """
  import Phoenix.LiveView
  import Phoenix.LiveView.Helpers

  alias Phoenix.LiveView.JS

  require Logger

  @doc """
  Helper for logging the path the player has navigated to.
  """
  def log_player_navigation_path(socket, uri) do
    %URI{
      path: path
    } = URI.parse(uri)

    if socket.assigns.current_player do
      Logger.info("Player #{socket.assigns.current_player.id} navigated to #{path}")
    else
      Logger.info("Anonymous player navigated to #{path}")
    end
  end

  @doc """
  Send a flash message to the main LiveView process from a component for display.
  """
  def send_self_flash_info(message) do
    send_flash_message(:info, message)
  end

  @doc """
  Send a flash message to the main LiveView process from a component for display.
  """
  def send_self_flash_error(message) do
    send_flash_message(:error, message)
  end

  defp send_flash_message(type, message) do
    send(self(), {:flash, type, message})
  end

  @doc """
  Renders a live component inside a modal.

  The rendered modal receives a `:return_to` option to properly update
  the URL when the modal is closed.

  ## Examples

      <.modal return_to={Routes.account_index_path(@socket, :index)}>
        <.live_component
          module={TestphxWeb.AccountLive.FormComponent}
          id={@account.id || :new}
          title={@page_title}
          action={@live_action}
          return_to={Routes.account_index_path(@socket, :index)}
          account: @account
        />
      </.modal>
  """
  def modal(assigns) do
    assigns = assign_new(assigns, :return_to, fn -> nil end)
    assigns = assign_new(assigns, :close_on_escape, fn -> true end)

    ~H"""
    <div id="modal" class="phx-modal fade-in flex flex-col items-center mt-14 py-14" phx-hook="ScrollLock" phx-window-keydown={if @close_on_escape, do: JS.dispatch("click", to: "#close")} phx-key="escape">
      <div
        id="modal-content"
        class="phx-modal-content fade-in-scale bg-neutral-800 rounded w-full sm:w-11/12 flex flex-col gap-4 max-w-7xl mb-14"
      >
        <%= live_patch "✖",
          to: @return_to,
          id: "close",
          class: "phx-modal-close self-end mr-0.25 mt-4"
        %>

        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end
end
