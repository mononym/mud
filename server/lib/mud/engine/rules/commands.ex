defmodule Mud.Engine.Rules.Commands do
  @moduledoc """
  Work with the Commands known to the engine.
  """

  alias Mud.Engine.{Command}
  alias Mud.Engine.Command.Part
  alias Mud.Engine.Command.Definition
  alias Mud.Engine.Command.Definition.Part
  alias Mud.Engine.Util

  require Logger

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
      define_close_command(),
      define_drop_command(),
      define_get_command(),
      define_kick_command(),
      define_kneel_command(),
      define_lock_command(),
      define_look_command(),
      define_move_command(),
      define_open_command(),
      define_put_command(),
      define_quit_command(),
      define_remove_command(),
      define_say_command(),
      define_sit_command(),
      define_stand_command(),
      define_store_command(),
      define_stow_command(),
      define_swap_command(),
      define_travel_command(),
      define_unlock_command(),
      define_wealth_command(),
      define_wear_command()
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

  defp define_open_command do
    %Definition{
      callback_module: Command.Open,
      parts: [
        %Part{
          matches: ["open"],
          key: :open,
          transformer: &List.first/1
        },
        %Part{
          must_follow: [:open],
          matches: ["my"],
          key: :thing_personal,
          greedy: true,
          transformer: &List.first/1
        },
        %Part{
          must_follow: [:open, :thing_personal],
          matches: [~r/^\d$/],
          key: :thing_which,
          transformer: &string_to_int/1
        },
        %Part{
          must_follow: [:thing_which, :open, :thing_personal],
          matches: [~r/.*/],
          key: :thing,
          greedy: true,
          transformer: &join_with_space_downcase/1
        },
        %Part{
          must_follow: [:thing],
          matches: ["in"],
          key: :thing_where,
          greedy: true,
          transformer: &List.first/1
        },
        %Part{
          must_follow: [:place],
          matches: ["in"],
          key: :place_where,
          greedy: true,
          transformer: &List.first/1
        },
        %Part{
          must_follow: [:place_where, :thing_where],
          matches: ["my"],
          key: :place_personal,
          greedy: true,
          transformer: &List.first/1
        },
        %Part{
          must_follow: [:place_personal, :place_where, :thing_where],
          matches: [~r/^\d$/],
          key: :place_which,
          transformer: &string_to_int/1
        },
        %Part{
          must_follow: [:place_which, :place_where, :place_personal, :thing_where],
          matches: [~r/.*/],
          key: :place,
          greedy: true,
          transformer: &join_with_space_downcase/1
        }
      ]
    }
  end

  defp define_close_command do
    %Definition{
      callback_module: Command.Close,
      parts: [
        %Part{
          matches: ["close"],
          key: :close,
          transformer: &List.first/1
        },
        %Part{
          must_follow: [:close],
          matches: ["my"],
          key: :thing_personal,
          greedy: true,
          transformer: &List.first/1
        },
        %Part{
          must_follow: [:close, :thing_personal],
          matches: [~r/^\d$/],
          key: :thing_which,
          transformer: &string_to_int/1
        },
        %Part{
          must_follow: [:thing_which, :close, :thing_personal],
          matches: [~r/.*/],
          key: :thing,
          greedy: true,
          transformer: &join_with_space_downcase/1
        },
        %Part{
          must_follow: [:thing],
          matches: ["in"],
          key: :thing_where,
          greedy: true,
          transformer: &List.first/1
        },
        %Part{
          must_follow: [:place],
          matches: ["in"],
          key: :place_where,
          greedy: true,
          transformer: &List.first/1
        },
        %Part{
          must_follow: [:place_where],
          matches: ["my"],
          key: :place_personal,
          greedy: true,
          transformer: &List.first/1
        },
        %Part{
          must_follow: [:place_personal, :place_where, :thing_where],
          matches: [~r/^\d$/],
          key: :place_which,
          transformer: &string_to_int/1
        },
        %Part{
          must_follow: [:place_which, :place_where, :place_personal],
          matches: [~r/.*/],
          key: :place,
          greedy: true,
          transformer: &join_with_space_downcase/1
        }
      ]
    }
  end

  defp define_get_command do
    %Definition{
      callback_module: Command.Get,
      parts: [
        %Part{
          matches: ["get"],
          key: :get,
          transformer: &List.first/1
        },
        %Part{
          must_follow: [:get],
          matches: ["my"],
          key: :thing_personal,
          greedy: true,
          transformer: &List.first/1
        },
        %Part{
          must_follow: [:get, :thing_personal],
          matches: [~r/^\d$/],
          key: :thing_which,
          transformer: &string_to_int/1
        },
        %Part{
          must_follow: [:thing_which, :get, :thing_personal],
          matches: [~r/.*/],
          key: :thing,
          greedy: true,
          transformer: &join_with_space_downcase/1
        },
        %Part{
          must_follow: [:place, :thing],
          matches: ["from"],
          key: :place_where,
          greedy: true,
          transformer: &List.first/1
        },
        %Part{
          must_follow: [:place_where],
          matches: ["my"],
          key: :place_personal,
          greedy: true,
          transformer: &List.first/1
        },
        %Part{
          must_follow: [:place_personal, :place_where],
          matches: [~r/^\d$/],
          key: :place_which,
          transformer: &string_to_int/1
        },
        %Part{
          must_follow: [:place_which, :place_where, :place_personal],
          matches: [~r/.*/],
          key: :place,
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
          transformer: &List.first/1
        },
        %Part{
          must_follow: [:put],
          matches: ["my"],
          key: :thing_personal,
          greedy: true,
          transformer: &List.first/1
        },
        %Part{
          must_follow: [:put, :thing_where, :thing_personal],
          matches: [~r/^\d$/],
          key: :thing_number,
          transformer: &string_to_int/1
        },
        %Part{
          must_follow: [:thing_number, :put, :thing_personal],
          matches: [~r/.*/],
          key: :thing,
          greedy: true,
          transformer: &join_with_space_downcase/1
        },
        %Part{
          must_follow: [:place, :thing],
          matches: ["in"],
          key: :place_where,
          greedy: true,
          transformer: &List.first/1
        },
        %Part{
          must_follow: [:place_where],
          matches: ["my"],
          key: :place_personal,
          greedy: true,
          transformer: &List.first/1
        },
        %Part{
          must_follow: [:place_personal, :place_where],
          matches: [~r/^\d$/],
          key: :place_number,
          transformer: &string_to_int/1
        },
        %Part{
          must_follow: [:place_number, :place_where, :place_personal],
          matches: [~r/.*/],
          key: :place,
          greedy: true,
          transformer: &join_with_space_downcase/1
        }
      ]
    }
  end

  defp define_wear_command do
    %Definition{
      callback_module: Command.Wear,
      parts: [
        %Part{
          matches: ["wear"],
          key: :wear,
          transformer: &Enum.join/1
        },
        %Part{
          must_follow: [:wear],
          matches: [~r/.*/],
          key: :thing,
          greedy: true,
          transformer: &join_with_space_downcase/1
        }
      ]
    }
  end

  defp define_drop_command do
    %Definition{
      callback_module: Command.Drop,
      parts: [
        %Part{
          matches: ["drop"],
          key: :drop,
          transformer: &Enum.join/1
        },
        %Part{
          must_follow: [:drop],
          matches: [~r/.*/],
          key: :thing,
          greedy: true,
          transformer: &join_with_space_downcase/1
        }
      ]
    }
  end

  defp define_travel_command do
    %Definition{
      callback_module: Command.Travel,
      parts: [
        %Part{
          matches: ["travel"],
          key: :travel,
          transformer: &Enum.join/1
        },
        %Part{
          must_follow: [:travel],
          matches: [~r/.*/],
          key: :thing,
          greedy: true,
          transformer: &join_with_space_downcase/1
        }
      ]
    }
  end

  defp define_swap_command do
    %Definition{
      callback_module: Command.Swap,
      parts: [
        %Part{
          matches: ["swap"],
          key: :swap,
          transformer: &Enum.join/1
        }
      ]
    }
  end

  defp define_lock_command do
    %Definition{
      callback_module: Command.Lock,
      parts: [
        %Part{
          matches: ["lock"],
          key: :lock,
          transformer: &Enum.join/1
        },
        %Part{
          must_follow: [:lock],
          matches: [~r/.*/],
          key: :target,
          greedy: true,
          transformer: &join_with_space_downcase/1
        }
      ]
    }
  end

  defp define_unlock_command do
    %Definition{
      callback_module: Command.Unlock,
      parts: [
        %Part{
          matches: ["unlock"],
          key: :unlock,
          transformer: &Enum.join/1
        },
        %Part{
          must_follow: [:unlock],
          matches: [~r/.*/],
          key: :target,
          greedy: true,
          transformer: &join_with_space_downcase/1
        }
      ]
    }
  end

  defp define_store_command do
    %Definition{
      callback_module: Command.Store,
      parts: [
        %Part{
          matches: ["store"],
          key: :store,
          transformer: &Enum.join/1
        },
        %Part{
          must_follow: [:store],
          matches: [
            "default",
            "list",
            "clear",
            "weapon",
            "weapons",
            "armor",
            "shield",
            "shields",
            "clothing",
            "clothes",
            "ammunition",
            "ammo",
            "gem",
            "gems"
          ],
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
          must_follow: [:path, :thing],
          matches: [~r/^\d$/],
          key: :place_number,
          transformer: &string_to_int/1
        },
        %Part{
          must_follow: [:path, :thing, :place_number],
          matches: [~r/.*/],
          key: :place,
          transformer: &join_with_space_downcase/1
        }
      ]
    }
  end

  defp define_stow_command do
    %Definition{
      callback_module: Command.Stow,
      parts: [
        %Part{
          matches: ["stow"],
          key: :stow,
          transformer: &List.first/1
        },
        %Part{
          must_follow: [:stow],
          matches: ["my"],
          key: :thing_personal,
          greedy: true,
          transformer: &List.first/1
        },
        %Part{
          must_follow: [:stow, :thing_personal],
          matches: [~r/^\d$/],
          key: :thing_which,
          transformer: &string_to_int/1
        },
        %Part{
          must_follow: [:thing_which, :stow, :thing_personal],
          matches: [~r/.*/],
          key: :thing,
          greedy: true,
          transformer: &join_with_space_downcase/1
        },
        %Part{
          must_follow: [:thing],
          matches: ["from", "in"],
          key: :thing_where,
          greedy: true,
          transformer: &List.first/1
        },
        %Part{
          must_follow: [:place],
          matches: ["from", "in"],
          key: :place_where,
          greedy: true,
          transformer: &List.first/1
        },
        %Part{
          must_follow: [:place_where, :thing_where],
          matches: ["my"],
          key: :place_personal,
          greedy: true,
          transformer: &List.first/1
        },
        %Part{
          must_follow: [:place_personal, :place_where, :thing_where],
          matches: [~r/^\d$/],
          key: :place_which,
          transformer: &string_to_int/1
        },
        %Part{
          must_follow: [:place_which, :place_where, :place_personal, :thing_where],
          matches: [~r/.*/],
          key: :place,
          greedy: true,
          transformer: &join_with_space_downcase/1
        }
      ]
    }
  end

  defp define_remove_command do
    %Definition{
      callback_module: Command.Remove,
      parts: [
        %Part{
          matches: ["remove"],
          key: :remove,
          transformer: &List.first/1
        },
        %Part{
          must_follow: [:remove],
          matches: [~r/.*/],
          key: :thing,
          transformer: &join_with_space_downcase/1
        }
      ]
    }
  end

  defp define_wealth_command do
    %Definition{
      callback_module: Command.Wealth,
      parts: [
        %Part{
          matches: ["wealth"],
          key: :wealth,
          transformer: &Enum.join/1
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
          key: :where,
          transformer: &Enum.join/1
        },
        %Part{
          must_follow: [:where, :sit],
          matches: [~r/.*/],
          key: :thing,
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
          key: :which,
          matches: [~r/^\d$/],
          must_follow: [:move],
          transformer: &string_to_int/1
        },
        %Part{
          must_follow: [:move, :which],
          matches: [~r/.*/],
          key: :thing,
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
          must_follow: [:look],
          matches: ["at", "in"],
          key: :thing_where,
          greedy: true,
          transformer: &List.first/1
        },
        %Part{
          must_follow: [:thing_where, :look],
          matches: ["my"],
          key: :thing_personal,
          greedy: true,
          transformer: &List.first/1
        },
        %Part{
          must_follow: [:look, :thing_where, :thing_personal],
          matches: [~r/^\d$/],
          key: :thing_number,
          transformer: &string_to_int/1
        },
        %Part{
          must_follow: [:thing_number, :look, :thing_personal, :thing_where],
          matches: [~r/.*/],
          key: :thing,
          greedy: true,
          transformer: &join_with_space_downcase/1
        },
        %Part{
          must_follow: [:place, :thing],
          matches: ["in"],
          key: :place_where,
          greedy: true,
          transformer: &List.first/1
        },
        %Part{
          must_follow: [:place_where],
          matches: ["my"],
          key: :place_personal,
          greedy: true,
          transformer: &List.first/1
        },
        %Part{
          must_follow: [:place_personal, :place_where],
          matches: [~r/^\d$/],
          key: :place_number,
          transformer: &string_to_int/1
        },
        %Part{
          must_follow: [:place_number, :place_where, :place_personal],
          matches: [~r/.*/],
          key: :place,
          greedy: true,
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
    Logger.debug(inspect(input))
    Enum.join(input, " ") |> String.downcase()
  end

  defp string_to_int([input]) do
    String.to_integer(input)
  end
end
