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
  alias Mud.Engine.Command.CallbackUtil
  alias Mud.Engine.Command.Context
  alias Mud.Engine.Message
  alias Mud.Engine.Search
  alias Mud.Engine.{Character, Item}
  alias Mud.Engine.Item.Location

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
      Context.append_output(
        context,
        context.character.id,
        Util.get_module_docs(__MODULE__),
        "error"
      )
    else
      if Util.is_uuid4(ast.thing.input) do
        item = Item.get!(ast.thing.input)

        if item.location.held_in_hand and item.location.character_id == context.character.id do
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
    results =
      Search.find_matches_in_held_items(
        context.character.id,
        context.command.ast.thing.input,
        context.character.settings.commands.search_mode
      )

    case results do
      {:ok, matches} ->
        [first | last] = CallbackUtil.sort_held_matches(matches, context.character.handedness)

        # then just handle results as normal
        wear_thing(context, first, List.wrap(last))

      _ ->
        Util.not_found_error(context)
    end
  end

  @spec wear_thing(Context.t(), Mud.Engine.Item.t()) :: Context.t()
  defp wear_thing(context, match, other_matches \\ []) do
    original_item = match.match

    if original_item.flags.wearable and original_item.flags.wear do
      location = Location.update_worn_item!(original_item.location, context.character.id)

      item = %{original_item | location: location}

      others =
        Character.list_others_active_in_areas(context.character.id, context.character.area_id)

      {how, where} = Util.item_wearable_slot_to_description_string(item.wearable)

      other_msg =
        [context.character.id | others]
        |> Message.new_story_output()
        |> Message.append_text("#{context.character.name}", "character")
        |> Message.append_text(" wears ", "base")
        |> Message.append_text(item.description.short, Util.get_item_type(item))
        |> Message.append_text(
          " #{how} #{Util.his_her_their(context.character)} #{where}.",
          "base"
        )

      self_msg =
        context.character.id
        |> Message.new_story_output()
        |> Message.append_text("You", "character")
        |> Message.append_text(" wear ", "base")
        |> Message.append_text(item.description.short, Util.get_item_type(item))
        |> Message.append_text(
          " #{how} your #{where}.",
          "base"
        )

      self_msg =
        if other_matches != [] do
          other_items = Enum.map(other_matches, & &1.match)

          Util.append_assumption_text(
            self_msg,
            original_item,
            other_items,
            context.character.settings.commands.multiple_matches_mode
          )
        else
          self_msg
        end

      context
      |> Context.append_message(other_msg)
      |> Context.append_message(self_msg)
      |> Context.append_event(
        context.character_id,
        UpdateInventory.new(:update, item)
      )
    else
      error_message =
        Message.new_story_output(
          context.character.id,
          Util.upcase_first(original_item.description.short),
          Util.get_item_type(original_item)
        )
        |> Message.append_text(
          " cannot be worn.",
          "system_alert"
        )

      Context.append_message(context, error_message)
    end
  end
end
