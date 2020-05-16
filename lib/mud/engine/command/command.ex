defmodule Mud.Engine.Command do
  defstruct callback_module: nil,
            segments: [],
            raw_input: ""

  alias Mud.Engine.Rules.Commands
  alias Mud.Engine.Command.Segment
  alias Mud.Engine.Command.ExecutionContext
  require Logger

  defmodule State do
    @moduledoc false
    # Used to hold the state during the processing of a string into a Command

    defstruct segments_to_process: [],
              # The list of segments which could potentially be populated as the child to the current root segment
              current_potential_children: [],
              # The remaining input which has yet to be processed
              remaining_input_chunks: [],
              # All of the segments for the command which can be used to help build each layer
              all_potential_segments: [],
              # The current root segment being processed
              current_root_segment: [],
              populated_segments: [],
              raw_input: nil,
              potential_combinations: []
  end

  @doc """
  Given a string such as 'look' or 'move west' turn it into a populated '__MODULE__{}.t()' struct.
  """
  @spec string_to_command(String.t()) ::
          {:error, :no_match | :not_found} | {:ok, Mud.Engine.Command.t()}
  def string_to_command(input) do
    split_input = String.split(input)
    # Populate the initial state for the processing
    state = %State{raw_input: input, remaining_input_chunks: split_input}

    # The command is assumed to be the first distinct set of characters provided.
    # It could be a shortened version of the command such as 'loo' or it could be the entire thing such as 'move west'.
    command_string = List.first(split_input)

    # Attempt to turn the command string into a command object
    case Commands.find_command(command_string) do
      {:ok, command} ->
        Logger.debug("command found")

        # If a Command was found, attempt to build a single set of Segments which accurately describes the structure of
        # the passed-in command string.
        case populate_segments(command, state) do
          # There were either no matches or too many matches, both of which get returned as an empty list
          [] ->
            Logger.debug("could not populate segments")
            {:error, :no_match}

          # A single, hopefully correct, combination was found.
          [matched_combination] ->
            Logger.debug("successfully populated segments: #{inspect(matched_combination)}")

            [last_segment | rest_of_segments] = Enum.reverse(matched_combination)

            segments_tree = build_ast(last_segment, rest_of_segments)

            # Command is returned with the Segment map populated for easy parsing/processing by Command logic.
            {:ok, %{command | raw_input: input, segments: segments_tree}}
        end

      error ->
        Logger.debug("command not found")
        error
    end
  end

  defp build_ast(ast_node, []) do
    ast_node
  end

  defp build_ast(ast_node, [segment | rest_of_segments]) do
    new_ast_node = %{segment | children: Map.put(segment.children, ast_node.key, ast_node)}

    build_ast(new_ast_node, rest_of_segments)
  end

  # Given a Command struct, and an initial state, attempts to build potential matching Segment combinations.
  # This effectively behaves as a lexer/parser
  @spec populate_segments(__MODULE__.t(), __MODULE__.State.t()) :: [__MODULE__.Segment.t()] | []
  defp populate_segments(command, state) do
    potential_combinations =
      enumerate_potential_combinations(command.segments, length(state.remaining_input_chunks))

    Logger.debug("Potential combinations: #{inspect(potential_combinations)}")

    # Reverse everything so lists are in expected order, rather than the efficient order for building lists
    normalized_combinations = normalize_combinations(potential_combinations)
    state = %{state | potential_combinations: normalized_combinations}

    Logger.debug("Normalized combinations: #{inspect(potential_combinations)}")

    match_combinations(state)
  end

  defp match_combinations(state) do
    Enum.reduce(state.potential_combinations, [], fn combination, matches ->
      Logger.debug("Checking potential combination: #{inspect(combination)}")

      case v2(%{state | segments_to_process: combination}) do
        {:ok, combo} ->
          [normalize_combination(combo) | matches]

        {:error, _combo} ->
          matches
      end
    end)
    |> Enum.sort()
    |> Enum.reduce([], fn combo, matching_combinations ->
      max_length =
        Enum.reduce(matching_combinations, 0, fn combination, longest ->
          max(longest, length(combination))
        end)

      cond do
        length(combo) > max_length ->
          [combo]

        length(combo) == max_length ->
          [combo | matching_combinations]

        length(combo) < max_length ->
          matching_combinations
      end
    end)
  end

  # Given the list of segments defined for a command, build the potential combinations the input can be matched against
  defp enumerate_potential_combinations([segment | segments], max_length) do
    potential_children = find_potential_children(segment, segments)
    # The first segment defined should always the command segment, so it will always be the root
    segment
    # Recursively build up the possible combinations for the given segments
    |> build_layer(segments, potential_children, [], max_length)
    |> flatten()
    |> inject_segment(segment)
    |> Enum.sort(fn list1, list2 ->
      length(list1) >= length(list2)
    end)
    |> Enum.uniq()
  end

  defp inject_segment(combinations, segment) do
    [[segment] | combinations]
  end

  defp flatten(combinations, combos \\ [])

  defp flatten(combinations = [%Segment{}], []) do
    [combinations]
  end

  defp flatten([], combos) do
    combos
  end

  defp flatten([[] | combinations], combos) do
    flatten(combinations, combos)
  end

  defp flatten([combination | combinations], combos) do
    if is_list(combination) do
      [combo | rest_of_combo] = combination

      if is_list(combo) do
        flatten([combo | [rest_of_combo | combinations]], combos)
      else
        flatten(combinations, [combination | combos])
      end
    end
  end

  # Don't allow combinations longer than the total number of distinct input words.
  # This will prevent infinite loops while still allowing for complex combinations that would otherwise loop.
  defp build_layer(
         _node,
         _all_potential_children,
         _current_potential_children,
         combination,
         max_length
       )
       when length(combination) >= max_length,
       do: combination

  # Recursively build all possible segment combinations up to a specified max length
  defp build_layer(
         node,
         all_potential_children,
         current_potential_children,
         combination,
         max_length
       ) do
    case length(current_potential_children) do
      # If no children follow the root node, we've reached the end of this particular combination
      0 ->
        [node | combination]

      # Some nodes which can follow the current root node have been found, so all those combinations must be built.
      # This effectively creates a fan-out effect, with the current combination being copied for each of the child
      # combinations.
      _some ->
        Enum.map(current_potential_children, fn child ->
          # The potential children must indicate they follow the next node to be processed.
          current_potential_children = find_potential_children(child, all_potential_children)

          # Recurse.
          build_layer(
            child,
            all_potential_children,
            current_potential_children,
            [node | combination],
            max_length
          )
        end)
    end
  end

  defp find_potential_children(node, all_potential_children) do
    Enum.filter(all_potential_children, fn pc ->
      pc.key != node.key and node.key in pc.must_follow
    end)
  end

  # Combinations is a list of lists. The overall order should be maintained while the combinations themselves should be
  # reversed.
  defp normalize_combinations(combinations) do
    Enum.map(combinations, fn combination ->
      Enum.reverse(combination)
    end)
  end

  defp normalize_combination(combination) do
    Enum.map(combination, fn combo ->
      %{combo | input: Enum.reverse(combo.input)}
    end)
    |> Enum.reverse()
  end

  # TODO: Clean this up. It's embarrassing.
  defp v2(state) do
    Logger.debug("Start of v2")

    with true <- safe_to_process(state),
         [segment | segments] <- state.segments_to_process,
         [input | rest] <- state.remaining_input_chunks,
         {:ok, normalized_input} <- normalize_input_prefix(input, segment),
         true <- input_and_segment_match(normalized_input, segment),
         {:error, :no_match} <- input_and_segment_match(normalized_input, List.first(segments)),
         segment <- update_input(segment, normalized_input) do
      if segment.greedy do
        {:ok,
         %{
           state
           | segments_to_process: [segment | segments],
             remaining_input_chunks: rest
         }}
      else
        {:ok,
         %{
           state
           | populated_segments: [segment | state.populated_segments],
             segments_to_process: segments,
             remaining_input_chunks: rest
         }}
      end

      # end
    else
      {:error, :unsafe_to_process} ->
        cond do
          Enum.empty?(state.segments_to_process) and Enum.empty?(state.remaining_input_chunks) ->
            {:match, state.populated_segments}

          length(state.segments_to_process) > 0 and
            length(List.first(state.segments_to_process).input) > 0 and
              Enum.empty?(state.remaining_input_chunks) ->
            [segment | segments] = state.segments_to_process

            {:ok,
             %{
               state
               | segments_to_process: segments,
                 populated_segments: [segment | state.populated_segments]
             }}

          true ->
            {:error, Enum.reverse(state.segments_to_process) ++ state.populated_segments}
        end

      {:error, :no_match} ->
        [segment | segments] = state.segments_to_process

        if length(segment.input) > 0 do
          {:ok,
           %{
             state
             | segments_to_process: segments,
               populated_segments: [segment | state.populated_segments]
           }}
        else
          {:error, Enum.reverse(state.segments_to_process) ++ state.populated_segments}
        end

      {:error, :invalid_format} ->
        {:error, Enum.reverse(state.segments_to_process) ++ state.populated_segments}

      {:match, new_state} ->
        {:match, new_state.populated_segments}

      # input matches next segment in the sequence.
      true ->
        segment = List.first(state.segments_to_process)

        # The current segment has input, which means we can safely move on and populate the next segment with the input
        if length(segment.input) > 0 do
          [segment | segments] = state.segments_to_process

          {:ok,
           %{
             state
             | populated_segments: [segment | state.populated_segments],
               segments_to_process: segments
           }}
        else
          [segment | segments] = state.segments_to_process
          [input | rest] = state.remaining_input_chunks
          segment = update_input(segment, input)

          if segment.greedy do
            {:ok,
             %{
               state
               | segments_to_process: [segment | segments],
                 remaining_input_chunks: rest
             }}
          else
            {:ok,
             %{
               state
               | populated_segments: [segment | state.populated_segments],
                 segments_to_process: segments,
                 remaining_input_chunks: rest
             }}
          end
        end

      _error ->
        {:error, Enum.reverse(state.segments_to_process) ++ state.populated_segments}
    end
    |> case do
      {:ok, state} ->
        v2(state)

      {:match, populated_segments} ->
        {:ok, populated_segments}

      error ->
        error
    end
  end

  defp update_input(segment, input) do
    input =
      if is_function(segment.transformer) do
        segment.transformer(input)
      else
        input
      end

    %{segment | input: [input | segment.input]}
  end

  # defp update_allowance(segment) do
  #   if segment.max_allowed == :infinite do
  #     segment
  #   else
  #     %{segment | max_allowed: segment.max_allowed - 1}
  #   end
  # end

  defp normalize_input_prefix(input, segment) do
    if segment.prefix != nil do
      if String.starts_with?(input, segment.prefix) do
        {:ok, String.trim_leading(input, segment.prefix)}
      else
        {:error, :no_match}
      end
    else
      {:ok, input}
    end
  end

  defp input_and_segment_match(_input, nil), do: {:error, :no_match}

  defp input_and_segment_match(input, segment) do
    Logger.debug("Checking input (#{input}) against segment: #{inspect(segment)}")

    if any_strings_match?(segment.match_strings, input) do
      Logger.debug("input matched segment")
      true
    else
      Logger.debug("input did not match segment")
      {:error, :no_match}
    end
  end

  defp safe_to_process(state) do
    Logger.debug("Checking if it is safe to process input")

    cond do
      Enum.empty?(state.segments_to_process) and Enum.empty?(state.remaining_input_chunks) ->
        Logger.debug("Both state and remaining input chunks are empty. There is a match.")
        {:match, state}

      not Enum.empty?(state.segments_to_process) and not Enum.empty?(state.remaining_input_chunks) ->
        Logger.debug("No more segments but the input is not empty. Safe to continue processing.")
        true

      true ->
        Logger.debug("Not safe to process.")
        {:error, :unsafe_to_process}
    end
  end

  defp any_strings_match?([], _input) do
    true
  end

  defp any_strings_match?(match_strings, input) do
    Enum.any?(match_strings, fn match_string ->
      if Regex.regex?(match_string) do
        Regex.match?(match_string, input)
      else
        match_string == input
      end
    end)
  end

  def executev2(context = %ExecutionContext{}) do
    if context.is_continuation == true and context.continuation_type == :numeric do
      case Integer.parse(context.raw_input) do
        {integer, _} ->
          context =
            context
            |> Map.put(:raw_input, context.continuation_data[integer])
            |> ExecutionContext.clear_continuation_data()
            |> ExecutionContext.clear_continuation_module()
            |> ExecutionContext.set_is_continuation(false)

          {:ok, context} = transaction(context, &context.continuation_module.continue/1)

          context

        :error ->
          context
          |> ExecutionContext.append_message(%Mud.Engine.Output{
            id: UUID.uuid4(),
            character_id: context.character_id,
            text:
              "{{warning}}Selection not recognized. Executing input as command instead.{{/warning}}"
          })
          |> ExecutionContext.clear_continuation_data()
          |> ExecutionContext.clear_continuation_module()
          |> ExecutionContext.set_is_continuation(false)
          |> do_execute()
      end
    else
      context
      |> ExecutionContext.clear_continuation_data()
      |> ExecutionContext.clear_continuation_module()
      |> ExecutionContext.set_is_continuation(false)
      |> do_execute()
    end
  end

  defp do_execute(context) do
    case string_to_command(context.raw_input) do
      {:ok, command} ->
        Logger.debug("turned string into a command")
        context = Map.put(context, :command, command)
        {:ok, context} = transaction(context, &command.callback_module.execute/1)

        process_messages(context)

      {:error, :no_match} ->
        Logger.debug("no matching command found")

        context =
          context
          |> ExecutionContext.clear_continuation_data()
          |> ExecutionContext.clear_continuation_module()
          |> ExecutionContext.set_is_continuation(false)
          |> ExecutionContext.append_message(%Mud.Engine.Output{
            id: UUID.uuid4(),
            character_id: context.character_id,
            text: "{{error}}No matching commands were found. Please try again.{{/error}}"
          })
          |> ExecutionContext.set_success()

        process_messages(context)
    end
  end

  defp transaction(context, function) do
    Mud.Repo.transaction(fn ->
      character = Mud.Engine.Model.Character.get_by_id!(context.character_id)
      context = %{context | character: character}

      if context.is_continuation do
        function.(context)
      else
        function.(context)
      end
    end)
  end

  defp process_messages(context) do
    if context.success do
      Enum.each(context.messages, fn message ->
        Mud.Engine.Session.cast_message(message)
      end)
    end

    context
  end
end
