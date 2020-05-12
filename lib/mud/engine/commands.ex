defmodule Mud.Engine.Commands do
  @moduledoc """
  Work with the Commands known to the engine.
  """

  alias Mud.Engine.{Command}
  alias Mud.Engine.Command.Segment

  @commands MapSet.new([
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
                    transformer: &String.to_integer/1
                  },
                  %Segment{
                    key: :target,
                    must_follow: [:at, :look, :switch, :number],
                    greedy: true
                  }
                ]
              },
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
                    greedy: true
                  }
                ]
              },
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
                    key: :move
                  },
                  %Segment{
                    must_follow: [:move],
                    match_strings: [],
                    key: :exit
                  },
                  %Segment{
                    must_follow: [:move],
                    match_strings: ["/continue"],
                    key: :continue
                  },
                  %Segment{
                    must_follow: [:continue],
                    match_strings: [
                      ~r/^[0-9A-F]{8}-[0-9A-F]{4}-4[0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}$/
                    ],
                    key: :link_id
                  }
                ]
              },
              %Command{
                callback_module: Command.Sit,
                segments: [
                  %Segment{
                    match_strings: ["sit"],
                    key: :sit
                  },
                  %Segment{
                    must_follow: [:sit],
                    match_strings: ["/continue"],
                    key: :continue
                  },
                  %Segment{
                    must_follow: [:continue],
                    match_strings: [
                      ~r/^[0-9A-F]{8}-[0-9A-F]{4}-4[0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}$/
                    ],
                    key: :object_id
                  },
                  %Segment{
                    must_follow: [:sit],
                    match_strings: ["on"],
                    key: :position
                  },
                  %Segment{
                    must_follow: [:position, :sit],
                    match_strings: [],
                    key: :target
                  }
                ]
              },
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
            ])

  @doc """
  Given a string as input, try to find a Command which it matches.
  """
  @spec find_command(String.t()) :: {:ok, Command.t()} | {:error, :no_match}
  def find_command(input) do
    case Enum.find(@commands, fn command ->
           command_segment = List.first(command.segments)
           Enum.any?(command_segment.match_strings, fn string -> string == input end)
         end) do
      command = %Command{} ->
        {:ok, command}

      nil ->
        {:error, :no_match}
    end
  end
end
