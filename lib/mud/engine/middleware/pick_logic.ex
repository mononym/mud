defmodule Mud.Engine.Middleware.PickLogic do
  @behaviour Mud.Engine.Middleware

  @impl true
  def execute(%Mud.Engine.Command.ExecutionContext{} = context) do
    case find_all_matching_verbs(context.raw_verb) do
      [] ->
        %{context | callback_module: Mud.Engine.Command.NoVerbMatchError}

      matched_verbs ->
        case find_exact_match(context.raw_verb, matched_verbs) do
          nil ->
            matched_verbs
            |> filter_by_parsing_arg_string(context.raw_argument_string)
            |> filter_by_priority()
            |> maybe_has_match_error()
            |> update_context(context)

          {verb, callback_module} ->
            %{context | callback_module: callback_module, matched_verb: verb}
        end
    end
  end

  defp update_context({verb, callback_module}, context) do
    %{context | callback_module: callback_module, matched_verb: verb}
  end

  defp maybe_has_match_error(matched_verbs) do
    case length(matched_verbs) do
      0 ->
        {"", Mud.Engine.Command.NoVerbMatchError}

      1 ->
        List.first(matched_verbs)

      _ ->
        matched_verbs = Stream.map(matched_verbs, &elem(&1, 0)) |> Enum.join(", ")

        {matched_verbs, Mud.Engine.Command.MultipleVerbMatchError}
    end
  end

  defp find_all_matching_verbs(input) do
    verbs = Mud.Engine.Verbs.match_verbs(input)

    Enum.find(verbs, verbs, fn {verb, _callback} ->
      verb === input
    end)
    |> List.wrap()
  end

  defp find_exact_match(raw_verb, matched_verbs) do
    Enum.find(matched_verbs, matched_verbs, fn {verb, _callback} ->
      raw_verb === verb
    end)
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
end
