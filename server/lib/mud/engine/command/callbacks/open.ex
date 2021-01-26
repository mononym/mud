defmodule Mud.Engine.Command.Open do
  @moduledoc """
  The CLOSE command allows the Character to open something such as a door or a chest.

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
  alias Mud.Engine.Command.Context
  alias Mud.Engine.{Character, Item}
  alias Item.{Container, Location}
  alias Mud.Engine.Command.AstNode.ThingAndPlace, as: TAP
  alias Mud.Engine.Command.AstNode.{Thing, Place}

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

      Context.append_output(
        context,
        context.character.id,
        Util.get_module_docs(__MODULE__),
        "error"
      )
    else
      # A UUID was passed in which means the open command is being attempted on a specific item.
      # This sort of command should only be triggered by the UI.
      if Util.is_uuid4(context.command.ast.thing.input) do
        Logger.debug("Open command provided with uuid: #{context.command.ast.thing.input}")

        # Since it is a "direct" command there is no way of knowing how deeply nested the item might be.
        # Grab the item and all of its parent containers.
        items = Item.list_all_recursive(context.command.ast.thing.input)

        # Make sure they are all open
        all_parents_open =
          Enum.all?(items, fn item ->
            item.container.open or item.id == context.command.ast.thing.input
          end)

        cond do
          # If one of the parents is not open, then we cannot get to the item, and an error should be returned.
          # Also, make sure something was actually found.
          length(items) > 0 and all_parents_open ->
            open_item(
              context,
              List.first(
                Search.things_to_match(
                  Enum.find(items, &(&1.id == context.command.ast.thing.input))
                )
              )
            )

          length(items) > 0 and not all_parents_open ->
            Util.parent_container_closed_error(context)

          length(items) == 0 ->
            Util.not_found_error(context)
        end
      else
        Logger.debug("Provided input was not a uuid: #{context.command.ast.thing.input}")

        # If there is input but that input is not a UUID, that means the player typed text in. Go searching for the item.
        find_thing_to_open(context)
      end
    end
  end

  defp open_item_in_worn_container(context) do
    context
  end

  defp open_item_in_area_or_in_inventory(context) do
    context
  end

  defp open_item_with_place(context) do
    # look for place on ground on in hands or worn
    results =
      Search.find_matches_relative_to_place_on_ground_in_hands_or_worn(
        context.character.area_id,
        context.character.id,
        context.command.ast.thing.input,
        context.command.ast.place.where,
        context.command.ast.place.input,
        context.character.settings.commands.search_mode
      )

    handle_search_results(context, results)
  end

  defp handle_search_results(context, results) do
    case results do
      {:ok, [match]} ->
        open_item(context, match)

      {:ok, all_matches = [match | matches]} ->
        IO.inspect(context.command.ast)

        case context.command.ast do
          # If which is greater than 0, then more than one match was anticipated.
          # Make sure provided selection is not more than the number of items that were found
          %TAP{thing: %Thing{which: which}}
          when is_integer(which) and which > 0 and which <= length(all_matches) ->
            open_item(context, Enum.at(matches, which - 1))

          # If the user provided a number but it is greater than the number of items found,
          %TAP{thing: %Thing{which: which}} when which > 0 and which > length(all_matches) ->
            Util.not_found_error(context)

          _ ->
            IO.inspect(context.character.settings.commands.multiple_matches_mode,
              label: "context.character.settings.commands.multiple_matches_mode"
            )

            case context.character.settings.commands.multiple_matches_mode do
              "silent" ->
                open_item(context, match, [])

              "alert" ->
                open_item(context, match, matches)

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

      {:ok, []} ->
        Util.not_found_error(context)

      _ ->
        Util.dave_error_v2(context)
    end
  end

  defp open_item_with_personal_place(context) do
    # look for place on ground on in hands or worn
    results =
      Search.find_matches_relative_to_place_in_hands_or_worn(
        context.character.id,
        context.command.ast.thing.input,
        context.command.ast.place.where,
        context.command.ast.place.input,
        context.character.settings.commands.search_mode
      )

    handle_search_results(context, results)
  end

  defp open_item_in_area_or_in_inventory(context) do
    context
  end

  defp open_item_on_ground_or_worn_or_held_items(context) do
    IO.inspect(context.command.ast.thing)

    results =
      Search.find_matches_on_ground_or_worn_or_held_items(
        context.character.area_id,
        context.character.id,
        context.command.ast.thing.input,
        context.character.settings.commands.search_mode
      )

    IO.inspect(results, label: "open_item_on_ground_or_worn_or_held_items")

    handle_search_results(context, results)
  end

  defp open_worn_or_held_item_in_inventory(context) do
    # open an item in inventory
    # sql search for all items in inventory which match text
    result =
      Search.find_matches_in_worn_or_held_items(
        context.character.id,
        context.command.ast.thing.input,
        context.character.settings.commands.search_mode
      )

    case result do
      {:ok, [thing]} ->
        Logger.debug("Found the item to Open")
        open_item(context, thing)

      {:ok, _} ->
        # open_item(context, thing)

        Logger.debug("Found too many items to open, or no item")

        Context.append_message(
          context,
          Message.new_story_output(
            context.character.id,
            "Multiple items were found, please be more specific.",
            "system_alert"
          )
        )

      # context
      # |> Context.append_error("Multiple potential items found, please be more specific.")

      error ->
        error
    end
  end

  defp find_thing_to_open(context = %Mud.Engine.Command.Context{}) do
    case context.command.ast do
      # Open thing on character
      # If nothing is found worn on the character do not look further
      %TAP{place: nil, thing: %Thing{personal: true}} ->
        Logger.debug("Item to Open should be on character")

        open_worn_or_held_item_in_inventory(context)

      # Thing being opened did not have 'my' specified, but also no place either
      %TAP{place: nil, thing: %Thing{personal: false}} ->
        # An id for a specific item was given.
        if Util.is_uuid4(context.command.ast.thing.input) do
          item = Item.get!(context.command.ast.thing.input)
          # TODO: Add check here to make sure that all parent containers, if any, are open
          if item.location.relative_to_item and item.location.relation == "in" do
            parents_open =
              Item.list_all_recursive_parents(item)
              |> Enum.all?(fn parent ->
                parent.flags.container and parent.container.open
              end)

            if parents_open do
              open_item(context, List.first(Search.things_to_match(item)))
            else
              Util.dave_error_v2(context)
            end
          end
        else
          # open thing on ground/in area, fallback to items held or in worn inventory
          open_item_on_ground_or_worn_or_held_items(context)
        end

      # This thing will be in a place, but that place might not be on the character
      %TAP{place: %Place{personal: false}, thing: %Thing{personal: false}} ->
        open_item_with_place(context)

      # get thing from container on character
      %TAP{place: %Place{personal: place}, thing: %Thing{personal: thing}} when place or thing ->
        open_item_with_personal_place(context)
    end
  end

  defp open_item(context, thing = %Search.Match{}, other_matches \\ []) do
    if Item.parent_containers_open?(thing.match) do
      cond do
        # Is container and container is closed, meaning it can be opened
        thing.match.flags.container and not thing.match.container.open ->
          container =
            Container.update!(thing.match.container, %{
              open: true
            })

          item = Map.put(thing.match, :container, container)

          others =
            Character.list_others_active_in_areas(context.character.id, context.character.area_id)

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
            |> Message.append_text(item.description.short, Mud.Engine.Util.get_item_type(item))
            |> Message.append_text(".", "base")

          self_msg =
            if other_matches != [] do
              other_items = Enum.map(other_matches, & &1.match)

              Util.append_assumption_text(self_msg, item, other_items)
            else
              self_msg
            end

          context =
            if item.location.worn_on_character or item.location.held_in_hand do
              Context.append_event(
                context,
                context.character_id,
                UpdateInventory.new(:update, item)
              )
            else
              Context.append_event(
                context,
                [context.character_id | others],
                UpdateArea.new(%{action: :update, on_ground: [item]})
              )
            end

          context
          |> Context.append_message(other_msg)
          |> Context.append_message(self_msg)

        # It is a container but the container is open,
        thing.match.flags.container and thing.match.container.open ->
          self_msg =
            context.character.id
            |> Message.new_story_output()
            |> Message.append_text(
              Util.upcase_first(thing.match.description.short),
              Mud.Engine.Util.get_item_type(thing.match)
            )
            |> Message.append_text(" is already open.", "system_warning")

          self_msg =
            if other_matches != [] do
              other_items = Enum.map(other_matches, & &1.match)
              IO.inspect(other_items, label: "other_items")

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
              thing.match.description.short,
              Mud.Engine.Util.get_item_type(thing.match)
            )
            |> Message.append_text(" cannot be opened.", "system_alert")

          self_msg =
            if other_matches != [] do
              other_items = Enum.map(other_matches, & &1.match)

              Util.append_assumption_text(self_msg, thing.match, other_items)
            else
              self_msg
            end

          Context.append_message(context, self_msg)
      end
    else
      # If a parent is closed, pretend like nothing was found
      Util.not_found_error(context)
    end
  end
end
