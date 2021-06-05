defmodule Mud.Engine.Command.Time do
  @moduledoc """
  The TIME command tells the approximate in game time.

  Print the time:
    - time
  """
  use Mud.Engine.Command.Callback

  alias Mud.Engine.Rules.Commands
  alias Mud.Engine.Command.Context
  alias Mud.Engine.Message
  alias Mud.Engine.Util

  require Logger

  def build_ast(_ast_nodes) do
    :ok
  end

  @impl true
  def execute(%Context{} = context) do
    ast = context.command.ast

    case ast do
      %{switch: switch, target: target} when not is_nil(switch) and not is_nil(target) ->
        case Commands.find_command_definition(target) do
          {:ok, definition} ->
            Context.append_message(
              context,
              Message.new_story_output(
                context.character.id,
                Util.get_module_docs(definition.callback_module),
                "system_info"
              )
            )

          _ ->
            Context.append_message(
              context,
              Message.new_story_output(
                context.character.id,
                "Could not find a matching verb/command to print the docs for.",
                "system_alert"
              )
            )
        end

      %{switch: switch, target: target} when not is_nil(switch) and is_nil(target) ->
        list_commands(context)

      _ ->
        Context.append_message(
          context,
          Message.new_story_output(
            context.character.id,
            Util.get_module_docs(__MODULE__),
            "system_info"
          )
        )
    end
  end

  defp list_commands(context) do
    chunked_emotes = Enum.chunk_every(@commands, 4, 4, ["", "", "", ""])

    title = "Available Commands"

    formatted_table_output =
      TableRex.Table.new(chunked_emotes)
      |> TableRex.Table.put_column_meta(:all, align: :center)
      |> TableRex.Table.put_title(title)
      |> TableRex.Table.render!(horizontal_style: :all)

    Context.append_message(
      context,
      Message.new_story_output(
        context.character.id,
        formatted_table_output,
        "base"
      )
    )
  end
end
