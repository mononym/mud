defmodule MudWeb.Live.Component.Story do
  use Phoenix.LiveComponent

  require Logger

  defmodule Input do
    use Ecto.Schema

    embedded_schema do
      field(:content, :string, default: "")
    end

    def new, do: %__MODULE__{} |> Ecto.Changeset.change(%{id: UUID.uuid4()})

    def new(content),
      do: %__MODULE__{} |> Ecto.Changeset.change(%{id: UUID.uuid4(), content: content})
  end

  def mount(socket) do
    socket =
      socket
      |> assign(
        input: Input.new(),
        messages: [],
        commands: [],
        command_index: 0,
        latest_input: ""
      )

    {:ok, socket, temporary_assigns: [messages: []]}
  end

  # def update(assigns, socket) do
  #   socket = assign(socket, Enum.to_list(assigns))

  #   socket =
  #     cond do
  #       not socket.assigns.initialized ->
  #         init_inventory_data(socket)
  #         |> assign(:initialized, true)
  #         |> assign(:loading, false)

  #       not is_nil(socket.assigns.event) ->
  #         event = socket.assigns.event
  #         items = event.items

  #         case event.action do
  #           :add ->
  #             Enum.reduce(items, socket, fn thing, socket ->
  #               modify(socket, thing)
  #             end)

  #           :remove ->
  #             Enum.reduce(items, socket, fn thing, socket ->
  #               remove(socket, thing)
  #             end)

  #           :update ->
  #             Enum.reduce(items, socket, fn thing, socket ->
  #               modify(socket, thing)
  #             end)
  #         end

  #       true ->
  #         socket
  #     end

  #   {:ok, socket}
  # end


  def render(assigns) do
    Phoenix.View.render(MudWeb.MudClientView, "story.html", assigns)
  end
  def handle_event("input_change", %{"input" => %{"content" => input}}, socket) do
    Logger.debug(inspect(input))
    {:noreply, assign(socket, :latest_input, input)}
  end

  def handle_event("submit_input", %{"input" => %{"content" => ""}}, socket) do
    Logger.debug(inspect(socket.assigns.input))
    {:noreply, socket}
  end

  # input sent via text box
  def handle_event("submit_input", %{"input" => %{"content" => input}}, socket) do
    Logger.debug("Handling input event: #{inspect(input)}")
    send_command(socket.assigns.character.id, input)
    Logger.debug("Sent input")

    {:noreply,
     assign(socket,
       input: Input.new(),
       commands: Enum.slice([input | socket.assigns.commands], 0..99),
       command_index: 0,
       viewing_history: false,
       latest_input: ""
     )}
  end

  defp send_command(character_id, text, type \\ :normal) do
    %Mud.Engine.Message.Input{id: UUID.uuid4(), to: character_id, text: text, type: type}
    |> Mud.Engine.Session.cast_message_or_event()
  end
end
