defmodule Mud.Engine.Commands do
  @moduledoc """
  Work with the Commands known to the engine.
  """

  alias Mud.Engine.{Command, Search}
  alias Mud.Engine.Command.Segment
  alias Mud.Engine.Command.Dependencies

  @commands MapSet.new([
              %Command{
                callback_module: Command.Look,
                segments: [
                  %Segment{
                    match_strings: ["l", "look"],
                    autocomplete: true,
                    key: :look
                  },
                  %Segment{
                    match_strings: ["loving", "shy"],
                    prefix: "/",
                    key: :switch,
                    max_allowed: 2,
                    must_follow: %Dependencies{any: [:look]}
                  },
                  %Segment{
                    match_strings: ["at"],
                    key: :at,
                    must_follow: %Dependencies{any: [:look, :switch]}
                  },
                  %Segment{
                    search: [Search.characters()],
                    key: :target,
                    must_follow: %Dependencies{any: [:at, :look, :switch]}
                  }
                ]
              },
              %Command{
                callback_module: Command.Placeholder,
                segments: [
                  %Segment{
                    match_strings: ["say"],
                    autocomplete: true,
                    key: :say
                  },
                  %Segment{
                    match_strings: ["to"],
                    key: :to,
                    must_follow: %Dependencies{any: [:say, :switch]},
                    cannot_follow: %Dependencies{any: [:at]}
                  },
                  %Segment{
                    must_follow: %Dependencies{any: [:say, :switch]},
                    cannot_follow: %Dependencies{any: [:to]},
                    search: [Search.characters()],
                    prefix: "@",
                    key: :at
                  },
                  %Segment{
                    must_follow: %Dependencies{any: [:to]},
                    search: [Search.characters()],
                    key: :character
                  },
                  %Segment{
                    must_follow: %Dependencies{any: [:say, :at, :character]},
                    match_strings: ["slowly"],
                    prefix: "/",
                    key: :switch,
                    max_allowed: 2
                  },
                  %Segment{
                    must_follow: %Dependencies{any: [:character, :say, :switch, :at]},
                    autocomplete: false,
                    key: :words,
                    max_allowed: :infinite
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
                    autocomplete: true,
                    search: [],
                    key: :move
                  },
                  %Segment{
                    must_follow: %Dependencies{any: [:move]},
                    match_strings: [],
                    autocomplete: true,
                    search: [:exits],
                    key: :exit,
                    max_allowed: :infinite
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
                    autocomplete: true,
                    search: [],
                    key: :move
                  }
                ]
              }
            ])

  def autocomplete(character_id, search_string) do
    Enum.flat_map(@commands, fn command ->
      # IO.inspect(command, label: "command")
      # IO.inspect(search_string, label: "search_string")
      match_strings = List.first(command.segments).match_strings
      # IO.inspect(match_strings, label: "match strings")

      if search_string == "" do
        match_strings
      else
        split_string = String.split(search_string)

        # matches =
        #   Enum.filter(match_strings, fn string ->
        #     # IO.inspect(string, label: "filter")
        #     String.starts_with?(string, input)
        #   end)

        # IO.inspect(matches, label: "matches")

        # IO.inspect(built_command, label: "built_command")
        # segment = List.last(built_command.segments)
        # IO.inspect(segment, label: "last segment")
        # key = segment.key
        # IO.inspect(key, label: "segment key")

        # matches =
        Command.string_to_matching_combinations(search_string)
        |> Enum.uniq()
        |> Enum.filter(fn combination ->
          # IO.inspect(combination, label: "combination")

          if length(split_string) < length(combination) do
            sgmt = Enum.at(combination, length(split_string) - 1)
            # IO.inspect(sgmt, label: "sgmt")
            # TODO allow segments with searches through as well
            # or not Enum.empty?(sgmt.search)
            not Enum.empty?(sgmt.input)
          else
            false
          end
        end)
        # |> IO.inspect(label: "between")
        |> Enum.flat_map(fn combination ->
          if length(combination) > length(split_string) do
            segment = Enum.at(combination, length(split_string))

            searches = Enum.filter(segment.match_strings, &is_atom/1)
            # perform searches here

            segment.match_strings ++
              Search.autocomplete(searches, search_string, character_id)
          else
            []
          end
        end)
      end
    end)

    # |> Enum.filter(fn result ->
    #   result != {:error, :no_match}
    # end)
  end

  @doc """
  Given a string as input, try to find a 
  """
  @spec find_command(String.t()) :: {:ok, Command.t()} | {:error, :no_match}
  def find_command(input) do
    case Enum.find(@commands, fn command ->
           Enum.any?(command.segments, fn segment ->
             Enum.any?(segment.match_strings, fn string -> string == input end)
           end)
         end) do
      command = %Command{} ->
        {:ok, command}

      nil ->
        {:error, :no_match}
    end
  end
end
