defmodule Mud.Engine.Command.Drop do
  @moduledoc """
  The DROP command allows a character to drop a held item onto the ground.

  An optional number, which selects which item in case of a multiple match conflict, may be provided.

  Syntax:
    - drop <which> <item>

  Examples:
    - drop sword
    - drop pink uni
    - drop 2 appl
  """

  use Mud.Engine.Command.Callback

  alias Mud.Engine.Event.Client.{UpdateArea, UpdateInventory}
  alias Mud.Engine.Search
  alias Mud.Engine.Util
  alias Mud.Engine.Command.Context
  alias Mud.Engine.{Character, Item}

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
        item = Item.get!(context.command.ast.thing.input)

        if Util.is_item_on_character?(item, context.character) do
          drop_thing(context, item)
        else
          Util.dave_error(context)
        end
      else
        find_thing_to_drop(context)
      end
    end
  end

  defp find_thing_to_drop(context) do
    held_items = Character.list_held_items(context.character)

    if length(held_items) == 0 do
      context
      |> Context.append_error("You aren't holding anything.")
    else
      ast = context.command.ast

      matches = Search.generate_matches(held_items, ast.thing.input, ast.thing.which)

      case matches do
        {:ok, [match]} ->
          drop_thing(context, match.match)

        {:ok, matches} when length(matches) > 1 ->
          Util.multiple_error(context)

        _ ->
          context
          |> Context.append_error("Could not find what you were attempting to drop.")
      end
    end
  end

  defp drop_thing(context, item) do
    item =
      Item.update!(item, %{
        container_id: nil,
        holdable_is_held: false,
        holdable_held_by_id: nil,
        holdable_hand: nil,
        area_id: context.character.area_id
      })

    all_items = Item.list_all_recursive(item)

    other_msg =
      "{{character}}#{context.character.name}{{/character}} drops {{item}}#{
        item.description.short
      }{{/item}} on the ground."

    self_msg = "You drop {{item}}#{item.description.short}{{/item}} on the ground."

    others =
      Character.list_others_active_in_areas(context.character.id, context.character.area_id)

    context
    |> Context.append_output(
      others,
      other_msg,
      "info"
    )
    |> Context.append_output(
      context.character.id,
      self_msg,
      "info"
    )
    |> Context.append_event(
      [context.character_id | others],
      UpdateArea.new(%{action: :add, on_ground: all_items})
    )

    # |> Context.append_event(
    #   context.character_id,
    #   UpdateInventory.new(:remove, all_items)
    # )
  end
end
