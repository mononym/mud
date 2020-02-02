defmodule Mud.Engine.Verbs do
  @moduledoc """
  Work with the Verbs known to the engine.
  """

  alias Mud.Engine.Command

  @verbs %{
    "ask" => Command.Placeholder,
    "bark" => Command.Placeholder,
    "climb" => Command.Placeholder,
    "dance" => Command.Placeholder,
    "e" => Command.Move,
    "east" => Command.Move,
    "go" => Command.Move,
    "hide" => Command.Placeholder,
    {:exact, "history"} => Command.History,
    "jump" => Command.Placeholder,
    "laugh" => Command.Placeholder,
    "l" => Command.Look,
    "look" => Command.Look,
    "meow" => Command.Placeholder,
    "move" => Command.Move,
    "n" => Command.Move,
    "north" => Command.Move,
    "northeast" => Command.Move,
    "northwest" => Command.Move,
    "nw" => Command.Move,
    "ne" => Command.Move,
    "out" => Command.Move,
    "park" => Command.Placeholder,
    "peek" => Command.Placeholder,
    {:exact, "quit"} => Command.Quit,
    "run" => Command.Placeholder,
    "search" => Command.Placeholder,
    "shove" => Command.Placeholder,
    "slap" => Command.Placeholder,
    "sleep" => Command.Placeholder,
    "slide" => Command.Placeholder,
    "slip" => Command.Placeholder,
    "smile" => Command.Placeholder,
    "smirk" => Command.Placeholder,
    "snicker" => Command.Placeholder,
    "snipe" => Command.Placeholder,
    "snore" => Command.Placeholder,
    "steal" => Command.Placeholder,
    "strip" => Command.Placeholder,
    "s" => Command.Move,
    "south" => Command.Move,
    "sw" => Command.Move,
    "southwest" => Command.Move,
    "se" => Command.Move,
    "southeast" => Command.Move,
    "swing" => Command.Placeholder,
    "swipe" => Command.Placeholder,
    "tap" => Command.Placeholder,
    "tie" => Command.Placeholder,
    "tip" => Command.Placeholder,
    "trip" => Command.Placeholder,
    "twirl" => Command.Placeholder,
    "walk" => Command.Placeholder,
    "waltz" => Command.Placeholder,
    "wake" => Command.Placeholder,
    "w" => Command.Move,
    "west" => Command.Move
  }

  @doc """
  Given a verb, or partial verb, as input return a list of possible matches and their callbacks.
  """
  @spec match_verbs(String.t()) :: [{String.t(), module}]
  def match_verbs(input) do
    Enum.filter(@verbs, fn
      {{:exact, verb}, _callback} ->
        input == verb

      {verb, _callback} ->
        String.starts_with?(verb, input)
    end)
    |> Enum.map(fn
      {{_, verb}, callback} -> {verb, callback}
      good_tuple -> good_tuple
    end)
  end
end
