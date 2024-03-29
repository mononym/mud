defmodule Mud.Engine.Command.Open do
  @moduledoc """
  The OPEN command allows the Character to open something such as a door or a chest.

  Syntax:
    - open <target>

  Examples:
    - open backpack
    - open door
    - open pouch in backpack
  """

  alias Mud.Engine.Event.Client.{UpdateArea, UpdateInventory}
  alias Mud.Engine.Search
  alias Mud.Engine.Message
  alias Mud.Engine.Util
  alias Mud.Engine.Command.CallbackUtil
  alias Mud.Engine.Command.Context
  alias Mud.Engine.{Character, Item, ItemUtil, Link}
  alias Mud.Engine.Command.AstNode.ThingAndPlace, as: TAP
  alias Mud.Engine.Command.AstNode.{Thing, Place}
  alias Mud.Engine.Link.Closable

  require Logger

  use Mud.Engine.Command.Callback

  @spec build_ast([Mud.Engine.Command.AstNode.t(), ...]) ::
          Mud.Engine.Command.AstNode.ThingAndPlace.t()
  def build_ast(ast_nodes) do
    Mud.Engine.Command.AstUtil.build_tap_ast(ast_nodes)
  end

  @impl true
  def execute(context) do
    Logger.debug("Executing Open command")
    Logger.debug(inspect(context))
    ast = context.command.ast

    if is_nil(ast.thing) do
      Logger.debug("Open command entered without input. Returning error with command docs.")

      Context.append_message(
        context,
        Message.new_story_output(
          context.character.id,
          Util.get_module_docs(__MODULE__),
          "system_info"
        )
      )
    else
      # A UUID was passed in which means the open command is being attempted on a specific item.
      # This sort of command should only be triggered by the UI.
      if Util.is_uuid4(context.command.ast.thing.input) do
        Logger.debug("Open command provided with uuid: #{context.command.ast.thing.input}")

        open_link_or_item_by_uuid(context)
      else
        Logger.debug("Provided input was not a uuid: #{context.command.ast.thing.input}")

        # If there is input but that input is not a UUID, that means the player typed text in. Go searching for the item.
        find_thing_to_open(context)
      end
    end
  end

  defp open_link_or_item_by_uuid(context) do
    case Link.get(context.command.ast.thing.input) do
      {:ok, link} ->
        open_link(context, List.first(Search.things_to_match(link)))

      _ ->
        case Item.get(context.command.ast.thing.input) do
          {:ok, item} ->
            validate_item_for_open(context, List.first(Search.things_to_match(item)))

          _ ->
            Util.dave_error_v2(context)
        end
    end
  end

  defp open_link(context, thing = %Search.Match{}, other_matches \\ []) do
    link = thing.match
    # The link is coming from the correct room so we can continue
    if link.from_id == context.character.area_id do
      # It is possible to open/close this link, it is not owned by someone else, and it is closed
      cond do
        link.flags.closable and not link.closable.open ->
          # open_links_both_ways()
          # actually open it
          closable = Closable.update!(link.closable, %{open: true})
          link = %{link | closable: closable}

          context = CallbackUtil.maybe_open_opposite_link(context, link)

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
            |> Message.append_text(" opened ", "base")
            |> Message.append_text(
              link.short_description,
              Mud.Engine.Util.get_link_type(link)
            )
            |> Message.append_text(".", "base")

          # Create message to self
          self_msg =
            context.character.id
            |> Message.new_story_output()
            |> Message.append_text("You", "character")
            |> Message.append_text(" open ", "base")
            |> Message.append_text(
              link.short_description,
              Mud.Engine.Util.get_link_type(link)
            )
            |> Message.append_text(".", "base")

          # Append assumption message if there were other links found
          self_msg =
            if other_matches != [] do
              other_links = Enum.map(other_matches, & &1.match)

              CallbackUtil.append_assumption_text(
                self_msg,
                link,
                other_links,
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
            [context.character_id | others],
            UpdateArea.new(%{action: :update, exits: [link]})
          )

        link.flags.is_closable and link.closable.open ->
          upcased_desc = Mud.Engine.Util.upcase_first(link.short_description)

          # Create message to self
          self_msg =
            Message.new_story_output(
              context.character.id,
              "#{upcased_desc} is already open.",
              "system_alert"
            )

          # Append assumption message if there were other links found
          self_msg =
            if other_matches != [] do
              other_links = Enum.map(other_matches, & &1.match)

              CallbackUtil.append_assumption_text(
                self_msg,
                link,
                other_links,
                context.character.settings.commands.multiple_matches_mode,
                context.character
              )
            else
              self_msg
            end

          Context.append_message(
            context,
            self_msg
          )

        not link.flags.is_closable ->
          upcased_desc = Mud.Engine.Util.upcase_first(link.short_description)

          # Create message to self
          self_msg =
            Message.new_story_output(
              context.character.id,
              "#{upcased_desc} cannot be opened.",
              "system_alert"
            )

          # Append assumption message if there were other links found
          self_msg =
            if other_matches != [] do
              other_links = Enum.map(other_matches, & &1.match)

              CallbackUtil.append_assumption_text(
                self_msg,
                link,
                other_links,
                context.character.settings.commands.multiple_matches_mode,
                context.character
              )
            else
              self_msg
            end

          Context.append_message(
            context,
            self_msg
          )
      end
    else
      # Link is not coming from the correct room, where the player is, so give an error
      Util.dave_error_v2(context)
    end
  end

  defp find_thing_to_open(context = %Mud.Engine.Command.Context{}) do
    case context.command.ast do
      # Open thing on character
      # If nothing is found worn on the character do not look further
      %TAP{place: nil, thing: %Thing{personal: true}} ->
        Logger.debug("Item to Open should be on character")

        # open_worn_or_held_item_in_inventory(context)
        open_item_in_inventory(context)

      # Thing being opened did not have 'my' specified, but also no place either
      %TAP{place: nil, thing: %Thing{personal: false}} ->
        open_thing_in_area_or_inventory(context)

      # This thing will be in a place, but that place might not be on the character
      %TAP{place: %Place{personal: false}, thing: %Thing{personal: false}} ->
        open_item_with_place(context)

      # open thing in container on character
      %TAP{place: %Place{personal: place}, thing: %Thing{personal: thing}} when place or thing ->
        open_item_with_personal_place(context)
    end
  end

  defp open_item_in_inventory(context) do
    results =
      Search.find_matches_in_inventory(
        context.character.id,
        context.command.ast.thing.input,
        context.character.settings.commands.search_mode
      )

    case results do
      {:ok, matches} ->
        # then just handle results as normal
        handle_search_results(context, {:ok, matches})

      _ ->
        handle_search_results(context, results)
    end
  end

  defp handle_search_results(context, results) do
    case results do
      {:ok, [match]} ->
        validate_item_for_open(context, match)

      {:ok, all_matches = [match | matches]} ->
        case context.command.ast do
          # If which is greater than 0, then more than one match was anticipated.
          # Make sure provided selection is not more than the number of items that were found
          %TAP{thing: %Thing{which: which}}
          when is_integer(which) and which > 0 and which <= length(all_matches) ->
            validate_item_for_open(context, Enum.at(all_matches, which - 1))

          # If the user provided a number but it is greater than the number of items found,
          %TAP{thing: %Thing{which: which}} when which > 0 and which > length(all_matches) ->
            Util.not_found_error(context)

          _ ->
            case context.character.settings.commands.multiple_matches_mode do
              "silent" ->
                validate_item_for_open(context, match, [])

              "full path" ->
                validate_item_for_open(context, match, matches)

              "choose" ->
                Context.append_message(
                  context,
                  Message.new_story_output(
                    context.character.id,
                    "Multiple items were found, please be more specific.",
                    "system_alert"
                  )
                )
            end
        end

      _ ->
        Util.not_found_error(context)
    end
  end

  defp open_item_with_place(context) do
    # look for place on ground on in hands or worn
    area_results =
      Search.find_matches_relative_to_place_in_area(
        context.character.area_id,
        context.command.ast.thing,
        context.command.ast.place,
        context.character.settings.commands.search_mode
      )

    case area_results do
      {:ok, area_matches} when area_matches != [] ->
        handle_search_results(context, {:ok, area_matches})

      _ ->
        open_item_with_personal_place(context)
    end
  end

  defp open_item_with_personal_place(context) do
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

  defp open_thing_in_area_or_inventory(context) do
    case Search.find_exits_in_area(context.character.area_id, context.command.ast.thing.input) do
      {:ok, [link | rest]} ->
        open_link(context, link, rest)

      _ ->
        area_results =
          Search.find_matches_on_ground_and_surfaces_in_area(
            context.character.area_id,
            context.command.ast.thing.input,
            context.character.settings.commands.search_mode
          )

        case area_results do
          {:ok, area_matches} when area_matches != [] ->
            handle_search_results(context, {:ok, area_matches})

          _ ->
            open_item_in_inventory(context)
        end
    end
  end

  defp validate_item_for_open(context, thing = %Search.Match{}, other_matches \\ []) do
    in_area = Item.in_area?(thing.match.id, context.character.area_id)
    in_inventory = Item.in_inventory?(thing.match.id, context.character.id)
    available_for_look = ItemUtil.is_available_for_look?(thing.match)

    cond do
      (not in_area and not in_inventory) or not available_for_look ->
        Util.dave_error_v2(context)

      (in_area or in_inventory) and available_for_look and
          (not thing.match.flags.is_closable or not thing.match.flags.open) ->
        self_msg =
          context.character.id
          |> Message.new_story_output()
          |> Message.append_text(
            "You ",
            "character"
          )
          |> Message.append_text(
            "cannot open ",
            "system_warning"
          )
          |> CallbackUtil.construct_item_current_location_message(
            thing.match,
            context.character,
            "system_warning"
          )
          |> Message.append_text(
            ".",
            "system_warning"
          )

        Context.append_message(context, self_msg)

      (in_area or in_inventory) and thing.match.flags.open and available_for_look and
        thing.match.flags.is_closable and thing.match.closable.open ->
        self_msg =
          context.character.id
          |> Message.new_story_output()
          |> Message.append_text(
            "You ",
            "character"
          )
          |> Message.append_text(
            "cannot open ",
            "system_warning"
          )
          |> CallbackUtil.construct_item_current_location_message(
            thing.match,
            context.character,
            "system_warning"
          )
          |> Message.append_text(
            " as it is already open.",
            "system_warning"
          )

        Context.append_message(context, self_msg)

      (in_area or in_inventory) and thing.match.flags.open and available_for_look and
        thing.match.flags.is_closable and not thing.match.closable.open ->
        open_item(context, thing, other_matches)
    end
  end

  defp open_item(context, thing = %Search.Match{}, other_matches) do
    cond do
      # Is container and container is closed, meaning it can be opened
      thing.match.flags.has_pocket and thing.match.flags.is_closable and
          not thing.match.closable.open ->
        in_inventory = Item.in_inventory?(thing.match.id, context.character.id)

        closable =
          Item.Closable.update!(thing.match.closable, %{
            open: true
          })

        item = Map.put(thing.match, :closable, closable)

        others =
          Character.list_others_active_in_areas(
            context.character.id,
            context.character.area_id
          )

        other_msg =
          others
          |> Message.new_story_output()
          |> Message.append_text("[#{context.character.name}]", "character")
          |> Message.append_text(" opens ", "base")
          |> Message.append_text(item.description.short, Mud.Engine.Util.get_item_type(item))
          |> Message.append_text(".", "base")

        self_msg =
          context.character.id
          |> Message.new_story_output()
          |> Message.append_text("You", "character")
          |> Message.append_text(" open ", "base")

        self_msg =
          CallbackUtil.construct_item_current_location_message(
            self_msg,
            item,
            context.character
          )
          |> Message.append_text(".", "base")

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

        # for items that are not root items, check to see whether the update needs to go to inventory or the area
        context =
          cond do
            item.location.worn_on_character or item.location.held_in_hand or
                in_inventory ->
              Context.append_event(
                context,
                context.character_id,
                UpdateInventory.new(:update, item)
              )

            item.location.on_ground ->
              Context.append_event(
                context,
                [context.character_id | others],
                UpdateArea.new(%{action: :update, items: [item]})
              )
          end

        context
        |> Context.append_message(other_msg)
        |> Context.append_message(self_msg)

      # It is a container but the container is open,
      thing.match.flags.has_pocket and
          (not thing.match.flags.is_closable or
             (thing.match.flags.is_closable and thing.match.closable.open)) ->
        self_msg =
          context.character.id
          |> Message.new_story_output()
          |> Message.append_text(
            CallbackUtil.upcase_item_with_location(thing.match),
            Mud.Engine.Util.get_item_type(thing.match)
          )
          |> Message.append_text(" is already open.", "system_warning")

        self_msg =
          if other_matches != [] do
            other_items = Enum.map(other_matches, & &1.match)

            CallbackUtil.append_assumption_text(
              self_msg,
              thing.match,
              other_items,
              context.character.settings.commands.multiple_matches_mode,
              context.character
            )
          else
            self_msg
          end

        Context.append_message(context, self_msg)

      # Assume the thing is not a container
      true ->
        self_msg =
          context.character.id
          |> Message.new_story_output()
          |> Message.append_text(
            CallbackUtil.upcase_item_with_location(thing.match),
            Mud.Engine.Util.get_item_type(thing.match)
          )
          |> Message.append_text(" cannot be opened.", "system_alert")

        self_msg =
          if other_matches != [] do
            other_items = Enum.map(other_matches, & &1.match)

            CallbackUtil.append_assumption_text(
              self_msg,
              thing.match,
              other_items,
              context.character.settings.commands.multiple_matches_mode,
              context.character
            )
          else
            self_msg
          end

        Context.append_message(context, self_msg)
    end
  end
end
