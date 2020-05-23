defmodule Mud.Engine.Command do
  # defstruct callback_module: nil,
  #           ast: nil,
  #           input: ""

  use TypedStruct

  typedstruct do
    field(:input, String.t(), required: true)

    field(:ast, Mud.Engine.Command.AstNode, default: nil)

    field(:callback_module, module())
  end

  alias Mud.Engine.Rules.Commands
  alias Mud.Engine.Command.AstNode
  alias Mud.Engine.Command.Definition.Part
  alias Mud.Engine.Command.ExecutionContext
  alias Mud.Engine.Message
  alias Mud.Engine.Util
  require Logger

  ##
  # Public API
  ##

  @doc """
  Given a string such as 'look' or 'move west' turn it into a populated '__MODULE__{}.t()' struct.
  """
  @spec string_to_command(String.t()) :: {:error, :no_match} | {:ok, Mud.Engine.Command.t()}
  def string_to_command(input) do
    # Split the input and keep all the spaces for use/dropping later
    split_input = Regex.split(~r/\s+/, input, include_captures: true)

    case Commands.find_command_definition(List.first(split_input)) do
      {:ok, definition} ->
        parts = Map.new(definition.parts, fn part -> {part.key, part} end)
        Logger.debug("definition: #{inspect(definition)}")

        case build_ast(split_input, {List.first(definition.parts), parts}) do
          possible_ast_list when possible_ast_list != [] ->
            Logger.debug("possible_ast_list: #{inspect(possible_ast_list)}")
            # Sort longest to shortest and grab longest match
            ast =
              possible_ast_list
              |> Enum.sort(fn x, y -> y.generations <= x.generations end)
              |> List.first()

            {:ok,
             %__MODULE__{
               input: input,
               callback_module: definition.callback_module,
               ast: ast
             }}

          [] ->
            {:error, :no_match}
        end

      error ->
        error
    end
  end

  @spec execute(Mud.Engine.Command.ExecutionContext.t()) ::
          Mud.Engine.Command.ExecutionContext.t()
  @doc """
  Given a populated `Mud.Engine.Command.ExecutionContext` struct, execute the command logic.
  """
  def execute(context = %ExecutionContext{}) do
    if context.is_continuation == true and context.continuation_type == :numeric do
      case Integer.parse(context.input) do
        {integer, _} ->
          continuation_module = context.continuation_module

          context =
            context
            |> ExecutionContext.set_input(context.continuation_data[integer])
            |> ExecutionContext.set_command(ExecutionContext.get_continuation_command(context))
            |> ExecutionContext.clear_continuation()

          {:ok, context} = transaction(context, &continuation_module.continue/1)

          process_messages(context)

        :error ->
          context
          |> ExecutionContext.append_message(
            Message.new_output(
              context.character_id,
              "Selection not recognized. Executing input as is instead.",
              "warning"
            )
          )
          |> ExecutionContext.clear_continuation()
          |> do_execute()
      end
    else
      do_execute(context)
    end
  end

  ##
  # Private Methods
  ##

  @spec do_execute(Mud.Engine.Command.ExecutionContext.t()) ::
          Mud.Engine.Command.ExecutionContext.t()
  defp do_execute(context) do
    Logger.debug("do_execute")
    Logger.debug(inspect(context))

    case string_to_command(context.input) do
      {:ok, command} ->
        Logger.debug("do_execute string_to_command succeeded")
        context = Map.put(context, :command, command)
        {:ok, context} = transaction(context, &command.callback_module.execute/1)

        process_messages(context)

      {:error, :no_match} ->
        Logger.debug("do_execute string_to_command failed")

        context =
          context
          |> ExecutionContext.append_output(
            context.character_id,
            "No matching commands were found. Please try again.",
            "error"
          )
          |> ExecutionContext.set_success()

        process_messages(context)
    end
  end

  defp transaction(context, function) do
    Mud.Repo.transaction(fn ->
      character = Mud.Engine.Model.Character.get_by_id!(context.character_id)
      context = ExecutionContext.set_character(context, character)

      function.(context)
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

  @spec normalize_ast(Mud.Engine.Command.AstNode.t(), [Mud.Engine.Command.AstNode.t()]) ::
          Mud.Engine.Command.AstNode.t()
  defp normalize_ast(ast_node, []) do
    ast_node
  end

  defp normalize_ast(ast_node, [node | rest_of_nodes]) do
    new_ast_node = %{
      node
      | children: Map.put(node.children, ast_node.key, ast_node),
        generations: ast_node.generations + 1
    }

    normalize_ast(new_ast_node, rest_of_nodes)
  end

  @spec build_ast(
          [String.t()],
          %{atom() => Part.t()} | {Part.t(), %{atom() => Part.t()}},
          Part.t() | nil,
          AstNode.t() | nil,
          [
            AstNode.t()
          ]
        ) ::
          [AstNode.t()] | []
  defp build_ast(split_input, parts, current_part \\ nil, current_ast \\ nil, ast \\ [])

  # No input to process but no ast nodes have been built.
  defp build_ast([], _parts, _current_part, nil, []) do
    []
  end

  # HAPPY PATH
  # All input has been processed and no dangling ast node
  defp build_ast([], _parts, _current_part, nil, [last_node | rest]) do
    Logger.debug("All input has been processed and no dangling ast node")

    normalize_ast(last_node, rest)
    |> List.wrap()
  end

  # All input has been processed but a dangling ast node needs to be put into the tree
  defp build_ast([], parts, current_part, current_ast, ast) do
    Logger.debug(
      "All input has been processed but a dangling ast node needs to be put into the tree"
    )

    transformed_input =
      current_ast.input
      |> current_part.transformer.()

    current_ast = %{current_ast | input: transformed_input}

    build_ast([], parts, current_part, nil, [current_ast | ast])
  end

  # Not all input has been processed but there are no more possibilities for matching
  defp build_ast(input, _parts, nil, nil, ast)
       when length(ast) > 0 and length(input) > 0 do
    Logger.debug(
      "Not all input has been processed but there are no more possibilities for matching"
    )

    :error
  end

  # very first iteration
  defp build_ast([next_input | rest_of_input], {current_part, parts}, nil, nil, ast = []) do
    Logger.debug("very first iteration")
    current_matches = any_matches?(current_part.matches, next_input)

    # if current node matches
    if current_matches do
      node = %AstNode{key: current_part.key, input: [next_input]}

      # if current node greedy
      if current_part.greedy do
        build_ast(rest_of_input, parts, current_part, node, ast)
        # current node not greedy
      else
        # listing potential children which ALSO match the input
        potential_children = list_children(current_part, parts)

        transformed_input =
          node.input
          |> current_part.transformer.()

        node = %{node | input: transformed_input}

        # There are potential children
        if length(potential_children) > 0 do
          Enum.flat_map(potential_children, fn child ->
            build_ast(rest_of_input, parts, child, nil, [node | ast])
          end)

          # no potential children
        else
          build_ast(rest_of_input, parts, nil, nil, [node | ast])
        end
      end
    else
      []
    end
  end

  # Iterating through children the first time
  defp build_ast(all_input, parts, current_part, nil, ast) do
    Logger.debug("Iterating through children the first time")
    Logger.debug(inspect({all_input, parts, current_part, nil, ast}))
    # if is whitespace and should be dropped, do it and update values so rest of algorithm works
    [next_input | rest_of_input] =
      if Regex.match?(~r/^\s+$/, List.first(all_input)) and current_part.drop_whitespace do
        List.delete_at(all_input, 0)
      else
        all_input
      end

    Logger.debug(inspect([next_input | rest_of_input]))

    current_matches = any_matches?(current_part.matches, next_input)
    Logger.debug(inspect(current_matches))

    if current_matches do
      node = %AstNode{key: current_part.key, input: [next_input]}

      if current_part.greedy do
        build_ast(rest_of_input, parts, current_part, node, ast)
      else
        # matching_children = list_matches(next_input, current_part, parts)
        potential_children = list_children(current_part, parts)

        transformed_input =
          node.input
          |> current_part.transformer.()

        node = %{node | input: transformed_input}

        if length(potential_children) > 0 do
          Enum.flat_map(potential_children, fn child ->
            build_ast(rest_of_input, parts, child, nil, [node | ast])
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
  defp build_ast(
         all_input,
         parts,
         current_part,
         current_ast,
         ast
       ) do
    Logger.debug("Iterating through a greedy child more than once")
    # if is whitespace and should be dropped, do it and update values so rest of algorithm works
    [next_input | rest_of_input] =
      if Regex.match?(~r/^\s+$/, List.first(all_input)) and current_part.drop_whitespace do
        List.delete_at(all_input, 0)
      else
        all_input
      end

    current_matches = any_matches?(current_part.matches, next_input)

    if current_matches do
      node = %{current_ast | input: [next_input | current_ast.input]}

      build_ast(rest_of_input, parts, current_part, node, ast)
    else
      potential_children = list_children(current_part, parts)

      transformed_input =
        current_ast.input
        |> current_part.transformer.()

      current_ast = %{current_ast | input: transformed_input}

      if length(potential_children) > 0 do
        Enum.flat_map(potential_children, fn child ->
          build_ast(all_input, parts, child, nil, [current_ast | ast])
        end)
      else
        []
      end
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
