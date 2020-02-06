defmodule Mud.Engine.Commands do
  @moduledoc """
  Work with the Commands known to the engine.
  """

  alias Mud.Engine.Command

  @commands MapSet.new([
              %Command{command: "ask", callback_module: Command.Placeholder},
              %Command{command: "bark", callback_module: Command.Placeholder},
              %Command{command: "climb", callback_module: Command.Placeholder},
              %Command{command: "dance", callback_module: Command.Placeholder},
              %Command{command: "e", callback_module: Command.Move},
              %Command{command: "east", callback_module: Command.Move},
              %Command{command: "go", callback_module: Command.Move},
              %Command{command: "hide", callback_module: Command.Placeholder},
              %Command{command: "history", callback_module: Command.History},
              %Command{command: "jump", callback_module: Command.Placeholder},
              %Command{command: "laugh", callback_module: Command.Placeholder},
              %Command{command: "l", callback_module: Command.Look},
              %Command{command: "look", callback_module: Command.Look},
              %Command{command: "meow", callback_module: Command.Placeholder},
              %Command{command: "move", callback_module: Command.Move},
              %Command{command: "n", callback_module: Command.Move},
              %Command{command: "north", callback_module: Command.Move},
              %Command{command: "northeast", callback_module: Command.Move},
              %Command{command: "northwest", callback_module: Command.Move},
              %Command{command: "nw", callback_module: Command.Move},
              %Command{command: "ne", callback_module: Command.Move},
              %Command{command: "out", callback_module: Command.Move},
              %Command{command: "park", callback_module: Command.Placeholder},
              %Command{command: "peek", callback_module: Command.Placeholder},
              %Command{command: "quit", callback_module: Command.Quit},
              %Command{command: "run", callback_module: Command.Placeholder},
              %Command{command: "search", callback_module: Command.Placeholder},
              %Command{command: "shove", callback_module: Command.Placeholder},
              %Command{command: "slap", callback_module: Command.Placeholder},
              %Command{command: "sleep", callback_module: Command.Placeholder},
              %Command{command: "slide", callback_module: Command.Placeholder},
              %Command{command: "slip", callback_module: Command.Placeholder},
              %Command{command: "smile", callback_module: Command.Placeholder},
              %Command{command: "smirk", callback_module: Command.Placeholder},
              %Command{command: "snicker", callback_module: Command.Placeholder},
              %Command{command: "snipe", callback_module: Command.Placeholder},
              %Command{command: "snore", callback_module: Command.Placeholder},
              %Command{command: "steal", callback_module: Command.Placeholder},
              %Command{command: "strip", callback_module: Command.Placeholder},
              %Command{command: "s", callback_module: Command.Move},
              %Command{command: "south", callback_module: Command.Move},
              %Command{command: "sw", callback_module: Command.Move},
              %Command{command: "southwest", callback_module: Command.Move},
              %Command{command: "se", callback_module: Command.Move},
              %Command{command: "southeast", callback_module: Command.Move},
              %Command{command: "swing", callback_module: Command.Placeholder},
              %Command{command: "swipe", callback_module: Command.Placeholder},
              %Command{command: "tap", callback_module: Command.Placeholder},
              %Command{command: "tie", callback_module: Command.Placeholder},
              %Command{command: "tip", callback_module: Command.Placeholder},
              %Command{command: "trip", callback_module: Command.Placeholder},
              %Command{command: "twirl", callback_module: Command.Placeholder},
              %Command{command: "walk", callback_module: Command.Placeholder},
              %Command{command: "waltz", callback_module: Command.Placeholder},
              %Command{command: "wake", callback_module: Command.Placeholder},
              %Command{command: "w", callback_module: Command.Move},
              %Command{command: "west", callback_module: Command.Move}
            ])

  @doc """
  Given a verb, or partial verb, as input return a list of possible matches and their callbacks.
  """
  def find_command(input) do
    case Enum.find(@commands, fn command -> command.command == input end) do
      command = %Command{} ->
        {:ok, command}

      nil ->
        {:error, :not_found}
    end
  end
end
