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
            item.container_open or item.id == context.command.ast.thing.input
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

  defp open_item_on_ground_or_in_inventory(context) do
    context
  end

  defp open_worn_item_in_inventory(context) do
    # open an item in inventory
    # sql search for all items in inventory which match text
    result =
      Search.find_matches_v2(
        [:worn_container],
        context.character.id,
        context.command.ast.thing.input,
        0
      )

    case result do
      {:ok, [thing]} ->
        Logger.debug("Found the item to Open")
        open_item(context, thing)

      {:ok, _things} ->
        Context.append_message(
          context,
          Message.new_story_output(context.character.id, "Found too many items to open")
        )

        Logger.debug("Found too many items to open, or no item")

        context
        |> Context.append_error("Multiple potential items found, please be more specific.")

      error ->
        error
    end
  end

  defp find_thing_to_open(context = %Mud.Engine.Command.Context{}) do
    case context.command.ast do
      # open thing in inventory on character
      %TAP{place: nil, thing: %Thing{personal: true}} ->
        Logger.debug("Item to Open should be on character")

        open_worn_item_in_inventory(context)

      # open thing on ground/in area, fallback to item in inventory
      %TAP{place: nil, thing: %Thing{personal: false}} ->
        if Util.is_uuid4(context.command.ast.thing.input) do
          item = Item.get!(context.command.ast.thing.input)
          open_item(context, List.first(Search.things_to_match(item)))
        else
          open_item_on_ground_or_in_inventory(context)
        end

      # get thing from container on ground, fallback to worn containers
      %TAP{place: %Place{personal: false}, thing: %Thing{personal: false}} ->
        open_item_in_area_or_in_inventory(context)

      # get thing from container on character
      %TAP{place: %Place{personal: place}, thing: %Thing{personal: thing}} when place or thing ->
        open_item_in_worn_container(context)
    end
  end

  defp open_item(context, thing = %Search.Match{}) do
    cond do
      thing.match.is_container and not thing.match.container_open ->
        item =
          Item.update!(thing.match, %{
            container_open: true
          })

        others =
          Character.list_others_active_in_areas(context.character.id, context.character.area_id)

        other_msg =
          others
          |> Message.new_story_output()
          |> Message.append_text("[#{context.character.name}]", "character")
          |> Message.append_text(" opens ", "base")
          |> Message.append_text(item.short_description, Mud.Engine.Util.get_item_type(item))

        self_msg =
          context.character.id
          |> Message.new_story_output()
          |> Message.append_text("You", "character")
          |> Message.append_text(" open ", "base")
          |> Message.append_text(item.short_description, Mud.Engine.Util.get_item_type(item))

        context =
          if item.wearable_is_worn or item.holdable_is_held do
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

      thing.match.is_container and thing.match.container_open ->
        self_msg =
          context.character.id
          |> Message.new_story_output()
          |> Message.append_text(
            Util.upcase_first(thing.match.short_description),
            Mud.Engine.Util.get_item_type(thing.match)
          )
          |> Message.append_text(" is already open.", "system_warning")

        Context.append_message(context, self_msg)

      true ->
        self_msg =
          context.character.id
          |> Message.new_story_output()
          |> Message.append_text("You cannot open ", "system_alert")
          |> Message.append_text(
            thing.match.short_description,
            Mud.Engine.Util.get_item_type(thing.match)
          )

        Context.append_message(context, self_msg)
    end
  end
end
