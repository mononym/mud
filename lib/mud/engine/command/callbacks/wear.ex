defmodule Mud.Engine.Command.Wear do
  @moduledoc """
  The WEAR command allows the Character to put on things like rings, backpacks, armour, clothing, etc...

  The item to be worn must be held.

  Syntax:
    - wear <target>

  Examples:
    - wear backpack
  """

  alias Mud.Engine.Event.Client.UpdateInventory
  alias Mud.Engine.Util
  alias Mud.Engine.Command.ExecutionContext
  alias Mud.Engine.Search
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
      if Util.is_uuid4(ast.thing.input) do
        item = Item.get!(ast.thing.input)

        if item.holdable_held_by_id == context.character.id do
          wear_thing(context, item)
        else
          Util.dave_error(context)
        end
      else
        find_thing_to_wear(context)
      end
    end
  end

  defp find_thing_to_wear(context) do
    held_items = Character.list_held_items(context.character)

    if length(held_items) == 0 do
      context
      |> ExecutionContext.append_error("You aren't holding anything.")
    else
      ast = context.command.ast

      matches = Search.generate_matches(held_items, ast.thing.input, ast.thing.which)

      case matches do
        {:ok, [match]} ->
          wear_thing(context, match.match)

        {:ok, matches} when length(matches) > 1 ->
          Util.multiple_error(context)

        _ ->
          context
          |> ExecutionContext.append_error("Could not find what you were attempting to wear.")
      end
    end
  end

  @spec wear_thing(ExecutionContext.t(), Mud.Engine.Item.t()) :: ExecutionContext.t()
  defp wear_thing(context, item) do
    primary_container = Item.get_primary_container(context.character.id)

    if item.is_wearable do
      item =
        Item.update!(item, %{
          wearable_worn_by_id: context.character.id,
          wearable_is_worn: true,
          holdable_held_by_id: nil,
          holdable_is_held: false,
          holdable_hand: nil,
          container_primary: item.is_container and is_nil(primary_container)
        })

      others =
        Character.list_others_active_in_areas(context.character.id, context.character.area_id)

      context
      |> ExecutionContext.append_output(
        others,
        "{{character}}#{context.character.name}{{/character}} puts {{item}}#{
          item.short_description
        }{{/item}} on their {{bodypart}}#{item.wearable_location}{{/bodypart}}.",
        "info"
      )
      |> ExecutionContext.append_output(
        context.character.id,
        "You put {{item}}#{item.short_description}{{/item}} on your {{bodypart}}#{
          item.wearable_location
        }{{/bodypart}}.",
        "info"
      )
      |> ExecutionContext.append_event(
        context.character_id,
        UpdateInventory.new(:update, item)
      )
    else
      ExecutionContext.append_output(
        context,
        context.character.id,
        String.capitalize("{{item}}#{item.short_description}{{/item}} cannot be worn."),
        "error"
      )
    end
  end
end
