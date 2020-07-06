defmodule Mud.Engine.Command.Close do
  @moduledoc """
  The CLOSE command allows the Character to close something such as a door or a chest.

  Syntax:
    - close <target>

  Examples:
    - close backpack
    - close door
    - close pouch in backpack
  """

  alias Mud.Engine.Event.Client.{UpdateArea, UpdateInventory}
  alias Mud.Engine.Util
  alias Mud.Engine.Command.ExecutionContext
  alias Mud.Engine.{Character, Item}

  require Logger

  use Mud.Engine.Command.Callback

  @spec build_ast([Mud.Engine.Command.AstNode.t(), ...]) ::
          Mud.Engine.Command.AstNode.OneThing.t()
  def build_ast(ast_nodes) do
    Mud.Engine.Command.AstUtil.build_one_thing_ast(ast_nodes)
  end

  @impl true
  def execute(context) do
    ast = context.command.ast

    if is_nil(ast.thing) do
      ExecutionContext.append_output(
        context,
        context.character.id,
        Util.get_module_docs(__MODULE__),
        "error"
      )
    else
      if Util.is_uuid4(context.command.ast.thing.input) do
        item = Item.get!(context.command.ast.thing.input)

        if Util.is_item_on_character?(item, context.character) do
          close_thing(context, item)
        else
          Util.dave_error(context)
        end
      else
        find_thing_to_close(context)
      end
    end
  end

  defp find_thing_to_close(context) do
    # held_items = Character.list_held_items(context.character)

    # if length(held_items) == 0 do
    #   context
    #   |> ExecutionContext.append_error("You aren't holding anything.")
    # else
    #   ast = context.command.ast

    #   matches = Search.generate_matches(held_items, ast.thing.input, ast.thing.which)

    #   case matches do
    #     {:ok, [match]} ->
    #       close_thing(context, match.match)

    #     {:ok, matches} when length(matches) > 1 ->
    #       Util.multiple_error(context)

    #     _ ->
    #       context
    #       |> ExecutionContext.append_error("Could not find what you were attempting to close.")
    #   end
    # end
    context
  end

  defp close_thing(context, item) do
    item =
      Item.update!(item, %{
        container_open: false
      })

    other_msg =
      "{{character}}#{context.character.name}{{/character}} closes {{item}}#{
        item.short_description
      }{{/item}}."

    self_msg = "You close {{item}}#{item.short_description}{{/item}}."

    others =
      Character.list_others_active_in_areas(context.character.id, context.character.area_id)

    # context =
    #   if is_nil()

    context
    |> ExecutionContext.append_output(
      others,
      other_msg,
      "info"
    )
    |> ExecutionContext.append_output(
      context.character.id,
      self_msg,
      "info"
    )
    |> ExecutionContext.append_event(
      [context.character_id | others],
      UpdateArea.new(:add, item)
    )
    |> ExecutionContext.append_event(
      context.character_id,
      UpdateInventory.new(:remove, item)
    )
  end
end
