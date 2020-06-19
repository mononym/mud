defmodule Mud.Engine.Command.Swap do
  @moduledoc """
  The SWAP command switches items held by a character between their hands.

  Syntax:
    - swap
  """

  use Mud.Engine.Command.Callback

  alias Mud.Engine.Command.ExecutionContext
  alias Mud.Engine.{Character, Item}

  require Logger

  @spec build_ast([Mud.Engine.Command.AstNode.t(), ...]) ::
          Mud.Engine.Command.AstNode.CommandInput.t()
  def build_ast(ast_nodes) do
    Mud.Engine.Command.AstUtil.build_command_input_ast(ast_nodes)
  end

  @impl true
  def execute(context) do
    items =
      context.character
      |> Character.list_held_items()
      |> Enum.map(fn item ->
        if item.holdable_hand == "left" do
          Item.update!(item, %{holdable_hand: "right"})
        else
          Item.update!(item, %{holdable_hand: "left"})
        end
      end)

    case items do
      [item] ->
        other_msg =
          "{{character}}#{context.character.name}{{/character}} moves #{
            Item.short_description(item)
          } to their {{bodypart}}#{item.holdable_hand} hand{{/bodypart}}"

        msg =
          "{{item}}#{String.capitalize(Item.short_description(item))}{{/item}} is now in your {{bodypart}}#{
            item.holdable_hand
          } hand{{/bodypart}}."

        others = Character.list_active_in_areas(context.character.area_id)

        context
        |> ExecutionContext.append_output(
          others,
          other_msg,
          "info"
        )
        |> ExecutionContext.append_output(
          context.character.id,
          msg,
          "info"
        )
        |> ExecutionContext.set_success()

      [item1, item2] ->
        other_msg =
          "{{character}}#{context.character.name}{{/character}} moves #{
            Item.short_description(item1)
          } to their {{bodypart}}#{item1.holdable_hand} hand{{/bodypart}}, and #{
            Item.short_description(item2)
          } to their {{bodypart}}#{item2.holdable_hand} hand{{/bodypart}} hand."

        msg =
          "{{item}}#{String.capitalize(Item.short_description(item1))}{{/item}} is now in your {{bodypart}}#{
            item1.holdable_hand
          } hand{{/bodypart}}, and #{Item.short_description(item2)} is in your {{bodypart}}#{
            item2.holdable_hand
          } hand{{/bodypart}}."

        others =
          Character.list_others_active_in_areas(context.character.id, context.character.area_id)

        context
        |> ExecutionContext.append_output(
          others,
          other_msg,
          "info"
        )
        |> ExecutionContext.append_output(
          context.character.id,
          msg,
          "info"
        )
        |> ExecutionContext.set_success()

      [] ->
        ExecutionContext.append_output(
          context,
          context.character.id,
          "You aren't holding anything.",
          "error"
        )
        |> ExecutionContext.set_success()
    end
  end
end
