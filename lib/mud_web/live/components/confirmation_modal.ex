defmodule MudWeb.Live.Components.ConfirmationModal do
  use Phoenix.Component

  def content(assigns) do
    ~H"""
    <div id="ConfirmationModal" phx-target={@target} class="fixed inset-0 z-20 overflow-y-auto"
      phx-window-keydown="close_modal"
      phx-key="escape">
      <div class="flex items-end justify-center min-h-screen px-1 pt-4 pb-20 text-center sm:block sm:p-0">
        <div class="fixed inset-0 bg-black bg-opacity-75 transition-opacity" aria-hidden="true"></div>
        <span class="hidden sm:inline-block sm:align-middle sm:h-screen" aria-hidden="true">&#8203;</span>
        <div class="inline-block overflow-hidden text-left align-bottom bg-neutral-800 shadow-md rounded-md transform transition-all sm:my-8 sm:align-middle sm:max-w-md sm:w-full">
          <div class="p-6 mx-auto mb-2 bg-neutral-800">
            <header class="mb-6 text-center">
              <h3 class="mb-3 text-lg font-bold">
                <%= render_slot(@header) %>
              </h3>
            </header>
            <%= render_slot(@inner_block) %>
            <footer class="flex mt-6 gap-x-10 justify-center">
              <%= render_slot(@footer) %>
            </footer>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def cancel_button(assigns) do
    ~H"""
    <button
      class="btn-red"
      phx-target={@target}
      phx-click="close_modal">
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  def confirm_button(assigns) do
    ~H"""
    <button
      class="btn-green"
      phx-target={@target}
      phx-click={@event}>
      <%= render_slot(@inner_block) %>
    </button>
    """
  end
end
