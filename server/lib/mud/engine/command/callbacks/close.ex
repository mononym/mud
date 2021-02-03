defmodule Mud.Engine.Command.Close do
  @moduledoc """
  The CLOSE command allows the Character to close something such as a door or a chest.

  Syntax:
    - close <target>

  Examples:
    - close backpack
    - close door
    - close pouch in backpack
  """

  alias Mud.Engine.Event.Client.{UpdateArea, UpdateInventory}
  alias Mud.Engine.Search
  alias Mud.Engine.Message
  alias Mud.Engine.Util
  alias Mud.Engine.Command.CallbackUtil
  alias Mud.Engine.Command.Context
  alias Mud.Engine.{Character, Item, Link}
  alias Item.{Container}
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
    Logger.debug("Executing Close command")
    Logger.debug(inspect(context))
    ast = context.command.ast

    if is_nil(ast.thing) do
      Logger.debug("Close command entered without input. Returning error with command docs.")

      Context.append_message(
        context,
        Message.new_story_output(
          context.character.id,
          Util.get_module_docs(__MODULE__),
          "system_info"
        )
      )
    else
      # A UUID was passed in which means the close command is being attempted on a specific item.
      # This sort of command should only be triggered by the UI.
      if Util.is_uuid4(context.command.ast.thing.input) do
        Logger.debug("Close command provided with uuid: #{context.command.ast.thing.input}")

        close_link_or_item_by_uuid(context)
      else
        Logger.debug("Provided input was not a uuid: #{context.command.ast.thing.input}")

        # If there is input but that input is not a UUID, that means the player typed text in. Go searching for the item.
        find_thing_to_close(context)
      end
    end
  end

  defp close_link_or_item_by_uuid(context) do
    case Link.get(context.command.ast.thing.input) do
      {:ok, link} ->
        close_link(context, List.first(Search.things_to_match(link)))

      _ ->
        case Item.get(context.command.ast.thing.input) do
          {:ok, item} ->
            close_item(context, List.first(Search.things_to_match(item)))

          _ ->
            Util.dave_error_v2(context)
        end
    end
  end

  defp find_thing_to_close(context = %Mud.Engine.Command.Context{}) do
    case context.command.ast do
      # Close thing on character
      # If nothing is found worn on the character do not look further
      %TAP{place: nil, thing: %Thing{personal: true}} ->
        Logger.debug("Item to Close should be on character")

        # close_worn_or_held_item_in_inventory(context)
        close_item_in_inventory(context)

      # Thing being closeed did not have 'my' specified, but also no place either
      %TAP{place: nil, thing: %Thing{personal: false}} ->
        close_item_in_area_or_inventory(context)

      # This thing will be in a place, but that place might not be on the character
      %TAP{place: %Place{personal: false}, thing: %Thing{personal: false}} ->
        close_item_with_place(context)

      # close thing in container on character
      %TAP{place: %Place{personal: place}, thing: %Thing{personal: thing}} when place or thing ->
        close_item_with_personal_place(context)
    end
  end

  defp close_item_in_inventory(context) do
    results =
      Search.find_matches_in_inventory(
        context.character.id,
        context.command.ast.thing.input,
        context.character.settings.commands.search_mode
      )

    case results do
      {:ok, matches} ->
        sorted_results = CallbackUtil.sort_matches(matches)

        # then just handle results as normal
        handle_search_results(context, {:ok, sorted_results})

      _ ->
        handle_search_results(context, results)
    end
  end

  defp handle_search_results(context, results) do
    case results do
      {:ok, [match]} ->
        close_item(context, match)

      {:ok, all_matches = [match | matches]} ->
        case context.command.ast do
          # If which is greater than 0, then more than one match was anticipated.
          # Make sure provided selection is not more than the number of items that were found
          %TAP{thing: %Thing{which: which}}
          when is_integer(which) and which > 0 and which <= length(all_matches) ->
            close_item(context, Enum.at(matches, which - 1))

          # If the user provided a number but it is greater than the number of items found,
          %TAP{thing: %Thing{which: which}} when which > 0 and which > length(all_matches) ->
            Util.not_found_error(context)

          _ ->
            case context.character.settings.commands.multiple_matches_mode do
              "silent" ->
                close_item(context, match, [])

              "alert" ->
                close_item(context, match, matches)

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

  defp close_item_with_place(context) do
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
        handle_search_results(context, {:ok, CallbackUtil.sort_matches(area_matches)})

      _ ->
        close_item_with_personal_place(context)
    end
  end

  defp close_item_with_personal_place(context) do
    # look for place on ground on in hands or worn
    results =
      Search.find_matches_relative_to_place_in_inventory(
        context.character.id,
        context.command.ast.thing,
        context.command.ast.place,
        context.character.settings.commands.search_mode
      )

    handle_search_results(context, results)
  end

  defp close_item_in_area_or_inventory(context) do
    case Search.find_exits_in_area(context.character.area_id, context.command.ast.thing.input) do
      {:ok, [link | rest]} ->
        close_link(context, link, rest)

      _ ->
        area_results =
          Search.find_matches_in_area(
            context.character.area_id,
            context.command.ast.thing.input,
            context.character.settings.commands.search_mode
          )

        case area_results do
          {:ok, area_matches} when area_matches != [] ->
            handle_search_results(context, {:ok, CallbackUtil.sort_matches(area_matches)})

          _ ->
            close_item_in_inventory(context)
        end
    end
  end

  defp maybe_close_opposite_link(context, link) do
    # search for link going opposite way that is also closable and in the same state
    # if one exists,
    case Link.get(link.to_id, link.from_id) do
      nil ->
        context

      opposite_link ->
        if opposite_link.flags.closable and opposite_link.closable.open do
          Closable.update!(opposite_link.closable, %{open: false})

          others =
            Character.list_others_active_in_areas(
              context.character.id,
              opposite_link.from_id
            )

          upcased_desc = Mud.Engine.Util.upcase_first(opposite_link.short_description)

          # Create message to self
          other_room_msg =
            Message.new_story_output(
              others,
              "#{upcased_desc} closes.",
              "base"
            )

          Context.append_message(context, other_room_msg)
        end
    end
  end

  defp close_link(context, thing = %Search.Match{}, other_matches \\ []) do
    link = thing.match
    # The link is coming from the correct room so we can continue
    if link.from_id == context.character.area_id do
      # It is possible to open/close this link and it is open
      cond do
        link.flags.closable and link.closable.open ->
          # actually close it
          closable = Closable.update!(link.closable, %{open: false})
          link = %{link | closable: closable}

          context = maybe_close_opposite_link(context, link)

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
            |> Message.append_text(" closed ", "base")
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
            |> Message.append_text(" close ", "base")
            |> Message.append_text(
              link.short_description,
              Mud.Engine.Util.get_link_type(link)
            )
            |> Message.append_text(".", "base")

          # Append assumption message if there were other links found
          self_msg =
            if other_matches != [] do
              other_links = Enum.map(other_matches, & &1.match)

              Util.append_assumption_text(self_msg, link, other_links)
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

        link.flags.closable and not link.closable.open ->
          upcased_desc = Mud.Engine.Util.upcase_first(link.short_description)

          # Create message to self
          self_msg =
            Message.new_story_output(
              context.character.id,
              "#{upcased_desc} is already closed.",
              "system_alert"
            )

          # Append assumption message if there were other links found
          self_msg =
            if other_matches != [] do
              other_links = Enum.map(other_matches, & &1.match)

              Util.append_assumption_text(self_msg, link, other_links)
            else
              self_msg
            end

          Context.append_message(
            context,
            self_msg
          )

        not link.flags.closable ->
          upcased_desc = Mud.Engine.Util.upcase_first(link.short_description)

          # Create message to self
          self_msg =
            Message.new_story_output(
              context.character.id,
              "#{upcased_desc} cannot be closed.",
              "system_alert"
            )

          # Append assumption message if there were other links found
          self_msg =
            if other_matches != [] do
              other_links = Enum.map(other_matches, & &1.match)

              Util.append_assumption_text(self_msg, link, other_links)
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

  defp close_item(context, thing = %Search.Match{}, other_matches \\ []) do
    in_area = Item.in_area?(thing.match.id, context.character.area_id)
    in_inventory = Item.in_inventory?(thing.match.id, context.character.id)
    parent_containers_open = Item.parent_containers_open?(thing.match)

    cond do
      parent_containers_open and (in_area or in_inventory) ->
        cond do
          # Is container and container is open, meaning it can be closed
          thing.match.flags.container and thing.match.container.open ->
            container =
              Container.update!(thing.match.container, %{
                open: false
              })

            item = Map.put(thing.match, :container, container)

            others =
              Character.list_others_active_in_areas(
                context.character.id,
                context.character.area_id
              )

            other_msg =
              others
              |> Message.new_story_output()
              |> Message.append_text("[#{context.character.name}]", "character")
              |> Message.append_text(" closes ", "base")
              |> Message.append_text(item.description.short, Mud.Engine.Util.get_item_type(item))
              |> Message.append_text(".", "base")

            self_msg =
              context.character.id
              |> Message.new_story_output()
              |> Message.append_text("You", "character")
              |> Message.append_text(" close ", "base")
              |> Message.append_text(
                Item.items_to_short_desc_with_nested_location_without_item(item),
                Mud.Engine.Util.get_item_type(item)
              )
              |> Message.append_text(".", "base")

            self_msg =
              if other_matches != [] do
                other_items = Enum.map(other_matches, & &1.match)

                Util.append_assumption_text(self_msg, item, other_items)
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
                    UpdateArea.new(%{action: :update, on_ground: [item]})
                  )
              end

            context
            |> Context.append_message(other_msg)
            |> Context.append_message(self_msg)

          # It is a container but the container is close,
          thing.match.flags.container and not thing.match.container.open ->
            self_msg =
              context.character.id
              |> Message.new_story_output()
              |> Message.append_text(
                CallbackUtil.upcase_item_with_location(thing.match),
                Mud.Engine.Util.get_item_type(thing.match)
              )
              |> Message.append_text(" is already closed.", "system_warning")

            self_msg =
              if other_matches != [] do
                other_items = Enum.map(other_matches, & &1.match)

                Util.append_assumption_text(self_msg, thing.match, other_items)
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
              |> Message.append_text(" cannot be closeed.", "system_alert")

            self_msg =
              if other_matches != [] do
                other_items = Enum.map(other_matches, & &1.match)

                Util.append_assumption_text(self_msg, thing.match, other_items)
              else
                self_msg
              end

            Context.append_message(context, self_msg)
        end

      not parent_containers_open and (in_area or in_inventory) ->
        parent_containers = Item.list_sorted_parent_containers(thing.match)
        # If a parent is closed, warn the player
        CallbackUtil.parent_containers_closed_error(context, thing.match, parent_containers)

      not in_area and not in_inventory ->
        Util.dave_error_v2(context)
    end
  end
end
