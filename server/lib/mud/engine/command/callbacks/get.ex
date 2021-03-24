defmodule Mud.Engine.Command.Get do
  @moduledoc """
  The GET command allows the Character to get something from the ground or relative to other items.

  In the case that an item is `in` or `on` another item, such as a sword on a counter or a gem in a box, it is not necessary to specify the exact relationship between the items. The engine will automatically detect the relationship, meaning you can simply use `from` without having to think about it.

  Syntax:
    - get <item> [from <place>]

  Examples:
    - get backpack
    - get my sword
    - get pouch from my backpack
    - get truffle from tray
    - get topaz from pouch from backpack
  """

  alias Mud.Engine.Event.Client.{UpdateArea, UpdateCharacter, UpdateInventory}
  alias Mud.Engine.Search
  alias Mud.Engine.Message
  alias Mud.Engine.Util
  alias Mud.Engine.Command.CallbackUtil
  alias Mud.Engine.Command.Context
  alias Mud.Engine.{Character, Item}
  alias Mud.Engine.Command.AstNode.ThingAndPlace, as: TAP
  alias Mud.Engine.Command.AstNode.{Thing, Place}
  alias Mud.Engine.Item.Location

  require Logger

  use Mud.Engine.Command.Callback

  # The process which executes the command logic first calls this method to have it parse the raw command AST nodes
  # into something that the actual command execution logic expects and can more easily use.

  # In some cases this may not even really be necessary, or at least it can act as simply a passthrough and :ok
  # can be returned.
  @spec build_ast([Mud.Engine.Command.AstNode.t(), ...]) ::
          Mud.Engine.Command.AstNode.ThingAndPlace.t()
  def build_ast(ast_nodes) do
    Mud.Engine.Command.AstUtil.build_tap_ast(ast_nodes)
  end

  # This is where the actual execution of the command takes place.
  # At this point the execution context (found at: lib/mud/engine/command/execution_context.ex) is populated and the
  # build_ast function above has been called.
  @impl true
  def execute(context) do
    Logger.debug("Executing Get command")
    Logger.debug(inspect(context))
    # Extract the ast for ease of access
    ast = context.command.ast

    # If, when building up the ThingAndPlace AST, no 'thing' is discovered that means that the command was sent through
    # 'naked'. In other words, someone entered 'get' with no other text. While this might be valid in the context of
    # some commands, for 'get' this obviously doesn't make sense. Return an error.
    if is_nil(ast.thing) do
      Logger.debug("Get command entered without input. Returning error with command docs.")

      # All communication, events, and every async action kicked off by the execution of a command **MUST** be attached
      # to the context in the form of a data structure describing what is to be done. This is because all of the code
      # in this callback module is executed in the context of a single serialized database transaction. That means that
      # this code might be executed an arbitrary number of times due to serialization errors at the database level.
      # See: https://sqlperformance.com/2014/04/t-sql-queries/the-serializable-isolation-level
      #
      # By attaching all outgoing message/events to the context we can avoid duplicate messages being sent out, and even
      # messages being sent out that are rendered invalid due to an error in execution *after* they were sent.
      #
      # This method is for attaching messages, which at the time of writing this text includes only a single type which is
      # the story window output.
      Context.append_message(
        context,
        # This message type is for sending text to the client for it to appear in the primary "Story Window"
        Message.new_story_output(
          context.character.id,
          Util.get_module_docs(__MODULE__),
          # The text 'type' determines that color that text will take on in the front end. Every single type of text is
          # configurable by the end user when it comes to the game client, so they can have the colors they want.
          "system_info"
        )
      )
    else
      # A UUID was passed in which means the get command is being attempted on a specific item.
      # This sort of command should only be triggered by the UI. But it is possible for a user
      # to specifically and manually enter a UUID.
      if Util.is_uuid4(context.command.ast.thing.input) do
        Logger.debug("Get command provided with uuid: #{context.command.ast.thing.input}")

        # Get the item based on the UUID passed in.
        case Item.get(context.command.ast.thing.input) do
          {:ok, item} ->
            # Wrap the item up as if it were a search result before passing it into the final method which will do
            # the proper security checks and actually execute the modification of the item data.
            get_item(context, List.first(Search.things_to_match(item)))

          _ ->
            # Somehow a UUID was entered that does not match up with an existing item. Outside of a bug in the system,
            # this should only occur if someone is trying to get fresh. Subtly nudge them with an error.
            Util.dave_error_v2(context)
        end
      else
        Logger.debug("Provided input was not a uuid: #{context.command.ast.thing.input}")

        # If there is input but that input is not a UUID, that means the player typed text in. Go searching for the item.
        find_thing_to_get(context)
      end
    end
  end

  # This method is used when trying to search for an item via text passed in with the command
  defp find_thing_to_get(context = %Mud.Engine.Command.Context{}) do
    case context.command.ast do
      # Someone typed in something like 'get my robe', so get the item from character inventory
      %TAP{place: nil, thing: %Thing{personal: true}} ->
        get_item_in_inventory(context)

      # Someone typed in something like 'get robe', so first try to get something from the area, and if that doesn't
      # work fallback to the inventory
      %TAP{place: nil, thing: %Thing{personal: false}} ->
        get_item_in_area_or_inventory(context)

      # This thing will be in a place, but that place might not be on the character. So they typed: 'get robe from pack'
      %TAP{place: %Place{personal: false}, thing: %Thing{personal: false}} ->
        get_item_with_place(context)

      # Not only is the item in a thing, but it's somewhere on the character: get my lockpick from sack
      %TAP{place: %Place{personal: place}, thing: %Thing{personal: thing}} when place or thing ->
        get_item_with_personal_place(context)
    end
  end

  # Search the inventory for an item matching a text string
  defp get_item_in_inventory(context) do
    # Check the DB for any items in the character's inventory which match the input provided to the 'get' command
    results =
      Search.find_matches_in_inventory(
        context.character.id,
        context.command.ast.thing.input,
        context.character.settings.commands.search_mode
      )

    case results do
      {:ok, matches} ->
        # Make sure the results are sorted for consistent behavior
        sorted_results = CallbackUtil.sort_matches(matches, true)

        # then just handle results as normal
        handle_search_results(context, {:ok, sorted_results})

      _ ->
        handle_search_results(context, results)
    end
  end

  # Handles the logistics around single matches, multiple matches, and allowing the selection of one of a number of
  # possible matches via the original command. For example, you could type in 'get 2 rock' and it would get the
  # second item that matched 'rock' instead of the first one as would be normal.
  defp handle_search_results(context, results) do
    case results do
      # There is only a single match and the player did not try and specify a specific item so just roll with that.
      {:ok, [match]} when context.command.ast.thing.which == 0 ->
        get_item(context, match)

      # There are possibly multiple matches, but the player might also have specified a specific item
      {:ok, all_matches = [match | matches]} ->
        case context.command.ast do
          # If which is greater than 0, then more than one match was anticipated and the player entered a number.
          # Make sure provided selection is not more than the number of items that were found
          %TAP{thing: %Thing{which: which}}
          when is_integer(which) and which > 0 and which <= length(all_matches) ->
            get_item(context, Enum.at(all_matches, which - 1))

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
                get_item(context, match, [])

              key when key in ["item only", "full path"] ->
                # If their choice is "full path" or "item only" that means pass everything through for generating messages later
                get_item(context, match, matches)

              "choose" ->
                Context.append_message(
                  context,
                  Message.new_story_output(
                    context.character.id,
                    "Multiple places to put things were found, please be more specific.",
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

  # The command entered was something like: get chest from pack
  defp get_item_with_place(context) do
    # look for place on ground in hands or worn
    area_results =
      Search.find_matches_relative_to_place_in_area(
        context.character.area_id,
        context.command.ast.thing,
        context.command.ast.place,
        context.character.settings.commands.search_mode
      )

    case area_results do
      {:ok, area_matches} when area_matches != [] ->
        handle_search_results(context, {:ok, CallbackUtil.sort_matches(area_matches, true)})

      _ ->
        get_item_with_personal_place(context)
    end
  end

  # The command entered was something like: get chest from my pack
  defp get_item_with_personal_place(context) do
    # look for the item you are trying to get, such as a rock, somewhere inside the inventory and make sure to only find something that actually has the right parents
    results =
      Search.find_matches_relative_to_place_in_inventory(
        context.character.id,
        context.command.ast.thing,
        context.command.ast.place,
        context.character.settings.commands.search_mode,
        false
      )

    handle_search_results(context, results)
  end

  # Checks the area for an item and if nothing is found moves on to the inventory
  defp get_item_in_area_or_inventory(context) do
    area_results =
      Search.find_matches_on_ground(
        context.character.area_id,
        context.command.ast.thing.input,
        context.character.settings.commands.search_mode
      )

    case area_results do
      {:ok, area_matches} when area_matches != [] ->
        handle_search_results(context, {:ok, CallbackUtil.sort_matches(area_matches, true)})

      _ ->
        get_item_on_visible_surfaces_in_area_or_inventory(context)
    end
  end

  # Checks the area for an item and if nothing is found moves on to the inventory
  defp get_item_on_visible_surfaces_in_area_or_inventory(context) do
    area_results =
      Search.find_matches_on_visible_surfaces(
        context.character.area_id,
        context.command.ast.thing.input,
        context.character.settings.commands.search_mode
      )

    case area_results do
      {:ok, area_matches} when area_matches != [] ->
        handle_search_results(context, {:ok, CallbackUtil.sort_matches(area_matches, true)})

      _ ->
        get_item_in_inventory(context)
    end
  end

  # This is the far-too-large function that needs to be broken up that is where all the magic happens
  defp get_item(context, thing = %Search.Match{}, other_matches \\ []) do
    # first, check to make sure the hands are not completely full
    items_in_hands = Item.list_items_in_hands(context.character.id)

    # If they are toss up a warning and we're done.
    if length(items_in_hands) == 2 do
      Util.hands_full_error(context)
    else
      original_item = thing.match

      # No matter how we got here, this is where we're going to check and make sure that the item being gotten is in
      # an appropriate place. This closes the security hole of UUID's along with other potential ones as well.
      in_area = Item.in_area?(original_item.id, context.character.area_id)
      in_inventory = Item.in_inventory?(original_item.id, context.character.id)

      # TODO: This assumes anything not in a container is on a surface all the way down. Is this good enough? Does this
      # need a more intense check? Investigate.
      available =
        if original_item.location.relative_to_item and original_item.location.relation == "on" do
          true
        else
          Item.parent_containers_open?(original_item)
        end

      cond do
        # This is the happy case where the item is where it is supposed to be and it is not inside any closed containers
        available and
            (in_area or
               (in_inventory and
                  not (original_item.location.held_in_hand or
                           original_item.location.worn_on_character))) ->
          actually_factually_get_the_item(
            context,
            original_item,
            other_matches,
            items_in_hands,
            in_area
          )

        # Not as happy, but the only problem is that one of the parent containers is closed
        not available and
            (in_area or
               (in_inventory and
                  not (original_item.location.held_in_hand or
                           original_item.location.worn_on_character))) ->
          parent_containers = Item.list_sorted_parent_containers(original_item)
          # If a parent is closed, warn the player
          CallbackUtil.parent_containers_closed_error(context, original_item, parent_containers)

        # The found item is already in the hands, so tell the player about that.
        in_inventory and original_item.location.held_in_hand ->
          self_msg =
            context.character.id
            |> Message.new_story_output()
            |> Message.append_text("You", "character")
            |> Message.append_text(" are already holding ", "base")
            |> Message.append_text(
              original_item.description.short,
              Mud.Engine.Util.get_item_type(original_item)
            )
            |> Message.append_text(".", "base")

          Context.append_message(context, self_msg)

        # The found item is worn on the character, so tell them about that.
        in_inventory and original_item.location.worn_on_character ->
          self_msg =
            context.character.id
            |> Message.new_story_output()
            |> Message.append_text("You", "character")
            |> Message.append_text(" are wearing ", "base")
            |> Message.append_text(
              original_item.description.short,
              Mud.Engine.Util.get_item_type(original_item)
            )
            |> Message.append_text(". If you wish, you may REMOVE it instead.", "base")

          Context.append_message(context, self_msg)

        # If the item is not in the area AND not in the inventory then something is very wrong. Outside of a system bug
        # this could mean the player is trying to be sly by entering a UUID themselves.
        not in_area and not in_inventory ->
          Util.dave_error_v2(context)
      end
    end
  end

  defp actually_factually_get_the_item(
         context,
         original_item,
         other_matches,
         items_in_hands,
         in_area
       ) do
    cond do
      # Make sure the coin can also be held
      original_item.flags.coin and original_item.flags.hold ->
        pick_up_yer_coins(context, original_item)

      # Item can be held which means it can be picked up
      original_item.flags.hold ->
        pick_up_yer_item(context, original_item, other_matches, items_in_hands, in_area)

      # Item cannot be picked up so need to throw a warning
      not original_item.flags.hold ->
        self_msg =
          context.character.id
          |> Message.new_story_output()
          |> Message.append_text(
            Util.upcase_first(
              Item.items_to_short_desc_with_nested_location_without_item(original_item)
              |> List.first()
            ),
            Mud.Engine.Util.get_item_type(original_item)
          )
          |> Message.append_text(" cannot be picked up.", "system_alert")

        Context.append_message(context, self_msg)
    end
  end

  # Take a guess what this one does
  defp pick_up_yer_item(context, original_item, other_matches, items_in_hands, in_area) do
    # As flavoring, figure out where to put the item based on what is in the hands and what the character's handedness
    # preference is set to.
    hand =
      cond do
        length(items_in_hands) == 0 ->
          context.character.handedness

        true ->
          if List.first(items_in_hands).location.hand == "right" do
            "left"
          else
            "right"
          end
      end

    # The items along the path to where the item being 'gotten' is are used to construct messages for the player and for others.
    items_in_path = Item.list_full_path(original_item)

    # The other characters in an area that should be alerted with a message.
    others =
      Character.list_others_active_in_areas(
        context.character.id,
        context.character.area_id
      )

    # Start construction of the message to the other players.
    other_msg =
      [context.character.id | others]
      |> Message.new_story_output()
      |> Message.append_text("#{context.character.name}", "character")
      |> Message.append_text(" gets ", "base")

    # For other characters, they only end up seeing the outermost item in the chain of nested items, if there is any.
    other_msg =
      Util.construct_nested_item_location_message_for_others(
        context.character,
        other_msg,
        original_item,
        items_in_path,
        in_area,
        "from"
      )
      |> Message.append_text(".", "base")

    # Start construction of the message to character which the command is being executed for.
    self_msg =
      context.character.id
      |> Message.new_story_output()
      |> Message.append_text("You", "character")
      |> Message.append_text(" get ", "base")

    # The whole chain of containers, assuming there is a nested chain of containers, to where the item being 'gotten' is
    # will be used to generate the message.
    self_msg =
      Util.construct_nested_item_location_message_for_self(
        self_msg,
        original_item,
        "from",
        true
      )
      |> Message.append_text(".", "base")

    # Potentially add a message warning about "other matching items" based on character preferences.
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

    # Update the actual item data in the database
    location = Location.update_held_item!(original_item.location, context.character.id, hand)

    # Update in memory copy of item for sending to the client
    item = Map.put(original_item, :location, location)

    # check to see whether the update needs to go to only inventory or the area too
    context =
      if in_area do
        # It is very possible the update changed the location in a way that might cause some oddities in the front end.
        # Grab everything for this item and all potential children and update them.
        # Keep an eye on this though as this is potentially very expensive and there are probably far better ways to address this.
        all_items_to_update = Item.list_all_recursive_children(item)

        # Send an update for the "area" to all characters in an area. This will tell the clients to remove this list of items to start the reset.
        context
        |> Context.append_event(
          [context.character_id | others],
          UpdateArea.new(%{action: :remove, items: all_items_to_update})
        )
        # Send an update for the "area" to all characters in an area. This will tell the clients to remove this list of items to end the reset.
        |> Context.append_event(
          context.character_id,
          UpdateInventory.new(:add, all_items_to_update)
        )
      else
        # Since the item wasn't in the area, which means it was somewhere in the inventory instead, only need to update the character
        # executing the command as far as actual inventory.
        Context.append_event(
          context,
          context.character_id,
          UpdateInventory.new(:update, item)
        )
      end

    # Add the messages for everyone.
    context
    |> Context.append_message(other_msg)
    |> Context.append_message(self_msg)
  end

  defp pick_up_yer_coins(context, original_item) do
    wealth_attrs =
      CallbackUtil.coin_to_wealth_update_attrs(
        original_item.coin,
        context.character.wealth
      )

    # Update character wealth. This is what is shown on the character when they type.......wealth
    updated_wealth = Mud.Engine.Character.Wealth.update!(context.character.wealth, wealth_attrs)

    # Attach updated data to character for updating front end client
    character = Map.put(context.character, :wealth, updated_wealth)

    # Delete coins since they don't really exist and don't need to be moved
    Item.delete(original_item)

    # Make other people jealous of lootz
    others =
      Character.list_others_active_in_areas(
        context.character.id,
        context.character.area_id
      )

    # Should be pretty obvious
    other_msg =
      others
      |> Message.new_story_output()
      |> Message.append_text("[#{context.character.name}]", "character")
      |> Message.append_text(" picks up ", "base")
      |> Message.append_text(
        CallbackUtil.coin_to_count_string(original_item.coin),
        Mud.Engine.Util.get_item_type(original_item)
      )
      |> Message.append_text(".", "base")

    # Character picking up coins probably wants to know how many
    self_msg =
      context.character.id
      |> Message.new_story_output()
      |> Message.append_text("You", "character")
      |> Message.append_text(" pick up ", "base")
      |> Message.append_text(
        CallbackUtil.coin_to_count_string(original_item.coin),
        Mud.Engine.Util.get_item_type(original_item)
      )
      |> Message.append_text(".", "base")

    # Make sure the coins are deleted from everyone's client, and that the character with the updated wealth gets the
    # event. And of course messages for everyone.
    context
    |> Context.append_event(
      character.id,
      UpdateCharacter.new(%{action: "wealth", wealth: updated_wealth})
    )
    |> Context.append_event(
      [context.character_id | others],
      UpdateArea.new(%{action: :remove, items: [original_item]})
    )
    |> Context.append_message(other_msg)
    |> Context.append_message(self_msg)
  end
end
