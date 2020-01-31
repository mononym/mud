defmodule Mud.Engine.Input do
  @doc """
  Proccess an input string for a Character.

  The high level process is:
    - Find longest matches in verb list
    - Filter by who can parse entire input
    - Filter by priority
    - Execute what's left or raise MultiMatch/NoMatch error
      - Execute input or raise MultiMatch error, such as "kick which ball?"
  """
  def process(player, character, input) do
    [verb, arg_string] =
      case String.split(input, " ", parts: 2, trim: true) do
        [verb, arg_string] ->
          [String.downcase(verb), arg_string]

        [verb] ->
          [String.downcase(verb), ""]
      end

    context = %Mud.Engine.Command.ExecutionContext{
      character_id: character,
      player_id: player,
      raw_input: input,
      raw_args: arg_string,
      raw_verb: verb
    }

    verb
    |> find_all_matching_verbs()
    |> filter_by_parsing_arg_string(arg_string)
    |> IO.inspect()
    |> filter_by_priority()
    |> execute(context)
    |> send_messages()
  end

  defp find_all_matching_verbs(input) do
    verbs =
      Mud.Engine.Verbs.match_verbs(input)
      |> IO.inspect()

    Enum.find(verbs, verbs, fn {verb, _callback} ->
      IO.inspect({verb, input})
      verb === input
    end)
    |> List.wrap()
    |> IO.inspect()
  end

  defp filter_by_parsing_arg_string(verbs, arg_string) do
    Enum.filter(verbs, fn {_verb, callback} ->
      case callback.parse_arg_string(arg_string) do
        {:ok, _} ->
          true

        {:error, _} ->
          false
      end
    end)
  end

  defp filter_by_priority(verbs) do
    groups =
      verbs
      |> Enum.group_by(fn {_verb, callback} ->
        callback.type
      end)
      |> Enum.sort(fn {type1, _}, {type2, _} ->
        case {type1, type2} do
          {"basic", "combat"} ->
            false

          _ ->
            true
        end
      end)

    case length(groups) do
      0 ->
        groups

      _ ->
        groups
        |> List.first()
        |> elem(1)
    end
  end

  defp execute([{matched_verb, callback_module}], context) do
    context = %{context | callback_module: callback_module, matched_verb: matched_verb}

    {:ok, args} = callback_module.parse_arg_string(context.raw_args)
    context = %{context | args: args}

    {:ok, context} =
      Mud.Repo.transaction(fn ->
        callback_module.execute(context)
      end)

    context
  end

  defp execute([], context) do
    execute([{"", Mud.Engine.Command.NoVerbMatchError}], context)
  end

  defp execute(matched_verbs, context) do
    matched_verbs = Enum.map(matched_verbs, fn {verb, _} -> verb end) |> Enum.join(", ")

    execute([{matched_verbs, Mud.Engine.Command.MultipleVerbMatchError}], context)
  end

  defp send_messages(context) do
    Enum.each(context.messages, fn message ->
      case message do
        %Mud.Engine.InputMessage{} = m ->
          Mud.Engine.send_message_as_character_input(m)

        %Mud.Engine.OutputMessage{} = m ->
          Mud.Engine.send_message_as_character_output(m)
      end
    end)
  end
end
