defmodule Mud.Engine.Command do
  defstruct callback_module: nil,
            segments: [],
            raw_input: ""

  alias Mud.Engine.Commands
  alias Mud.Engine.CommandContext
  require Logger

  # throw rock at wall with sling
  # command, <object/character/denizen>, <key>

  defmodule Dependencies do
    defstruct all: [],
              any: []
  end

  defmodule Segment do
    # @enforce_keys [:autocomplete, :key, :match_strings, :optional]
    # "@", "/", "at ", "with ", ""
    defstruct match_strings: [],
              # Prefixes are split or trimmed from a string based on this flag.
              is_prefix: false,
              # Prefixes are used in two ways. In one a prefix is trimmed from a string before it is saved to the segment.
              # In the other, a prefix is split off from a string and used to populate a segment, while the second half of the
              # string is processed against the next segment in line.
              prefix: nil,
              autocomplete: true,
              # This segment can only be processed if a segment with the specified key has been
              # successfully populated. For example, there should be no character name segment for
              # the following partial command: "say /slowly"
              #
              # Whereas there should be character autocomplete for the following partial command
              must_follow: nil,
              cannot_follow: nil,
              # character, scenery, exit, denizen, self
              search: [],
              key: :look,
              # The string that was parsed/assigned to this segment
              input: [],
              # How many of these segments are allowed in a row
              max_allowed: 1
  end

  defmodule State do
    defstruct segments_to_process: [],
              populated_segments: [],
              raw_input: [],
              split_input: [],
              potential_combinations: []
  end

  @spec string_to_command(String.t()) ::
          {:error, :no_match | :not_found} | {:ok, Mud.Engine.Command.t()}
  def string_to_command(input) do
    state = %State{raw_input: input, split_input: String.split(input)}
    command_string = List.first(state.split_input)

    case Commands.find_command(command_string) do
      {:ok, command} ->
        case find_matching_combinations(command, state, false) do
          [] ->
            {:error, :no_match}

          matched_combination ->
            segments_map =
              Enum.reduce(matched_combination, %{}, fn segment, map ->
                Map.put(map, segment.key, segment)
              end)

            {:ok, %{command | raw_input: input, segments: segments_map}}
        end

      error ->
        error
    end
  end

  def string_to_matching_combinations(input) do
    state = %State{raw_input: input, split_input: String.split(input)}
    command_string = List.first(state.split_input)

    case Commands.find_command(command_string) do
      {:ok, command} ->
        find_matching_combinations(command, state, true)

      error ->
        error
    end
  end

  defp find_matching_combinations(command, state, multiple) do
    potential_combinations = build_combinations(command.segments)
    normalized_combinations = normalize_combinations(potential_combinations)
    state = %{state | potential_combinations: normalized_combinations}

    Enum.reduce(state.potential_combinations, [], fn combination, matches ->
      if not multiple and matches != [] do
        matches
      else
        case v2(%{state | segments_to_process: combination}) do
          {:ok, combo} ->
            if multiple do
              [normalize_combination(combo) | matches]
            else
              normalize_combination(combo)
            end

          {:error, combo} ->
            if multiple do
              [normalize_combination(combo) | matches]
            else
              matches
            end
        end
      end
    end)
  end

  defp build_combinations([segment | segments]) do
    segment
    |> build_layer(segments, [])
    |> flatten()
    |> inject_segment(segment)
    |> Enum.sort(fn list1, list2 ->
      length(list1) >= length(list2)
    end)
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

  def build_layer(node, potential_children, combination) do
    children =
      Enum.filter(potential_children, fn child ->
        Enum.any?(child.must_follow.any, fn dep -> dep == node.key end)
      end)

    case length(children) do
      0 ->
        if node.cannot_follow != nil do
          if Enum.any?(combination, fn segment ->
               segment.key in node.cannot_follow.any
             end) do
            combination
          else
            [node | combination]
          end
        else
          [node | combination]
        end

      _some ->
        children
        |> Enum.filter(fn child ->
          if child.cannot_follow != nil do
            not Enum.any?(combination, fn segment ->
              segment.key in child.cannot_follow.any
            end)
          else
            true
          end
        end)
        |> Enum.map(fn child ->
          potential_children = Enum.filter(potential_children, fn pc -> pc.key != node.key end)

          build_layer(child, potential_children, [node | combination])
        end)
    end
  end

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

  defp v2(state) do
    with true <- safe_to_process(state),
         [segment | segments] <- state.segments_to_process,
         [input | rest] <- state.split_input,
         {:ok, normalized_input} <- normalize_input_prefix(input, segment),
         true <- input_and_segment_match(normalized_input, segment),
         segment <- update_allowance(segment),
         segment <- update_input(segment, normalized_input) do
      if segment.max_allowed > 0 do
        {:ok,
         %{
           state
           | segments_to_process: [segment | segments],
             split_input: rest
         }}
      else
        {:ok,
         %{
           state
           | populated_segments: [segment | state.populated_segments],
             segments_to_process: segments,
             split_input: rest
         }}
      end
    else
      {:error, :unsafe_to_process} ->
        cond do
          Enum.empty?(state.segments_to_process) and Enum.empty?(state.split_input) ->
            # throw({:ok, state.populated_segments})
            {:match, state.populated_segments}

          length(state.segments_to_process) > 0 and
            length(List.first(state.segments_to_process).input) > 0 and
              Enum.empty?(state.split_input) ->
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
    %{segment | input: [input | segment.input]}
  end

  defp update_allowance(segment) do
    if segment.max_allowed == :infinite do
      segment
    else
      %{segment | max_allowed: segment.max_allowed - 1}
    end
  end

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

  defp input_and_segment_match(input, segment) do
    if any_strings_match?(segment.match_strings, input) do
      true
    else
      {:error, :no_match}
    end
  end

  defp safe_to_process(state) do
    cond do
      Enum.empty?(state.segments_to_process) and Enum.empty?(state.split_input) ->
        {:match, state}

      not Enum.empty?(state.segments_to_process) and not Enum.empty?(state.split_input) ->
        true

      true ->
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

  def executev2(context = %CommandContext{}) do
    IO.inspect(context, label: "executev2")
    if context.is_continuation == true do
      # IO.inspect("CONTINUATION")
      context
    else
      case string_to_command(context.raw_input) do
        {:ok, command} ->
          context = Map.put(context, :command, command)
          {:ok, context} = transaction(context, &command.callback_module.execute/1)
          # IO.inspect(context, label: "after exectuion")

          process_messages(context)

        {:error, :not_found} ->
          context
      end
    end
  end

  @doc """
  Take a string, find a command it matches, and execute it if possible.

  After execution messages will be sent out.
  """
  def execute(context) do
    trimmed_input = String.trim(context.raw_input)

    if context.is_continuation == true do
      context = Map.put(context, :raw_input, trimmed_input)

      case context.continuation_module.parse_continuation_arg_string(trimmed_input) do
        {:ok, parsed_args} ->
          context = %{context | parsed_args: parsed_args}

          {:ok, context} = transaction(context, &context.continuation_module.continue/1)

          process_messages(context)

          context

        {:error, _error} ->
          context
          |> Mud.Engine.CommandContext.append_message(%Mud.Engine.Output{
            id: UUID.uuid4(),
            character_id: context.character_id,
            text:
              "{{error}}Selection not recognized. Please try the original command again.{{/error}}"
          })
          |> Mud.Engine.CommandContext.clear_continuation_data()
          |> Mud.Engine.CommandContext.clear_continuation_module()
          |> Mud.Engine.CommandContext.set_is_continuation(false)
          |> Mud.Engine.CommandContext.set_success(true)
          |> process_messages()
      end
    else
      split_string =
        String.split(trimmed_input, " ", parts: 2, trim: true) |> Enum.map(&String.trim/1)

      raw_command = List.first(split_string)

      case Mud.Engine.Commands.find_command(raw_command) do
        {:ok, command} ->
          arg_string =
            if length(split_string) == 1 do
              ""
            else
              List.last(split_string)
            end

          context = %{
            context
            | command: command,
              raw_input: trimmed_input,
              raw_argument_string: arg_string
          }

          case command.callback_module.parse_execute_arg_string(arg_string) do
            {:ok, parsed_args} ->
              context = %{context | parsed_args: parsed_args}

              {:ok, context} = transaction(context, &command.callback_module.execute/1)

              process_messages(context)

              context

            {:error, _error} ->
              context
              |> Mud.Engine.CommandContext.append_message(%Mud.Engine.Output{
                id: UUID.uuid4(),
                character_id: context.character_id,
                text: "{{error}}Failed to parse arguements for `#{command.raw_input}`.{{/error}}"
              })
              |> Mud.Engine.CommandContext.set_success(true)
              |> process_messages()
          end

        {:error, :not_found} ->
          context
          |> Mud.Engine.CommandContext.append_message(%Mud.Engine.Output{
            id: UUID.uuid4(),
            character_id: context.character_id,
            text: "{{error}}You want to do what?{{/error}}"
          })
          |> Mud.Engine.CommandContext.set_success(true)
          |> process_messages()
      end
    end
  end

  defp transaction(context, function) do
    Mud.Repo.transaction(fn ->
      character = Mud.Engine.get_character!(context.character_id)
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
        Mud.Engine.cast_message_to_character_session(message)
      end)
    end

    context
  end
end
