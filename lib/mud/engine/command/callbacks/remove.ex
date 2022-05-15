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
  alias Mud.Engine.Item.Location
  alias Mud.Engine.Character
  alias Mud.Engine.Command.Context
  alias Mud.Engine.Command.CallbackUtil
  alias Mud.Engine.Util
  alias Mud.Engine.Search
  alias Mud.Engine.Command.AstNode.ThingAndPlace, as: TAP
  alias Mud.Engine.Command.AstNode.{Thing}
  alias Mud.Engine.Message

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

        if item.location.character_id == context.character.id do
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
    ast = context.command.ast

    matches =
      Search.find_matches_in_worn_items(
        context.character.id,
        ast.thing.input,
        context.character.settings.commands.search_mode
      )

    case matches do
      # There is only a single match and the player did not try and specify a specific item so just roll with that.
      {:ok, [match]} when context.command.ast.thing.which == 0 ->
        remove_thing(context, match.match)

      # There are possibly multiple matches, but the player might also have specified a specific item
      {:ok, all_matches = [match | matches]} ->
        case context.command.ast do
          # If which is greater than 0, then more than one match was anticipated and the player entered a number.
          # Make sure provided selection is not more than the number of items that were found
          %TAP{thing: %Thing{which: which}}
          when is_integer(which) and which > 0 and which <= length(all_matches) ->
            remove_thing(context, Enum.at(all_matches, which - 1).match)

          # If the user provided a number but it is greater than the number of items found,
          %TAP{thing: %Thing{which: which}} when which > 0 and which > length(all_matches) ->
            Util.not_found_error(context)

          # The user did not preselect an item and we're just dealing with multiple matches. Fall through to the
          # normal get_item function.
          _ ->
            # Determine what to do based on character preferences when it comes to multiple potential matches.
            case context.character.settings.commands.multiple_matches_mode do
              "silent" ->
                # If their choice is "silent" that means just drop the extras so it is like they don't exist
                remove_thing(context, match)

              key when key in ["item only", "full path"] ->
                # If their choice is "full path" or "item only" that means pass everything through for generating messages later
                remove_thing(context, match, matches)

              "choose" ->
                Context.append_message(
                  context,
                  Message.new_story_output(
                    context.character.id,
                    "Multiple possible matches found, please be more specific.",
                    "system_alert"
                  )
                )
            end
        end

      # No results were found so return a standard error.
      _ ->
        Util.not_found_error(context)
    end
  end

  defp remove_thing(context, original_item, other_matches \\ []) do
    held_items = Character.list_held_items(context.character)

    if length(held_items) < 2 do
      target_hand =
        if length(held_items) == 1 do
          [%{location: %{hand: hand}}] = held_items

          if hand == "right" do
            "left"
          else
            "right"
          end
        else
          context.character.handedness
        end

      updated_location =
        Location.update_held_item!(original_item.location, context.character.id, target_hand)

      item = %{original_item | location: updated_location}

      others =
        Character.list_others_active_in_areas(context.character.id, context.character.area_id)

      other_msg =
        [context.character.id | others]
        |> Message.new_story_output()
        |> Message.append_text(context.character.name, "character")
        |> Message.append_text(" removed ", "base")
        |> Message.append_text(
          item.description.short,
          Mud.Engine.Util.get_item_type(item)
        )
        |> Message.append_text(".", "base")

      self_msg =
        context.character.id
        |> Message.new_story_output()
        |> Message.append_text("You", "character")
        |> Message.append_text(" remove ", "base")
        |> Message.append_text(
          item.description.short,
          Mud.Engine.Util.get_item_type(item)
        )
        |> Message.append_text(".", "base")

      # Potentially add a message warning about "other matching items" based on character preferences.
      self_msg =
        if other_matches != [] do
          other_items = Enum.map(other_matches, & &1.match)

          CallbackUtil.append_assumption_text(
            self_msg,
            original_item,
            other_items,
            context.character.settings.commands.multiple_matches_mode,
            context.character
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
      Util.hands_full_error(context)
    end
  end
end
