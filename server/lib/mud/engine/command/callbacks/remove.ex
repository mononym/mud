defmodule Mud.Engine.Command.Remove do
  @moduledoc """
  The REMOVE command allows a character to 'remove' things from a container and place them on the ground.

  Syntax:
    - remove <thing> from <place>

  Examples:
    - remove gem from gembag
  """
  use Mud.Engine.Command.Callback

  alias Mud.Engine.Event.Client.UpdateInventory
  alias Mud.Engine.Item
  alias Mud.Engine.Character
  alias Mud.Engine.Command.Context
  alias Mud.Engine.Util
  alias Mud.Engine.Search

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
      if Util.is_uuid4(ast.thing.input) do
        item = Item.get!(ast.thing.input)

        if item.wearable_worn_by_id == context.character.id do
          remove_thing(context, item)
        else
          Util.dave_error(context)
        end
      else
        find_thing_to_remove(context)
      end
    end
  end

  defp find_thing_to_remove(context) do
    held_items = Character.list_held_items(context.character)

    if length(held_items) == 2 do
      Context.append_output(
        context,
        context.character.id,
        "Your hands are full. Empty at least one of them first.",
        "error"
      )
    else
      ast = context.command.ast
      worn_items = Character.list_worn_items(context.character)

      matches = Search.generate_matches(worn_items, ast.thing.input, ast.thing.which)

      case matches do
        {:ok, [match]} ->
          remove_thing(context, match.match)

        {:ok, matches} when length(matches) > 1 ->
          Util.handle_multiple_items(
            context,
            Enum.map(matches, & &1.description.short),
            matches,
            "Which thing did you wish to remove?"
          )

        _ ->
          Context.append_output(
            context,
            context.character.id,
            "Could not find what you were attempting to remove.",
            "error"
          )
      end
    end
  end

  defp remove_thing(context, item) do
    held_items = Character.list_held_items(context.character)
    was_container_primary = not is_nil(item.container_primary)

    item =
      Item.update!(item, %{
        wearable_worn_by_id: nil,
        wearable_is_worn: false,
        holdable_held_by_id: context.character.id,
        holdable_is_held: true,
        holdable_hand: Character.which_hand(held_items),
        container_primary: false
      })

    # context = Util.maybe_update_primary_container(context, was_container_primary)

    others =
      Character.list_others_active_in_areas(context.character.id, context.character.area_id)

    context
    |> Context.append_output(
      others,
      "{{character}}#{context.character.name}{{/character}} removed {{item}}#{
        item.description.short
      }{{/item}} from their {{bodypart}}#{item.wearable_location}{{/bodypart}}.",
      "info"
    )
    |> Context.append_output(
      context.character.id,
      String.capitalize(
        "You remove {{item}}#{item.description.short}{{/item}} from your {{bodypart}}#{
          item.wearable_location
        }{{/bodypart}}."
      ),
      "info"
    )
    |> Context.append_event(
      context.character_id,
      UpdateInventory.new(:update, item)
    )
  end
end
