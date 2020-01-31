defmodule MudWeb.MudClientLive do
  use Phoenix.LiveView

  def mount(_params, session, socket) do
    :ok = Mud.Engine.start_character_session(session["character_id"])
    :ok = Mud.Engine.subscribe_to_character_output_messages(session["character_id"])

    {:ok,
     assign(socket, %{
       player_id: session["player"].id,
       character_id: session["character_id"],
       command: "",
       even: true,
       messages: []
     }), temporary_assigns: [messages: []]}
  end

  def render(assigns) do
    assigns = %{assigns | command: ""}
    MudWeb.MudClientView.render("v1.html", assigns)
  end

  def handle_event("input", %{"code" => "Enter", "value" => input}, socket) do
    Mud.Engine.send_message_for(
      Mud.Engine.Message.new(
        socket.assigns.player_id,
        socket.assigns.character_id,
        input,
        :input
      )
    )

    {:noreply,
     assign(socket, %{
       even: !socket.assigns.even
     })}
  end

  def handle_event("input", _, socket) do
    {:noreply, socket}
  end

  def handle_info({:output, message}, socket) do
    text = transform_output_for_web(message.text)

    {:noreply,
     assign(socket, %{
       messages: socket.assigns.messages ++ [%{id: message.id, text: text}]
     })}
  end

  defp transform_output_for_web(text) do
    case Regex.named_captures(~r/.*?{{(?<tag>.+?)}}.*/, text) do
      nil ->
        text

      %{"tag" => tag} ->
        text
        |> String.replace("{{#{tag}}}", "<span class=\"#{tag_to_text_color(tag)}\">")
        |> String.replace("{{/#{tag}}}", "</span>")
        |> transform_output_for_web()
    end
  end

  defp tag_to_text_color("area-name") do
    "text-yellow-700"
  end

  defp tag_to_text_color("area-description") do
    "text-teal-700"
  end

  defp tag_to_text_color("also-present") do
    "text-green-700"
  end

  defp tag_to_text_color("obvious-exits") do
    "text-blue-700"
  end

  defp tag_to_text_color("echo") do
    "text-gray-700"
  end

  defp tag_to_text_color(_tag) do
    "text-black"
  end
end
