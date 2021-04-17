defmodule Mud.Engine.Command.Executor do
  use TypedStruct

  typedstruct do
    field(:input, String.t(), required: true)

    field(:ast, Mud.Engine.Command.AbstractAstNode, default: nil)

    field(:callback_module, module())
  end

  alias Mud.Engine.Rules.Commands
  alias Mud.Engine.Command.AbstractAstNode
  alias Mud.Engine.Command.Definition.Part
  alias Mud.Engine.Command.Context
  alias Mud.Engine.Message
  alias Mud.Engine.Util
  require Logger

  ##
  # Public API
  ##

  @doc """
  Given a string such as 'get coin' or '"/slowly to thomas Yoohoo!' turn it into a populated '__MODULE__{}.t()' struct.
  """
  @spec string_to_command(String.t()) :: {:error, :no_match} | {:ok, Mud.Engine.Command.t()}
  def string_to_command(input) do
    input = String.trim(input)

    input =
      if String.starts_with?(input, "'") or String.starts_with?(input, "\"") do
        "say " <> String.trim(String.slice(input, 1..-1))
      else
        input
      end

    # Split the input and keep all the spaces for use/dropping later
    [first | rest] = Regex.split(~r/\s+/, input, include_captures: true)
    split_input = [String.downcase(first) | rest]

    case Commands.find_command_definition(List.first(split_input)) do
      {:ok, definition} ->
        parts = Map.new(definition.parts, fn part -> {part.key, part} end)

        case build_abstract_ast(split_input, {List.first(definition.parts), parts}) do
          abstract_asts when abstract_asts != [] ->
            abstract_ast =
              abstract_asts
              |> Enum.sort(&(length(&1) >= length(&2)))
              |> List.first()

            {:ok,
             %__MODULE__{
               input: input,
               callback_module: definition.callback_module,
               ast: definition.callback_module.build_ast(abstract_ast)
             }}

          [] ->
            {:error, :no_match}
        end

      error ->
        error
    end
  end

  @spec execute(Mud.Engine.Command.Context.t()) ::
          Mud.Engine.Command.Context.t()
  @doc """
  Given a populated `Mud.Engine.Command.Context` struct, execute the command logic.
  """
  def execute(context = %Context{}) do
    cond do
      context.is_continuation == true and context.continuation_type == :numeric ->
        case Integer.parse(context.input) do
          {integer, _} ->
            if not is_struct(context.continuation_data) do
              do_continue(context, context.continuation_data[integer])
            else
              cd = context.continuation_data
              cd = %{cd | cd.type => Map.get(cd, cd.type)[integer]}
              do_continue(context, cd)
            end

          :error ->
            context
            |> Context.append_message(
              Message.new_story_output(
                context.character_id,
                "Selection not recognized. Executing input as is instead.",
                "system_warning"
              )
            )
            |> Context.clear_continuation()
            |> do_execute()
        end

      context.is_continuation == true and context.continuation_type == :custom ->
        do_continue(context, {context.input, context.continuation_data})

      true ->
        do_execute(context)
    end
  end

  ##
  # Private Methods
  ##

  defp do_continue(context, continuation_data) do
    continuation_module = context.continuation_module

    context =
      context
      |> Context.set_input(continuation_data)
      |> Context.set_command(Context.get_continuation_command(context))
      |> Context.clear_continuation()

    {:ok, context} = transaction(context, &continuation_module.continue/1)

    process_events(context)
    process_messages(context)
  end

  @spec do_execute(Mud.Engine.Command.Context.t()) ::
          Mud.Engine.Command.Context.t()
  defp do_execute(context) do
    case string_to_command(context.input) do
      {:ok, command} ->
        context = Map.put(context, :command, command)
        {:ok, context} = transaction(context, &command.callback_module.execute/1)

        process_events(context)
        process_messages(context)

      {:error, :no_match} ->
        context =
          context
          |> Context.append_message(
            Message.new_story_output(
              context.character_id,
              "No matching commands were found. Please try again.",
              "system_alert"
            )
          )

        process_events(context)
        process_messages(context)
    end
  end

  defp transaction(context, function) do
    Mud.Repo.transaction(fn ->
      character = Mud.Engine.Character.get_by_id!(context.character_id)
      context = Context.set_character(context, character)

      function.(context)
    end)
  end

  defp process_events(context) do
    context.events
    |> Enum.reverse()
    |> Enum.each(fn event ->
      Mud.Engine.Session.cast_message_or_event(event)
    end)

    context
  end

  defp process_messages(context) do
    context.messages
    |> Enum.reverse()
    |> Enum.each(fn message ->
      Mud.Engine.Session.cast_message_or_event(message)
    end)

    context
  end

  @spec build_abstract_ast(
          [String.t()],
          %{atom() => Part.t()} | {Part.t(), %{atom() => Part.t()}},
          Part.t() | nil,
          AbstractAstNode.t() | nil,
          [AbstractAstNode.t()]
        ) :: [AbstractAstNode.t()] | []
  defp build_abstract_ast(split_input, parts, current_part \\ nil, current_ast \\ nil, ast \\ [])

  # No input to process but no ast nodes have been built.
  defp build_abstract_ast([], _parts, _current_part, nil, []) do
    []
  end

  # HAPPY PATH
  # All input has been processed and no dangling ast node
  # defp build_abstract_ast([], _parts, _current_part, nil, [last_node | rest]) do
  defp build_abstract_ast([], _parts, _current_part, nil, ast_nodes) do
    [Enum.reverse(ast_nodes)]
  end

  # All input has been processed but a dangling ast node needs to be put into the tree
  defp build_abstract_ast([], parts, current_part, current_ast, ast) do
    transformed_input =
      current_ast.input
      |> Enum.reverse()
      |> current_part.transformer.()

    current_ast = %{current_ast | input: transformed_input}

    build_abstract_ast([], parts, current_part, nil, [current_ast | ast])
  end

  # Not all input has been processed but there are no more possibilities for matching
  defp build_abstract_ast(input, _parts, nil, nil, ast)
       when length(ast) > 0 and length(input) > 0 do
    :error
  end

  # very first iteration
  defp build_abstract_ast([next_input | rest_of_input], {current_part, parts}, nil, nil, ast = []) do
    current_matches = any_matches?(current_part.matches, next_input)

    # if current node matches
    if current_matches do
      node = %AbstractAstNode{key: current_part.key, input: [next_input]}

      # if current node greedy
      if current_part.greedy do
        build_abstract_ast(rest_of_input, parts, current_part, node, ast)
        # current node not greedy
      else
        # listing potential children
        potential_children = list_children(current_part, parts)

        transformed_input =
          node.input
          |> Enum.reverse()
          |> current_part.transformer.()

        node = %{node | input: transformed_input}

        # There are potential children
        if length(potential_children) > 0 do
          r =
            Enum.flat_map(potential_children, fn child ->
              build_abstract_ast(rest_of_input, parts, child, nil, [node | ast])
            end)

          r

          # no potential children
        else
          build_abstract_ast(rest_of_input, parts, nil, nil, [node | ast])
        end
      end
    else
      []
    end
  end

  # Iterating through children the first time
  defp build_abstract_ast(all_input, parts, current_part, nil, ast) do
    # if is whitespace and should be dropped, do it and update values so rest of algorithm works
    [next_input | rest_of_input] =
      if Regex.match?(~r/^\s+$/, List.first(all_input)) and current_part.drop_whitespace do
        List.delete_at(all_input, 0)
      else
        all_input
      end

    current_matches = any_matches?(current_part.matches, next_input)

    if current_matches do
      node = %AbstractAstNode{key: current_part.key, input: [next_input]}

      if current_part.greedy do
        build_abstract_ast(rest_of_input, parts, current_part, node, ast)
      else
        potential_children = list_children(current_part, parts)

        transformed_input =
          node.input
          |> Enum.reverse()
          |> current_part.transformer.()

        node = %{node | input: transformed_input}

        if length(potential_children) > 0 do
          Enum.flat_map(potential_children, fn child ->
            build_abstract_ast(rest_of_input, parts, child, nil, [node | ast])
          end)
        else
          []
        end
      end
    else
      []
    end
  end

  # Iterating through a greedy child more than once
  defp build_abstract_ast(
         all_input,
         parts,
         current_part,
         current_ast,
         ast
       ) do
    # if is whitespace and should be dropped, do it and update values so rest of algorithm works
    [next_input | rest_of_input] =
      if Regex.match?(~r/^\s+$/, List.first(all_input)) and current_part.drop_whitespace do
        List.delete_at(all_input, 0)
      else
        all_input
      end

    current_matches = any_matches?(current_part.matches, next_input)
    potential_children = list_children(current_part, parts)

    transformed_input =
      current_ast.input
      |> Enum.reverse()
      |> current_part.transformer.()

    updated_current_ast = %{current_ast | input: transformed_input}

    child_asts =
      Enum.flat_map(potential_children, fn child ->
        build_abstract_ast(all_input, parts, child, nil, [updated_current_ast | ast])
      end)

    child_matches = length(child_asts) > 0

    cond do
      child_matches ->
        child_asts

      current_matches ->
        node = %{current_ast | input: [next_input | current_ast.input]}

        build_abstract_ast(rest_of_input, parts, current_part, node, ast)

      true ->
        []
    end
  end

  defp any_matches?(matches, string) do
    Enum.any?(matches, fn maybe_regex ->
      Util.check_equiv(maybe_regex, string)
    end)
  end

  defp list_children(current_part, all_children) do
    Stream.filter(all_children, fn {_key, child} ->
      Enum.any?(child.must_follow, &(&1 == current_part.key))
    end)
    |> Enum.map(fn tuple -> elem(tuple, 1) end)
  end
end
