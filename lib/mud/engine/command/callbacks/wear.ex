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

  @behaviour Mud.Engine.Command.Callback

  @impl true
  def continue(context) do
    wear_thing(context, context.input)
  end

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
      |> ExecutionContext.set_success()
    else
      held_items = Character.list_held_items(context.character)

      if length(held_items) == 0 do
        ExecutionContext.append_output(
          context,
          context.character.id,
          "You aren't holding anything.",
          "error"
        )
        |> ExecutionContext.set_success()
      else
        ast = context.command.ast

        matches = Search.generate_matches(held_items, ast.thing.input, ast.thing.which)

        case matches do
          {:ok, [match]} ->
            wear_thing(context, match)

          {:ok, matches} when length(matches) > 1 ->
            Util.handle_multiple_items(
              context,
              Enum.map(matches, & &1.short_description),
              matches,
              "Which thing did you wish to wear?"
            )

          _ ->
            ExecutionContext.append_output(
              context,
              context.character.id,
              "Could not find what you were attempting to drop.",
              "error"
            )
            |> ExecutionContext.set_success()
        end
      end
    end
  end

  @spec wear_thing(ExecutionContext.t(), Mud.Engine.Match.t()) :: ExecutionContext.t()
  defp wear_thing(context, match) do
    item = match.match

    if item.is_wearable do
      Item.update!(item, %{
        wearable_worn_by_id: context.character.id,
        wearable_is_worn: true,
        holdable_held_by_id: nil,
        holdable_is_held: false,
        holdable_hand: nil
      })

      others =
        Character.list_others_active_in_areas(context.character.id, context.character.area_id)

      context
      |> ExecutionContext.append_output(
        others,
        "{{character}}#{context.character.name}{{/character}} puts {{item}}#{
          match.short_description
        }{{/item}} on their {{bodypart}}#{item.wearable_location}{{/bodypart}}.",
        "info"
      )
      |> ExecutionContext.append_output(
        context.character.id,
        "You put {{item}}#{match.short_description}{{/item}} on your {{bodypart}}#{
          item.wearable_location
        }{{/bodypart}}.",
        "info"
      )
      |> ExecutionContext.append_event(
        context.character_id,
        UpdateInventory.new(:update, item)
      )
      |> ExecutionContext.set_success()
    else
      ExecutionContext.append_output(
        context,
        context.character.id,
        String.capitalize("{{item}}#{match.short_description}{{/item}} cannot be worn."),
        "error"
      )
      |> ExecutionContext.set_success()
    end
  end
end
