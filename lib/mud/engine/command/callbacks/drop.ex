defmodule Mud.Engine.Command.Drop do
  @moduledoc """
  The DROP command allows a character to drop a held item onto the ground.

  Aliases for dropping items in the 'left', 'right', and 'all' hands have been provided.

  Syntax:
    - drop BOTH | ALL| LEFT | RIGHT | <item>

  Examples:
    - drop sword
    - drop left
    - drop both
    - drop all
  """

  use Mud.Engine.Command.Callback

  alias Mud.Engine.Event.Client.{UpdateArea, UpdateInventory}
  alias Mud.Engine.Search
  alias Mud.Engine.Util
  alias Mud.Engine.Command.Context
  alias Mud.Engine.{Character, Item}
  alias Mud.Engine.Item.Location
  alias Mud.Engine.Message
  alias Mud.Engine.Command.CallbackUtil

  require Logger

  @spec build_ast([Mud.Engine.Command.AstNode.t(), ...]) ::
          Mud.Engine.Command.AstNode.OneThing.t()
  def build_ast(ast_nodes) do
    Mud.Engine.Command.AstUtil.build_one_thing_ast(ast_nodes)
  end

  @impl true
  def execute(context) do
    Logger.debug("Executing Drop command")
    Logger.debug(inspect(context))
    ast = context.command.ast

    if is_nil(ast.thing) do
      Logger.debug("Drop command entered without input. Returning error with command docs.")

      Context.append_message(
        context,
        Message.new_story_output(
          context.character.id,
          Util.get_module_docs(__MODULE__),
          "system_info"
        )
      )
    else
      # A UUID was passed in which means the drop command is being attempted on a specific item.
      # This sort of command should only be triggered by the UI.
      if Util.is_uuid4(context.command.ast.thing.input) do
        Logger.debug("Drop command provided with uuid: #{context.command.ast.thing.input}")

        drop_item_by_uuid(context)
      else
        Logger.debug("Provided input was not a uuid: #{context.command.ast.thing.input}")

        # If there is input but that input is not a UUID, that means the player typed text in. Go searching for the item.
        find_thing_to_drop(context)
      end
    end
  end

  defp drop_item_by_uuid(context) do
    case Item.get(context.command.ast.thing.input) do
      {:ok, item} ->
        drop_item(context, List.first(Search.things_to_match(item)))

      _ ->
        Util.dave_error_v2(context)
    end
  end

  defp get_item_from_hand_as_matches_list(character_id, hand) do
    Item.get_item_in_hand_as_list(character_id, hand)
    |> Search.things_to_match()
  end

  defp get_items_from_hands_as_matches_list(character_id) do
    Item.list_items_in_hands(character_id)
    |> Search.things_to_match()
  end

  defp find_thing_to_drop(context = %Mud.Engine.Command.Context{}) do
    input = context.command.ast.thing.input

    case input do
      "left" ->
        matches = get_item_from_hand_as_matches_list(context.character.id, "left")

        if length(matches) == 1 do
          drop_item(context, List.first(matches))
        else
          Util.hand_already_empty(context, input)
        end

      "right" ->
        matches = get_item_from_hand_as_matches_list(context.character.id, "right")

        if length(matches) == 1 do
          drop_item(context, List.first(matches))
        else
          Util.hand_already_empty(context, input)
        end

      "both" ->
        case get_items_from_hands_as_matches_list(context.character.id) do
          [] ->
            Util.hands_already_empty(context)

          matches ->
            matches = CallbackUtil.sort_held_matches(matches, context.character.physical_features.dominant_hand)

            # then just handle results as normal
            Enum.reduce(matches, context, fn match, context ->
              drop_item(context, match)
            end)
        end

      "all" ->
        case get_items_from_hands_as_matches_list(context.character.id) do
          [] ->
            Util.hands_already_empty(context)

          matches ->
            matches = CallbackUtil.sort_held_matches(matches, context.character.physical_features.dominant_hand)

            # then just handle results as normal
            Enum.reduce(matches, context, fn match, context ->
              drop_item(context, match)
            end)
        end

      _ ->
        results =
          Search.find_matches_in_held_items(
            context.character.id,
            input,
            context.character.settings.commands.search_mode
          )

        case results do
          {:ok, matches} ->
            [first | last] = CallbackUtil.sort_held_matches(matches, context.character.physical_features.dominant_hand)

            # then just handle results as normal
            drop_item(context, first, List.wrap(last))

          _ ->
            Util.not_found_error(context)
        end
    end
  end

  defp drop_item(context, thing = %Search.Match{}, other_matches \\ []) do
    original_item = thing.match
    # double check that the thing is held in the hand
    # if thing is held in hand, drop it and send out messages
    # if thing is not held in hand of character, send out dave message
    if original_item.location.held_in_hand and
         original_item.location.character_id == context.character.id do
      location =
        Location.update_on_ground_item!(original_item.location, context.character.area_id)

      item = %{original_item | location: location}

      # get other characters for messaging
      others =
        Character.list_others_active_in_areas(
          context.character.id,
          context.character.area_id
        )

      # create message to others
      other_msg =
        others
        |> Message.new_story_output()
        |> Message.append_text("[#{context.character.name}]", "character")
        |> Message.append_text(" dropped ", "base")
        |> Message.append_text(
          item.description.short,
          Mud.Engine.Util.get_item_type(item)
        )
        |> Message.append_text(".", "base")

      # Create message to self
      self_msg =
        context.character.id
        |> Message.new_story_output()
        |> Message.append_text("You", "character")
        |> Message.append_text(" drop ", "base")
        |> Message.append_text(
          item.description.short,
          Mud.Engine.Util.get_item_type(item)
        )
        |> Message.append_text(".", "base")

      # Append assumption message if there were other links found
      self_msg =
        if other_matches != [] do
          other_items = Enum.map(other_matches, & &1.match)

          CallbackUtil.append_assumption_text(
            self_msg,
            item,
            other_items,
            context.character.settings.commands.multiple_matches_mode,
            context.character
          )
        else
          self_msg
        end

      all_items_to_update = Item.list_all_recursive_children(item, true)

      context
      |> Context.append_message(other_msg)
      |> Context.append_message(self_msg)
      |> Context.append_event(
        context.character_id,
        UpdateInventory.new(%{action: :remove, items: all_items_to_update})
      )
      |> Context.append_event(
        [context.character_id | others],
        UpdateArea.new(%{
          action: :add,
          items: Item.list_all_recursive_surface_children(original_item)
        })
      )
    else
      Util.dave_error_v2(context)
    end
  end
end
