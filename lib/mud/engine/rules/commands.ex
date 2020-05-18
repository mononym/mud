defmodule Mud.Engine.Rules.Commands do
  @moduledoc """
  Work with the Commands known to the engine.
  """

  alias Mud.Engine.{Command}
  alias Mud.Engine.Command.Segment

  ##
  # API
  ##

  @doc """
  Given a string as input, try to find a Command which it matches.
  """
  @spec find_command(String.t()) :: {:ok, Command.t()} | {:error, :no_match}
  def find_command(input) do
    case Enum.find(list_all_command_definitions(), fn command ->
           command_segment = List.first(command.segments)
           Enum.any?(command_segment.match_strings, fn string -> string == input end)
         end) do
      command = %Command{} ->
        {:ok, command}

      nil ->
        {:error, :no_match}
    end
  end

  ##
  # Private Functions
  ##

  defp list_all_command_definitions do
    MapSet.new([
      define_look_command(),
      define_say_command(),
      define_move_command(),
      define_sit_command(),
      define_quit_command()
    ])
  end

  defp define_quit_command do
    %Command{
      callback_module: Command.Quit,
      segments: [
        %Segment{
          match_strings: [
            "quit"
          ],
          key: :quit
        }
      ]
    }
  end

  defp define_sit_command do
    %Command{
      callback_module: Command.Sit,
      segments: [
        %Segment{
          match_strings: ["sit"],
          key: :sit
        },
        %Segment{
          must_follow: [:sit],
          match_strings: ["on"],
          key: :position
        },
        %Segment{
          must_follow: [:position, :sit],
          match_strings: [],
          key: :target,
          greedy: true,
          transformer: &join_input_with_space_downcase/1
        }
      ]
    }
  end

  defp define_move_command do
    %Command{
      callback_module: Command.Move,
      segments: [
        %Segment{
          match_strings: [
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
          transformer: &join_input_with_space_downcase/1
        },
        %Segment{
          key: :number,
          match_strings: [~r/\d/],
          must_follow: [:move],
          transformer: &single_string_to_int/1
        },
        %Segment{
          must_follow: [:move, :number],
          match_strings: [],
          key: :exit,
          transformer: &join_input_with_space_downcase/1
        }
      ]
    }
  end

  defp define_say_command do
    %Command{
      callback_module: Command.Placeholder,
      segments: [
        %Segment{
          match_strings: ["say"],
          key: :say
        },
        %Segment{
          match_strings: ["to"],
          key: :to,
          must_follow: [:say, :switch]
        },
        %Segment{
          must_follow: [:say, :switch],
          prefix: "@",
          key: :at
        },
        %Segment{
          must_follow: [:to],
          key: :character
        },
        %Segment{
          must_follow: [:say, :at, :character],
          match_strings: ["slowly"],
          prefix: "/",
          key: :switch
        },
        %Segment{
          must_follow: [:character, :say, :switch, :at],
          key: :words,
          greedy: true,
          transformer: &join_input_with_space_downcase/1
        }
      ]
    }
  end

  defp define_look_command do
    %Command{
      callback_module: Command.Look,
      segments: [
        %Segment{
          match_strings: ["l", "look"],
          key: :look
        },
        %Segment{
          match_strings: ["loving", "shy"],
          prefix: "/",
          key: :switch,
          must_follow: [:look]
        },
        %Segment{
          match_strings: ["at"],
          key: :at,
          must_follow: [:look, :switch]
        },
        %Segment{
          key: :number,
          match_strings: [~r/\d/],
          must_follow: [:at, :look, :switch],
          transformer: &single_string_to_int/1
        },
        %Segment{
          key: :target,
          must_follow: [:at, :look, :switch, :number],
          greedy: true,
          transformer: &join_input_with_space_downcase/1
        }
      ]
    }
  end

  defp join_input_with_space_downcase(input) do
    Enum.join(input, " ") |> String.downcase()
  end

  defp single_string_to_int([input]) do
    String.to_integer(input)
  end
end
