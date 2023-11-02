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

  ##
  # Private Functions
  ##

  defp list_all_command_definitions do
    MapSet.new([
      define_balance_command(),
      define_buy_command(),
      define_close_command(),
      define_crouch_command(),
      define_deposit_command(),
      define_drop_command(),
      define_get_command(),
      # define_kick_command(),
      define_kneel_command(),
      define_lie_command(),
      # define_lock_command(),
      define_help_command(),
      define_look_command(),
      define_move_command(),
      define_open_command(),
      define_put_command(),
      define_quit_command(),
      define_remove_command(),
      define_say_command(),
      define_sit_command(),
      define_shop_command(),
      define_stand_command(),
      define_store_command(),
      define_stow_command(),
      # define_swap_command(),
      # define_travel_command(),
      # define_unlock_command(),
      define_verb_command(),
      define_wealth_command(),
      define_wear_command(),
      define_withdraw_command()
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

  defp define_crouch_command do
    %Definition{
      callback_module: Command.Crouch,
      parts: [
        %Part{
          matches: ["crouch"],
          key: :crouch,
          transformer: &Enum.join/1
        },
        %Part{
          follows: [:crouch],
          matches: ["on"],
          key: :thing_where,
          transformer: &Enum.join/1
        },
        %Part{
          follows: [:thing_where, :crouch],
          matches: [~r/.*/],
          key: :thing,
          transformer: &join_with_space_downcase/1
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
          follows: [:kneel],
          matches: ["on"],
          key: :thing_where,
          transformer: &Enum.join/1
        },
        %Part{
          follows: [:thing_where, :kneel],
          matches: [~r/.*/],
          key: :thing,
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
          follows: [:open],
          matches: ["my"],
          key: :thing_personal,
          greedy: true,
          transformer: &List.first/1
        },
        %Part{
          follows: [:open, :thing_personal],
          matches: [~r/^\d$/],
          key: :thing_which,
          transformer: &string_to_int/1
        },
        %Part{
          follows: [:thing_which, :open, :thing_personal],
          matches: [~r/.*/],
          key: :thing,
          greedy: true,
          transformer: &join_with_space_downcase/1
        },
        %Part{
          follows: [:thing],
          matches: ["in"],
          key: :thing_where,
          greedy: true,
          transformer: &List.first/1
        },
        %Part{
          follows: [:place],
          matches: ["in"],
          key: :place_where,
          greedy: true,
          transformer: &List.first/1
        },
        %Part{
          follows: [:place_where, :thing_where],
          matches: ["my"],
          key: :place_personal,
          greedy: true,
          transformer: &List.first/1
        },
        %Part{
          follows: [:place_personal, :place_where, :thing_where],
          matches: [~r/^\d$/],
          key: :place_which,
          transformer: &string_to_int/1
        },
        %Part{
          follows: [:place_which, :place_where, :place_personal, :thing_where],
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
          follows: [:close],
          matches: ["my"],
          key: :thing_personal,
          greedy: true,
          transformer: &List.first/1
        },
        %Part{
          follows: [:close, :thing_personal],
          matches: [~r/^\d$/],
          key: :thing_which,
          transformer: &string_to_int/1
        },
        %Part{
          follows: [:thing_which, :close, :thing_personal],
          matches: [~r/.*/],
          key: :thing,
          greedy: true,
          transformer: &join_with_space_downcase/1
        },
        %Part{
          follows: [:thing],
          matches: ["in"],
          key: :thing_where,
          greedy: true,
          transformer: &List.first/1
        },
        %Part{
          follows: [:place],
          matches: ["in"],
          key: :place_where,
          greedy: true,
          transformer: &List.first/1
        },
        %Part{
          follows: [:place_where],
          matches: ["my"],
          key: :place_personal,
          greedy: true,
          transformer: &List.first/1
        },
        %Part{
          follows: [:place_personal, :place_where, :thing_where],
          matches: [~r/^\d$/],
          key: :place_which,
          transformer: &string_to_int/1
        },
        %Part{
          follows: [:place_which, :place_where, :place_personal],
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
          follows: [:get],
          matches: ["my"],
          key: :thing_personal,
          greedy: true,
          transformer: &List.first/1
        },
        %Part{
          follows: [:get, :thing_personal],
          matches: [~r/^\d$/],
          key: :thing_which,
          transformer: &string_to_int/1
        },
        %Part{
          follows: [:thing_which, :get, :thing_personal],
          matches: [~r/.*/],
          key: :thing,
          greedy: true,
          transformer: &join_with_space_downcase/1
        },
        %Part{
          follows: [:thing],
          matches: ["in", "on"],
          key: :thing_where,
          greedy: true,
          transformer: &List.first/1
        },
        %Part{
          follows: [:place],
          matches: ["in", "on"],
          key: :place_where,
          greedy: true,
          transformer: &List.first/1
        },
        %Part{
          follows: [:place_where, :thing_where],
          matches: ["my"],
          key: :place_personal,
          greedy: true,
          transformer: &List.first/1
        },
        %Part{
          follows: [:place_personal, :place_where, :thing_where],
          matches: [~r/^\d$/],
          key: :place_which,
          transformer: &string_to_int/1
        },
        %Part{
          follows: [:place_which, :place_where, :place_personal, :thing_where],
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
          follows: [:put],
          matches: ["my"],
          key: :thing_personal,
          greedy: true,
          transformer: &List.first/1
        },
        %Part{
          follows: [:put, :thing_where, :thing_personal],
          matches: [~r/^\d$/],
          key: :thing_which,
          transformer: &string_to_int/1
        },
        %Part{
          follows: [:thing_which, :put, :thing_personal],
          matches: [~r/.*/],
          key: :thing,
          greedy: true,
          transformer: &join_with_space_downcase/1
        },
        %Part{
          follows: [:thing],
          matches: ["in", "on"],
          key: :thing_where,
          greedy: true,
          transformer: &List.first/1
        },
        %Part{
          follows: [:place],
          matches: ["in", "on"],
          key: :place_where,
          greedy: true,
          transformer: &List.first/1
        },
        %Part{
          follows: [:place_where, :thing_where],
          matches: ["my"],
          key: :place_personal,
          greedy: true,
          transformer: &List.first/1
        },
        %Part{
          follows: [:place_personal, :place_where, :thing_where],
          matches: [~r/^\d$/],
          key: :place_which,
          transformer: &string_to_int/1
        },
        %Part{
          follows: [:place_which, :place_where, :place_personal, :thing_where],
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
          follows: [:wear],
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
          follows: [:drop],
          matches: [~r/.*/],
          key: :thing,
          greedy: true,
          transformer: &join_with_space_downcase/1
        }
      ]
    }
  end

  # defp define_travel_command do
  #   %Definition{
  #     callback_module: Command.Travel,
  #     parts: [
  #       %Part{
  #         matches: ["travel"],
  #         key: :travel,
  #         transformer: &Enum.join/1
  #       },
  #       %Part{
  #         follows: [:travel],
  #         matches: [~r/.*/],
  #         key: :thing,
  #         greedy: true,
  #         transformer: &join_with_space_downcase/1
  #       }
  #     ]
  #   }
  # end

  # defp define_swap_command do
  #   %Definition{
  #     callback_module: Command.Swap,
  #     parts: [
  #       %Part{
  #         matches: ["swap"],
  #         key: :swap,
  #         transformer: &Enum.join/1
  #       }
  #     ]
  #   }
  # end

  # defp define_lock_command do
  #   %Definition{
  #     callback_module: Command.Lock,
  #     parts: [
  #       %Part{
  #         matches: ["lock"],
  #         key: :lock,
  #         transformer: &Enum.join/1
  #       },
  #       %Part{
  #         follows: [:lock],
  #         matches: [~r/.*/],
  #         key: :target,
  #         greedy: true,
  #         transformer: &join_with_space_downcase/1
  #       }
  #     ]
  #   }
  # end

  # defp define_unlock_command do
  #   %Definition{
  #     callback_module: Command.Unlock,
  #     parts: [
  #       %Part{
  #         matches: ["unlock"],
  #         key: :unlock,
  #         transformer: &Enum.join/1
  #       },
  #       %Part{
  #         follows: [:unlock],
  #         matches: [~r/.*/],
  #         key: :target,
  #         greedy: true,
  #         transformer: &join_with_space_downcase/1
  #       }
  #     ]
  #   }
  # end

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
          follows: [:store],
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
          follows: [:thing],
          matches: ["in"],
          key: :path,
          transformer: &Enum.join/1
        },
        %Part{
          follows: [:path, :thing],
          matches: [~r/^\d$/],
          key: :place_which,
          transformer: &string_to_int/1
        },
        %Part{
          follows: [:path, :thing, :place_which],
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
          follows: [:stow],
          matches: ["my"],
          key: :thing_personal,
          greedy: true,
          transformer: &List.first/1
        },
        %Part{
          follows: [:stow, :thing_personal],
          matches: [~r/^\d$/],
          key: :thing_which,
          transformer: &string_to_int/1
        },
        %Part{
          follows: [:thing_which, :stow, :thing_personal],
          matches: [~r/.*/],
          key: :thing,
          greedy: true,
          transformer: &join_with_space_downcase/1
        },
        %Part{
          follows: [:thing],
          matches: ["in", "on"],
          key: :thing_where,
          greedy: true,
          transformer: &List.first/1
        },
        %Part{
          follows: [:place],
          matches: ["in", "on"],
          key: :place_where,
          greedy: true,
          transformer: &List.first/1
        },
        %Part{
          follows: [:place, :thing],
          matches: ["into"],
          key: :place_switch,
          greedy: true,
          transformer: &List.first/1
        },
        %Part{
          follows: [:place_where, :thing_where, :place_switch],
          matches: ["my"],
          key: :place_personal,
          greedy: true,
          transformer: &List.first/1
        },
        %Part{
          follows: [:place_personal, :place_where, :thing_where, :place_switch],
          matches: [~r/^\d$/],
          key: :place_which,
          transformer: &string_to_int/1
        },
        %Part{
          follows: [:place_which, :place_where, :place_personal, :thing_where, :place_switch],
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
          follows: [:remove],
          matches: [~r/.*/],
          key: :thing,
          transformer: &join_with_space_downcase/1
        }
      ]
    }
  end

  defp define_balance_command do
    %Definition{
      callback_module: Command.Balance,
      parts: [
        %Part{
          matches: ["balance"],
          key: :balance,
          transformer: &Enum.join/1
        }
      ]
    }
  end

  defp define_help_command do
    %Definition{
      callback_module: Command.Help,
      parts: [
        %Part{
          matches: ["help"],
          key: :help,
          transformer: &Enum.join/1
        }
      ]
    }
  end

  defp define_verb_command do
    %Definition{
      callback_module: Command.Verb,
      parts: [
        %Part{
          matches: ["commands", "verb"],
          key: :verb,
          transformer: &Enum.join/1
        },
        %Part{
          follows: [:verb],
          matches: [~r/^\/info/],
          key: :switch,
          greedy: false,
          transformer: &trim_slash/1
        },
        %Part{
          follows: [:switch],
          matches: [~r/.*/],
          key: :target,
          greedy: true,
          transformer: &join_with_space_downcase/1
        }
      ]
    }
  end

  defp define_shop_command do
    %Definition{
      callback_module: Command.Shop,
      parts: [
        %Part{
          matches: ["shop"],
          key: :shop,
          transformer: &Enum.join/1
        }
      ]
    }
  end

  defp define_buy_command do
    %Definition{
      callback_module: Command.Buy,
      parts: [
        %Part{
          matches: ["buy"],
          key: :buy,
          transformer: &Enum.join/1
        },
        %Part{
          key: :product,
          matches: [~r/^\d+$/],
          follows: [:buy],
          transformer: &Enum.join/1
        }
      ]
    }
  end

  defp define_deposit_command do
    %Definition{
      callback_module: Command.Deposit,
      parts: [
        %Part{
          matches: ["deposit"],
          key: :deposit,
          transformer: &Enum.join/1
        },
        %Part{
          key: :amount,
          matches: ["all", ~r/^\d+$/],
          follows: [:deposit],
          transformer: &Enum.join/1
        },
        %Part{
          key: :type,
          matches: [
            "c",
            "co",
            "cop",
            "copp",
            "coppe",
            "copper",
            "g",
            "go",
            "gol",
            "gold",
            "b",
            "br",
            "bro",
            "bron",
            "bronz",
            "bronze",
            "s",
            "si",
            "sil",
            "silv",
            "silve",
            "silver"
          ],
          follows: [:amount],
          transformer: &Enum.join/1
        }
      ]
    }
  end

  defp define_withdraw_command do
    %Definition{
      callback_module: Command.Withdraw,
      parts: [
        %Part{
          matches: ["withdraw"],
          key: :withdraw,
          transformer: &Enum.join/1
        },
        %Part{
          key: :amount,
          matches: ["all", ~r/^\d+$/],
          follows: [:withdraw],
          transformer: &Enum.join/1
        },
        %Part{
          key: :type,
          matches: [
            "c",
            "co",
            "cop",
            "copp",
            "coppe",
            "copper",
            "g",
            "go",
            "gol",
            "gold",
            "b",
            "br",
            "bro",
            "bron",
            "bronz",
            "bronze",
            "s",
            "si",
            "sil",
            "silv",
            "silve",
            "silver"
          ],
          follows: [:amount],
          transformer: &Enum.join/1
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

  # defp define_kick_command do
  #   %Definition{
  #     callback_module: Command.Kick,
  #     parts: [
  #       %Part{
  #         matches: ["kick"],
  #         key: :kick,
  #         transformer: &Enum.join/1
  #       },
  #       %Part{
  #         follows: [:kick],
  #         matches: [~r/.*/],
  #         key: :target,
  #         greedy: true,
  #         transformer: &join_with_space_downcase/1
  #       }
  #     ]
  #   }
  # end

  defp define_lie_command do
    %Definition{
      callback_module: Command.Lie,
      parts: [
        %Part{
          matches: ["lie"],
          key: :lie,
          transformer: &Enum.join/1
        },
        %Part{
          follows: [:lie],
          matches: ["on"],
          key: :thing_where,
          transformer: &Enum.join/1
        },
        %Part{
          follows: [:thing_where, :lie],
          matches: [~r/.*/],
          key: :thing,
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
          follows: [:sit],
          matches: ["on"],
          key: :thing_where,
          transformer: &Enum.join/1
        },
        %Part{
          follows: [:thing_where, :sit],
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
        },
        %Part{
          follows: [:stand],
          matches: ["on"],
          key: :thing_where,
          transformer: &Enum.join/1
        },
        %Part{
          follows: [:thing_where, :stand],
          matches: [~r/.*/],
          key: :thing,
          transformer: &join_with_space_downcase/1
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
          follows: [:move],
          transformer: &string_to_int/1
        },
        %Part{
          follows: [:move, :which],
          matches: [~r/.*/],
          key: :thing,
          transformer: &join_with_space_downcase/1
        }
      ]
    }
  end

  defp define_say_command do
    %Definition{
      callback_module: Command.Say,
      parts: [
        %Part{
          matches: ["say"],
          key: :say,
          transformer: &Enum.join/1
        },
        %Part{
          matches: ["to"],
          key: :to,
          follows: [:say, :switch],
          greedy: false,
          transformer: &Enum.join/1
        },
        %Part{
          follows: [:to],
          matches: [~r/^[a-zA-Z]+/],
          greedy: false,
          key: :to_character,
          transformer: &trim_at/1
        },
        %Part{
          follows: [:say, :switch],
          matches: [~r/^\@[a-zA-Z]+/],
          greedy: false,
          key: :at_character,
          transformer: &trim_at/1
        },
        %Part{
          follows: [:say, :to_character, :at_character],
          matches: [~r/^\/[a-zA-Z]+$/],
          key: :switch,
          greedy: false,
          transformer: &trim_slash/1
        },
        %Part{
          follows: [:to_character, :at_character, :say, :switch],
          matches: [~r/.*/],
          key: :words,
          greedy: true,
          drop_whitespace: false,
          transformer: &join_with_trimmed_ends/1
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
          follows: [:look],
          matches: ["@", "at", "in", "on"],
          key: :thing_switch,
          greedy: true,
          transformer: &List.first/1
        },
        %Part{
          follows: [:thing_where, :look, :thing_switch],
          matches: ["my"],
          key: :thing_personal,
          greedy: true,
          transformer: &List.first/1
        },
        %Part{
          follows: [:look, :thing_where, :thing_personal, :thing_switch],
          matches: [~r/^\d$/],
          key: :thing_which,
          transformer: &string_to_int/1
        },
        %Part{
          follows: [:thing_which, :look, :thing_personal, :thing_where, :thing_switch],
          matches: [~r/.*/],
          key: :thing,
          greedy: true,
          transformer: &join_with_space_downcase/1
        },
        %Part{
          follows: [:thing],
          matches: ["in", "on"],
          key: :thing_where,
          greedy: true,
          transformer: &List.first/1
        },
        %Part{
          follows: [:place],
          matches: ["in", "on"],
          key: :place_where,
          greedy: true,
          transformer: &List.first/1
        },
        %Part{
          follows: [:place_where, :thing_where],
          matches: ["my"],
          key: :place_personal,
          greedy: true,
          transformer: &List.first/1
        },
        %Part{
          follows: [:place_personal, :place_where, :thing_where],
          matches: [~r/^\d$/],
          key: :place_which,
          transformer: &string_to_int/1
        },
        %Part{
          follows: [:place_which, :place_where, :place_personal, :thing_where],
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
    Logger.debug(inspect(input), label: :join_with_space_downcase)
    Enum.join(input, " ") |> String.downcase()
  end

  defp string_to_int([input]) do
    String.to_integer(input)
  end

  defp join_with_trimmed_ends(input) do
    Enum.join(input) |> String.trim()
  end
end
