defmodule Mud.Engine.Command.AstUtil do
  alias Mud.Engine.Command.AstNode

  require Logger

  @doc """
  Given a list of `Mud.Engine.Command.AstNode` structs, turn them into a populated
  `Mud.Engine.Command.AstNode.OneThing{} struct.
  """
  @spec build_one_thing_ast([Mud.Engine.Command.AstNode.t(), ...]) ::
          Mud.Engine.Command.AstNode.OneThing.t()
  def build_one_thing_ast([]) do
    %AstNode.OneThing{}
  end

  def build_one_thing_ast([node | ast_nodes]) do
    Logger.debug(inspect([node | ast_nodes]))
    {thing, []} = populate_thing(%AstNode.Thing{}, ast_nodes)

    case thing.input do
      nil ->
        %AstNode.OneThing{
          command: node.input
        }

      _ ->
        %AstNode.OneThing{
          command: node.input,
          thing: thing
        }
    end
  end

  def build_one_thing_ast([node | ast_nodes]) do
    Logger.debug(inspect([node | ast_nodes]))
    {thing, []} = populate_thing(%AstNode.Thing{}, ast_nodes)

    case thing.input do
      nil ->
        %AstNode.OneThing{
          command: node.input
        }

      _ ->
        %AstNode.OneThing{
          command: node.input,
          thing: thing
        }
    end
  end

  @doc """
  Given a list of `Mud.Engine.Command.AstNode` structs, turn them into a populated
  `Mud.Engine.Command.AstNode.CommandInput{} struct.
  """
  @spec build_command_input_ast([Mud.Engine.Command.AstNode.t(), ...]) ::
          Mud.Engine.Command.AstNode.CommandInput.t()
  def build_command_input_ast([command]) do
    %AstNode.CommandInput{command: command.input}
  end

  def build_command_input_ast([command, input]) do
    %AstNode.CommandInput{command: command.input, input: input.input}
  end

  @doc """
  Given a list of `Mud.Engine.Command.AstNode` structs, turn them into a populated
  `Mud.Engine.Command.AstNode.ThingAndPlace{} struct.
  """
  @spec build_tap_ast([Mud.Engine.Command.AstNode.t(), ...]) ::
          Mud.Engine.Command.AstNode.ThingAndPlace.t()
  def build_tap_ast([]) do
    %AstNode.ThingAndPlace{}
  end

  def build_tap_ast([node | ast_nodes]) do
    {thing, rest} = populate_thing(%AstNode.Thing{}, ast_nodes)

    case thing.input do
      nil ->
        %AstNode.ThingAndPlace{
          command: node.input
        }

      _ ->
        place = populate_place(%AstNode.Place{}, rest)

        case place.input do
          nil ->
            %AstNode.ThingAndPlace{
              command: node.input,
              thing: thing
            }

          _ ->
            %AstNode.ThingAndPlace{
              command: node.input,
              thing: thing,
              place: populate_place(%AstNode.Place{}, rest)
            }
        end
    end
  end

  defp populate_thing(node, []), do: {node, []}

  defp populate_thing(node = %AstNode.Thing{}, [ast_node | rest]) do
    case ast_node.key do
      :thing_personal ->
        populate_thing(%{node | personal: true}, rest)

      :thing_which ->
        populate_thing(%{node | which: ast_node.input}, rest)

      :thing_where ->
        populate_thing(%{node | where: ast_node.input}, rest)

      :thing ->
        {%{node | input: ast_node.input}, rest}
    end
  end

  defp populate_place(tap_node, []) do
    tap_node
  end

  defp populate_place(tap_node = %AstNode.Place{}, [ast_node | rest]) do
    case ast_node.key do
      :place_personal ->
        populate_place(%{tap_node | personal: true}, rest)

      :place_which ->
        populate_place(%{tap_node | which: ast_node.input}, rest)

      :place_where ->
        populate_place(%{tap_node | where: ast_node.input}, rest)

      :place ->
        tap_node = %{tap_node | input: ast_node.input}

        if length(rest) > 0 do
          node = populate_place(%AstNode.Place{}, rest)

          %{node | path: tap_node}
        else
          tap_node
        end
    end
  end
end
