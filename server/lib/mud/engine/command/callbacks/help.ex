defmodule Mud.Engine.Command.Help do
  @moduledoc """
  The HELP command, currently, only prints out this text but in the future will provide access to various help topics.

  The VERB command can be used to explore the commands that are available.
  """
  use Mud.Engine.Command.Callback

  alias Mud.Engine.Command.Context
  alias Mud.Engine.Message
  alias Mud.Engine.Util

  require Logger

  def build_ast(_ast_nodes) do
    :ok
  end

  @impl true
  def execute(%Context{} = context) do
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
