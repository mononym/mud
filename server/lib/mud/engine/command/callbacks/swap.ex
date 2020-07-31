defmodule Mud.Engine.Command.Swap do
  @moduledoc """
  The SWAP command switches items held by a character between their hands.

  Syntax:
    - swap
  """

  use Mud.Engine.Command.Callback

  alias Mud.Engine.Event.Client.UpdateInventory
  alias Mud.Engine.Command.Context
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

    context =
      Context.append_event(
        context,
        context.character_id,
        UpdateInventory.new(:update, items)
      )

    case items do
      [item] ->
        other_msg =
          "{{character}}#{context.character.name}{{/character}} moves #{item.short_description} to their {{bodypart}}#{
            item.holdable_hand
          } hand{{/bodypart}}"

        msg =
          "{{item}}#{String.capitalize(item.short_description)}{{/item}} is now in your {{bodypart}}#{
            item.holdable_hand
          } hand{{/bodypart}}."

        others = Character.list_active_in_areas(context.character.area_id)

        context
        |> Context.append_output(
          others,
          other_msg,
          "info"
        )
        |> Context.append_output(
          context.character.id,
          msg,
          "info"
        )

      [item1, item2] ->
        other_msg =
          "{{character}}#{context.character.name}{{/character}} moves #{item1.short_description} to their {{bodypart}}#{
            item1.holdable_hand
          } hand{{/bodypart}}, and #{item2.short_description} to their {{bodypart}}#{
            item2.holdable_hand
          } hand{{/bodypart}} hand."

        msg =
          "{{item}}#{String.capitalize(item1.short_description)}{{/item}} is now in your {{bodypart}}#{
            item1.holdable_hand
          } hand{{/bodypart}}, and #{item2.short_description} is in your {{bodypart}}#{
            item2.holdable_hand
          } hand{{/bodypart}}."

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
          msg,
          "info"
        )

      [] ->
        Context.append_output(
          context,
          context.character.id,
          "You aren't holding anything.",
          "error"
        )
    end
  end
end
