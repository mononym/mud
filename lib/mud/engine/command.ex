defmodule Mud.Engine.Command do
  @enforce_keys [:raw_input]
  defstruct verb: nil,
            adverbs: [],
            prepositional_phrases: [],
            raw_input: nil

  # Command anatomy: <verb> <adverbs> <target> <prepositional phrases> <args>

  def process_input(input) do
    # At this point there should be no switches/special characters in the string
    # The known prepositions are the keywords by which the string should be split.
    # Everything between these points belongs to one of those keywords as it's assumed
    # to be part of a prepositional phrase.

    trimmed_input = String.trim(input)
    split_string = String.split(trimmed_input, " ", parts: 2, trim: true)
    raw_verb = List.first(split_string)
    possible_matches = Mud.Engine.Verbs.find_matches()
    commands = construct_commands(possible_matches, List.pop_at(split_string, 1))
    {commands, input} = extract_adverbs(commands, List.pop_at(split_string, 1))
    # commands = build_prepositional_phrases(commands, input)
  end

  defp construct_commands(verbs, input) do
    Enum.map(verbs, fn verb ->
      %__MODULE__{verb: verb, raw_input: input}
    end)
  end

  defp build_verb_phrases(commands, input) do
    Enum.map(commands, fn command ->
      new_phrase = %__MODULE__{raw_input: input}
      # populated_phrase = process_verb_phrase(command.verb, new_phrase)

      %{command | verb_phrase: new_phrase}
    end)
  end

  defp extract_adverbs(commands, input) do
    Enum.map(commands, fn command ->
      verb = command.verb
      known_adverbs = verb.known_adverbs
    end)

    # get verb from command
    # get adverb info from verb
    # if any adverbs match they are extracted from string and stored in order in command
    # new command and updated input returned
    #
    #
  end

  # String.trim() above took care of the beginning/end of the whole string. This will take care of the stuff between
  defp split_verb_from_input(input), do: String.split(input, " ", parts: 2, trim: true)

  defp construct_verb_phrases(split_input) do
    split_input
    |> List.first()
    |> Mud.Engine.Verbs.find_matches()
  end

  defp match_raw_verb_against_verb_list(split_input) do
    split_input
    |> List.first()
    |> Mud.Engine.Verbs.find_matches()
  end

  defp build_verb_struct() do
  end
end
