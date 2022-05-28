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
        place = populate_place(%AstNode.Place{}, rest) |> normalize_personal()

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
              place: place
            }
        end
    end
  end

  defp normalize_personal(place = %AstNode.Place{path: nil}) do
    place
  end

  defp normalize_personal(place = %AstNode.Place{personal: true, path: path_place}) do
    %{place | path: normalize_personal(%{path_place | personal: true})}
  end

  defp normalize_personal(place = %AstNode.Place{personal: false, path: path_place}) do
    path_place = normalize_personal(path_place)

    %{place | path: path_place, personal: path_place.personal}
  end

  defp populate_thing(node, []), do: {node, []}

  defp populate_thing(node = %AstNode.Thing{}, [ast_node | rest]) do
    case ast_node.key do
      :thing_personal ->
        populate_thing(%{node | personal: true}, rest)

      :thing_switch ->
        populate_thing(%{node | switch: ast_node.input}, rest)

      :thing_which ->
        populate_thing(%{node | which: ast_node.input}, rest)

      :thing_where ->
        populate_thing(%{node | where: ast_node.input}, rest)

      :thing ->
        populate_thing(%{node | input: ast_node.input}, rest)

      _ ->
        {node, [ast_node | rest]}
    end
  end

  defp populate_place(tap_node, []) do
    tap_node
  end

  defp populate_place(tap_node = %AstNode.Place{}, [ast_node | rest]) do
    case ast_node.key do
      :place_personal ->
        populate_place(%{tap_node | personal: true}, rest)

      :place_switch ->
        # if place has already been populated than this switch should belong to the "next" place
        # specified
        if not is_nil(tap_node.input) do
          node = populate_place(%AstNode.Place{}, [ast_node | rest])

          %{tap_node | path: node}
        else
          # if place not populated then switch belongs to "this" place
          populate_place(%{tap_node | switch: ast_node.input}, rest)
        end

      :place_which ->
        populate_place(%{tap_node | which: ast_node.input}, rest)

      :place_where ->
        populate_place(%{tap_node | where: ast_node.input}, rest)

      :place ->
        # if place already is populated, then rotate, don't just assume.
        if not is_nil(tap_node.input) do
          node = populate_place(%AstNode.Place{}, [ast_node | rest])

          %{tap_node | path: node}
        else
          # if place not populated then populate and recurse
          populate_place(%{tap_node | input: ast_node.input}, rest)
        end
    end
  end
end
