defmodule Mud.Engine.Command.Travel do
  @moduledoc """
  The TRAVEL command allows a character to automatically travel from one place to another.

  Syntax:
    - travel <destination>

  Examples:
    - travel <uuid is currently the only accepted input>
  """

  use Mud.Engine.Command.Callback

  alias Mud.Engine.Script
  alias Mud.Engine.Util
  alias Mud.Engine.Command.Context
  alias Mud.Engine.{Area, Region}

  require Logger

  @spec build_ast([Mud.Engine.Command.AstNode.t(), ...]) ::
          Mud.Engine.Command.AstNode.OneThing.t()
  def build_ast(ast_nodes) do
    Mud.Engine.Command.AstUtil.build_one_thing_ast(ast_nodes)
  end

  @impl true
  def execute(context) do
    ast = context.command.ast

    if is_nil(ast.thing) do
      Context.append_output(
        context,
        context.character.id,
        Util.get_module_docs(__MODULE__),
        "error"
      )
    else
      if Util.is_uuid4(context.command.ast.thing.input) do
        area = Area.get_area!(ast.thing.input)

        raw_data = Region.list_area_and_link_ids(area.region_id)

        raw_data =
          Map.put(
            raw_data,
            :link_ids,
            Enum.map(raw_data[:link_ids], fn {lid, l1, l2} ->
              {l1, l2, [label: lid, weight: 1]}
            end)
          )

        graph =
          Graph.new(type: :directed)
          |> Graph.add_edges(raw_data[:link_ids])
          |> Graph.add_vertices(raw_data[:area_ids])

        path = Graph.dijkstra(graph, context.character.area_id, area.id)

        :ok = Script.attach(context.character, "quick_travel", Script.Travel, path)

        context
      else
        Util.dave_error(context)
      end
    end
  end
end
