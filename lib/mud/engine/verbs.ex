defmodule Mud.Engine.Verbs do
  @moduledoc """
  Work with the Verbs known to the engine.
  """

  alias Mud.Engine.Command
  alias Mud.Engine.Verb
  alias Mud.Engine.Adverbs
  alias Mud.Engine.Adverb

  @verbs MapSet.new([
           %Verb{
             verb: "ask",
             callback_module: Command.Placeholder,
             known_adverbs: [
               Adverb.quietly(),
               Adverb.quickly(),
               Adverb.softly(),
               Adverb.tenderly(),
               Adverb.lovingly(),
               Adverb.sternly(),
               Adverb.giddy()
             ],
             max_adverbs: 0,
             allowed_adverb_combinations: []
             },
           %Verb{
             verb: "bark",
             callback_module: Command.Placeholder,
             known_adverbs: [Adverb.loudly(), Adverb.softly()], max_adverbs: 0, allowed_adverb_combinations: []
             },
           %Verb{
             verb: "climb",
             callback_module: Command.Placeholder,
             known_adverbs: [Adverb.carefully(), Adverb.quickly(), Adverb.slowly()], max_adverbs: 0, allowed_adverb_combinations: []
             },
           %Verb{verb: "dance", callback_module: Command.Placeholder, known_adverbs: [], max_adverbs: 0, allowed_adverb_combinations: []
           },
           %Verb{verb: "e", callback_module: Command.Move, known_adverbs: [], max_adverbs: 0, allowed_adverb_combinations: []
           },
           %Verb{verb: "east", callback_module: Command.Move, known_adverbs: [Adverb.quickly()], max_adverbs: 0, allowed_adverb_combinations: []
           },
           %Verb{verb: "go", callback_module: Command.Move, known_adverbs: [], max_adverbs: 0, allowed_adverb_combinations: []
           },
           %Verb{
             verb: "hide",
             callback_module: Command.Placeholder,
             known_adverbs: [Adverb.carefully(), Adverb.quickly(), Adverb.quietly()], max_adverbs: 0, allowed_adverb_combinations: []
             },
           %Verb{
             verb: "history",
             callback_module: Command.History,
             requires_exact_match: true,
             known_adverbs: [], max_adverbs: 0, allowed_adverb_combinations: []
             },
           %Verb{verb: "jump", callback_module: Command.Placeholder, known_adverbs: [], max_adverbs: 0, allowed_adverb_combinations: []},
           %Verb{verb: "laugh", callback_module: Command.Placeholder, known_adverbs: [], max_adverbs: 0, allowed_adverb_combinations: []},
           %Verb{verb: "l", callback_module: Command.Look, known_adverbs: [], max_adverbs: 0, allowed_adverb_combinations: []},
           %Verb{verb: "look", callback_module: Command.Look, known_adverbs: [], max_adverbs: 0, allowed_adverb_combinations: []},
           %Verb{verb: "meow", callback_module: Command.Placeholder, known_adverbs: [], max_adverbs: 0, allowed_adverb_combinations: []},
           %Verb{verb: "move", callback_module: Command.Move, known_adverbs: [], max_adverbs: 0, allowed_adverb_combinations: []},
           %Verb{verb: "n", callback_module: Command.Move, known_adverbs: [], max_adverbs: 0, allowed_adverb_combinations: []},
           %Verb{verb: "north", callback_module: Command.Move, known_adverbs: [[]], max_adverbs: 0, allowed_adverb_combinations: []},
           %Verb{verb: "northeast", callback_module: Command.Move, known_adverbs: [], max_adverbs: 0, allowed_adverb_combinations: []},
           %Verb{verb: "northwest", callback_module: Command.Move, known_adverbs: [], max_adverbs: 0, allowed_adverb_combinations: []},
           %Verb{verb: "nw", callback_module: Command.Move, known_adverbs: [], max_adverbs: 0, allowed_adverb_combinations: []},
           %Verb{verb: "ne", callback_module: Command.Move, known_adverbs: [], max_adverbs: 0, allowed_adverb_combinations: []},
           %Verb{verb: "out", callback_module: Command.Move, known_adverbs: [], max_adverbs: 0, allowed_adverb_combinations: []},
           %Verb{verb: "park", callback_module: Command.Placeholder, known_adverbs: [], max_adverbs: 0, allowed_adverb_combinations: []},
           %Verb{verb: "peek", callback_module: Command.Placeholder, known_adverbs: [], max_adverbs: 0, allowed_adverb_combinations: []},
           %Verb{
             verb: "quit",
             callback_module: Command.Quit,
             requires_exact_match: true,
             known_adverbs: [],
             max_adverbs: 0,
             allowed_adverb_combinations: []
             },
           %Verb{verb: "run", callback_module: Command.Placeholder, known_adverbs: [], max_adverbs: 0, allowed_adverb_combinations: []},
           %Verb{verb: "search", callback_module: Command.Placeholder, known_adverbs: [], max_adverbs: 0, allowed_adverb_combinations: []},
           %Verb{verb: "shove", callback_module: Command.Placeholder, known_adverbs: [], max_adverbs: 0, allowed_adverb_combinations: []},
           %Verb{verb: "slap", callback_module: Command.Placeholder, known_adverbs: [], max_adverbs: 0, allowed_adverb_combinations: []},
           %Verb{verb: "sleep", callback_module: Command.Placeholder, known_adverbs: [], max_adverbs: 0, allowed_adverb_combinations: []},
           %Verb{verb: "slide", callback_module: Command.Placeholder, known_adverbs: [], max_adverbs: 0, allowed_adverb_combinations: []},
           %Verb{verb: "slip", callback_module: Command.Placeholder, known_adverbs: [], max_adverbs: 0, allowed_adverb_combinations: []},
           %Verb{verb: "smile", callback_module: Command.Placeholder, known_adverbs: [], max_adverbs: 0, allowed_adverb_combinations: []},
           %Verb{verb: "smirk", callback_module: Command.Placeholder, known_adverbs: [], max_adverbs: 0, allowed_adverb_combinations: []},
           %Verb{verb: "snicker", callback_module: Command.Placeholder, known_adverbs: [], max_adverbs: 0, allowed_adverb_combinations: []},
           %Verb{verb: "snipe", callback_module: Command.Placeholder, known_adverbs: [], max_adverbs: 0, allowed_adverb_combinations: []},
           %Verb{verb: "snore", callback_module: Command.Placeholder, known_adverbs: [], max_adverbs: 0, allowed_adverb_combinations: []},
           %Verb{verb: "steal", callback_module: Command.Placeholder, known_adverbs: [], max_adverbs: 0, allowed_adverb_combinations: []},
           %Verb{verb: "strip", callback_module: Command.Placeholder, known_adverbs: [], max_adverbs: 0, allowed_adverb_combinations: []},
           %Verb{verb: "s", callback_module: Command.Move, known_adverbs: [], max_adverbs: 0, allowed_adverb_combinations: []},
           %Verb{verb: "south", callback_module: Command.Move, known_adverbs: [], max_adverbs: 0, allowed_adverb_combinations: []},
           %Verb{verb: "sw", callback_module: Command.Move, known_adverbs: [], max_adverbs: 0, allowed_adverb_combinations: []},
           %Verb{verb: "southwest", callback_module: Command.Move, known_adverbs: [], max_adverbs: 0, allowed_adverb_combinations: []},
           %Verb{verb: "se", callback_module: Command.Move, known_adverbs: [], max_adverbs: 0, allowed_adverb_combinations: []},
           %Verb{verb: "southeast", callback_module: Command.Move, known_adverbs: [], max_adverbs: 0, allowed_adverb_combinations: []},
           %Verb{verb: "swing", callback_module: Command.Placeholder, known_adverbs: [], max_adverbs: 0, allowed_adverb_combinations: []},
           %Verb{verb: "swipe", callback_module: Command.Placeholder, known_adverbs: [], max_adverbs: 0, allowed_adverb_combinations: []},
           %Verb{verb: "tap", callback_module: Command.Placeholder, known_adverbs: [], max_adverbs: 0, allowed_adverb_combinations: []},
           %Verb{verb: "tie", callback_module: Command.Placeholder, known_adverbs: [], max_adverbs: 0, allowed_adverb_combinations: []},
           %Verb{verb: "tip", callback_module: Command.Placeholder, known_adverbs: [], max_adverbs: 0, allowed_adverb_combinations: []},
           %Verb{verb: "trip", callback_module: Command.Placeholder, known_adverbs: [], max_adverbs: 0, allowed_adverb_combinations: []},
           %Verb{verb: "twirl", callback_module: Command.Placeholder, known_adverbs: [], max_adverbs: 0, allowed_adverb_combinations: []},
           %Verb{verb: "walk", callback_module: Command.Placeholder, known_adverbs: [], max_adverbs: 0, allowed_adverb_combinations: []},
           %Verb{verb: "waltz", callback_module: Command.Placeholder, known_adverbs: [], max_adverbs: 0, allowed_adverb_combinations: []},
           %Verb{verb: "wake", callback_module: Command.Placeholder, known_adverbs: [], max_adverbs: 0, allowed_adverb_combinations: []},
           %Verb{verb: "w", callback_module: Command.Move, known_adverbs: [], max_adverbs: 0, allowed_adverb_combinations: []},
           %Verb{verb: "west", callback_module: Command.Move, known_adverbs: [], max_adverbs: 0, allowed_adverb_combinations: []}
         ])

  @doc """
  Given a verb, or partial verb, as input return a list of possible matches and their callbacks.
  """
  @spec find_matches(String.t()) :: [{String.t(), module, max_adverbs: 0, allowed_adverb_combinations: []}]
  def find_matches(input) do
    input
    |> find_verbs()
    |> maybe_choose_exact_match(input)
    |> populate_verbs(input)
  end

  defp populate_verbs(verbs, input) do
    Enum.map(verbs, fn verb ->
      %{verb | raw_input: input, max_adverbs: 0, allowed_adverb_combinations: []}
    end)
  end

  defp find_verbs(input) do
    Enum.filter(@verbs, fn
      %Verb{requires_exact_match: true, verb: verb, max_adverbs: 0, allowed_adverb_combinations: []} ->
        input == verb

      %Verb{verb: verb, max_adverbs: 0, allowed_adverb_combinations: []} ->
        String.starts_with?(verb, input)
    end)
  end

  defp maybe_choose_exact_match(verbs, input) do
    case Enum.find_value(enumerable, nil, fun) do
      verb ->#= %Verb{max_adverbs: 0, allowed_adverb_combinations: []} ->
        [verb]

      nil ->
        verbs
    end
  end
end
