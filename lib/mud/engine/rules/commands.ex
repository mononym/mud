defmodule Mud.Engine.Rules.Commands do
  @moduledoc """
  Work with the Commands known to the engine.
  """

  alias Mud.Engine.{Command}
  alias Mud.Engine.Command.Part
  alias Mud.Engine.Command.Definition
  alias Mud.Engine.Command.Definition.Part
  alias Mud.Engine.Util

  ##
  # API
  ##

  @doc """
  Given a string as input, try to find a Command which it matches.
  """
  @spec find_command_definition(String.t()) :: {:ok, Definition.t()} | {:error, :no_match}
  def find_command_definition(input) do
    case Enum.find(list_all_command_definitions(), fn command ->
           command_part = List.first(command.parts)

           Enum.any?(command_part.matches, fn match_string ->
             Util.check_equiv(match_string, input)
           end)
         end) do
      definition = %Definition{} ->
        {:ok, definition}

      nil ->
        {:error, :no_match}
    end
  end

  @doc """
  Given a string as input, try to find a Command which it matches.
  """
  @spec find_command(String.t()) :: {:ok, Command.t()} | {:error, :no_match}
  def find_command(input) do
    case Enum.find(list_all_command_definitions(), fn command ->
           command_part = List.first(command.parts)
           Enum.any?(command_part.matches, fn string -> string == input end)
         end) do
      definition = %Definition{} ->
        {:ok, definition}

      nil ->
        {:error, :no_match}
    end
  end

  ##
  # Private Functions
  ##

  defp list_all_command_definitions do
    MapSet.new([
      define_kick_command(),
      define_kneel_command(),
      define_look_command(),
      define_move_command(),
      define_put_command(),
      define_quit_command(),
      define_say_command(),
      define_sit_command(),
      define_stand_command()
    ])
  end

  defp define_quit_command do
    %Definition{
      callback_module: Command.Quit,
      parts: [
        %Part{
          matches: [
            "quit"
          ],
          key: :quit,
          transformer: &Enum.join/1
        }
      ]
    }
  end

  defp define_kneel_command do
    %Definition{
      callback_module: Command.Kneel,
      parts: [
        %Part{
          matches: ["kneel"],
          key: :kneel,
          transformer: &Enum.join/1
        },
        %Part{
          must_follow: [:kneel],
          matches: ["on"],
          key: :position,
          transformer: &Enum.join/1
        },
        %Part{
          must_follow: [:position, :kneel],
          matches: [~r/.*/],
          key: :target,
          greedy: true,
          transformer: &join_with_space_downcase/1
        }
      ]
    }
  end

  defp define_put_command do
    %Definition{
      callback_module: Command.Put,
      parts: [
        %Part{
          matches: ["put"],
          key: :put,
          transformer: &Enum.join/1
        },
        %Part{
          must_follow: [:put],
          matches: [~r/.*/],
          key: :thing,
          transformer: &join_with_space_downcase/1
        },
        %Part{
          must_follow: [:thing],
          matches: ["in"],
          key: :path,
          transformer: &Enum.join/1
        },
        %Part{
          must_follow: [:path],
          matches: [~r/.*/],
          key: :place,
          transformer: &join_with_space_downcase/1
        }
      ]
    }
  end

  defp define_kick_command do
    %Definition{
      callback_module: Command.Kick,
      parts: [
        %Part{
          matches: ["kick"],
          key: :kick,
          transformer: &Enum.join/1
        },
        %Part{
          must_follow: [:kick],
          matches: [~r/.*/],
          key: :target,
          greedy: true,
          transformer: &join_with_space_downcase/1
        }
      ]
    }
  end

  defp define_sit_command do
    %Definition{
      callback_module: Command.Sit,
      parts: [
        %Part{
          matches: ["sit"],
          key: :sit,
          transformer: &Enum.join/1
        },
        %Part{
          must_follow: [:sit],
          matches: ["on"],
          key: :position,
          transformer: &Enum.join/1
        },
        %Part{
          must_follow: [:position, :sit],
          matches: [~r/.*/],
          key: :target,
          transformer: &join_with_space_downcase/1
        }
      ]
    }
  end

  defp define_stand_command do
    %Definition{
      callback_module: Command.Stand,
      parts: [
        %Part{
          matches: ["stand"],
          key: :stand,
          transformer: &Enum.join/1
        }
      ]
    }
  end

  defp define_move_command do
    %Definition{
      callback_module: Command.Move,
      parts: [
        %Part{
          matches: [
            "n",
            "north",
            "s",
            "south",
            "e",
            "east",
            "w",
            "west",
            "nw",
            "northwest",
            "ne",
            "northeast",
            "sw",
            "southwest",
            "se",
            "southeast",
            "in",
            "out",
            "up",
            "down",
            "go",
            "move"
          ],
          key: :move,
          transformer: &Enum.join/1
        },
        %Part{
          key: :number,
          matches: [~r/\d/],
          must_follow: [:move],
          transformer: &string_to_int/1
        },
        %Part{
          must_follow: [:move, :number],
          matches: [~r/.*/],
          key: :exit,
          transformer: &join_with_space_downcase/1
        }
      ]
    }
  end

  defp define_say_command do
    %Definition{
      callback_module: Command.Placeholder,
      parts: [
        %Part{
          matches: ["say"],
          key: :say,
          transformer: &Enum.join/1
        },
        %Part{
          matches: ["to"],
          key: :to,
          must_follow: [:say, :switch],
          transformer: &Enum.join/1
        },
        %Part{
          must_follow: [:to],
          matches: [~r/^\@[a-zA-Z]+/],
          key: :character,
          transformer: &trim_at/1
        },
        %Part{
          must_follow: [:say, :character],
          matches: ["/slowly"],
          key: :switch,
          transformer: &trim_slash/1
        },
        %Part{
          must_follow: [:character, :say, :switch],
          matches: [~r/.*/],
          key: :words,
          greedy: true,
          drop_whitespace: false,
          transformer: &Enum.join/1
        }
      ]
    }
  end

  defp define_look_command do
    %Definition{
      callback_module: Command.Look,
      parts: [
        %Part{
          matches: ["l", "look"],
          key: :look,
          transformer: &join_with_space_downcase/1
        },
        %Part{
          matches: ["/loving", "/shy"],
          key: :switch,
          must_follow: [:look],
          transformer: &trim_slash/1
        },
        %Part{
          matches: ["at"],
          key: :at,
          must_follow: [:look, :switch],
          transformer: &join_with_space_downcase/1
        },
        %Part{
          key: :number,
          matches: [~r/\d/],
          must_follow: [:at, :look, :switch],
          transformer: &string_to_int/1
        },
        %Part{
          key: :target,
          must_follow: [:at, :look, :switch, :number],
          matches: [~r/.*/],
          transformer: &join_with_space_downcase/1
        }
      ]
    }
  end

  defp trim_at([input]) do
    String.trim_leading(input, "@")
  end

  defp trim_slash([input]) do
    String.trim_leading(input, "/")
  end

  defp join_with_space_downcase(input) do
    Enum.join(input, " ") |> String.downcase()
  end

  defp string_to_int([input]) do
    String.to_integer(input)
  end
end
