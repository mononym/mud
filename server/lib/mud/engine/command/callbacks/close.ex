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
    Logger.debug("Executing Close command")
    Logger.debug(inspect(context))
    ast = context.command.ast

    if is_nil(ast.thing) do
      Logger.debug("Close command entered without input. Returning error with command docs.")

      Context.append_output(
        context,
        context.character.id,
        Util.get_module_docs(__MODULE__),
        "error"
      )
    else
      # A UUID was passed in which means the close command is being attempted on a specific item.
      # This sort of command should only be triggered by the UI.
      if Util.is_uuid4(context.command.ast.thing.input) do
        Logger.debug("Close command provided with uuid: #{context.command.ast.thing.input}")

        # Since it is a "direct" command there is no way of knowing how deeply nested the item might be.
        # Grab the item and all of its parent containers.
        items = Item.list_all_recursive(context.command.ast.thing.input)

        # Make sure they are all close
        all_parents_close =
          Enum.all?(items, fn item ->
            item.container.open or item.id == context.command.ast.thing.input
          end)

        cond do
          # If one of the parents is not close, then we cannot get to the item, and an error should be returned.
          # Also, make sure something was actually found.
          length(items) > 0 and all_parents_close ->
            close_item(
              context,
              List.first(
                Search.things_to_match(
                  Enum.find(items, &(&1.id == context.command.ast.thing.input))
                )
              )
            )

          length(items) > 0 and not all_parents_close ->
            Util.parent_container_closed_error(context)

          length(items) == 0 ->
            Util.not_found_error(context)
        end
      else
        Logger.debug("Provided input was not a uuid: #{context.command.ast.thing.input}")

        # If there is input but that input is not a UUID, that means the player typed text in. Go searching for the item.
        find_thing_to_close(context)
      end
    end
  end

  defp close_item_in_worn_container(context) do
    context
  end

  defp close_item_in_area_or_in_inventory(context) do
    context
  end

  defp close_item_on_ground_or_in_inventory(context) do
    context
  end

  defp close_worn_item_in_inventory(context) do
    # close an item in inventory
    # sql search for all items in inventory which match text
    result =
      Search.find_matches_in_worn_items(
        context.character.id,
        context.command.ast.thing.input
      )

    case result do
      {:ok, [thing]} ->
        Logger.debug("Found the item to Close")
        close_item(context, thing)

      {:ok, _} ->
        # close_item(context, thing)

        Logger.debug("Found too many items to close, or no item")

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

  defp find_thing_to_close(context = %Mud.Engine.Command.Context{}) do
    Logger.debug(inspect(context.command.ast))

    case context.command.ast do
      # Close thing in inventory on character
      # If nothing is found worn on the character do not look further
      %TAP{place: nil, thing: %Thing{personal: true}} ->
        Logger.debug("Item to Close should be on character")

        close_worn_item_in_inventory(context)

      # close thing on ground/in area, fallback to item in inventory
      %TAP{place: nil, thing: %Thing{personal: false}} ->
        if Util.is_uuid4(context.command.ast.thing.input) do
          item = Item.get!(context.command.ast.thing.input)
          close_item(context, List.first(Search.things_to_match(item)))
        else
          close_item_on_ground_or_in_inventory(context)
        end

      # get thing from container on ground, fallback to worn containers
      %TAP{place: %Place{personal: false}, thing: %Thing{personal: false}} ->
        close_item_in_area_or_in_inventory(context)

      # get thing from container on character
      %TAP{place: %Place{personal: place}, thing: %Thing{personal: thing}} when place or thing ->
        close_item_in_worn_container(context)
    end
  end

  defp close_item(context, thing = %Search.Match{}, other_matches \\ []) do
    cond do
      # Is container and container is closed, meaning it can be closeed
      thing.match.flags.container and thing.match.container.open ->
        container =
          Container.update!(thing.match.container, %{
            open: false
          })

        item = Map.put(thing.match, :container, container)

        others =
          Character.list_others_active_in_areas(context.character.id, context.character.area_id)

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
          |> Message.append_text(item.description.short, Mud.Engine.Util.get_item_type(item))
          |> Message.append_text(".", "base")

        self_msg =
          if other_matches != [] do
            # ("Assuming that was your intended target. #{length(other_matches)} other possible matches were found: ")
            Message.append_text(self_msg, "\n", "base")
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

      # It is a container but the container is closed,
      thing.match.flags.container and not thing.match.container.open ->
        self_msg =
          context.character.id
          |> Message.new_story_output()
          |> Message.append_text(
            Util.upcase_first(thing.match.description.short),
            Mud.Engine.Util.get_item_type(thing.match)
          )
          |> Message.append_text(" is already closed.", "system_warning")

        Context.append_message(context, self_msg)

      # Assume the thing is not a container
      true ->
        self_msg =
          context.character.id
          |> Message.new_story_output()
          |> Message.append_text("You cannot close ", "system_alert")
          |> Message.append_text(
            thing.match.description.short,
            Mud.Engine.Util.get_item_type(thing.match)
          )
          |> Message.append_text(".", "system_alert")

        Context.append_message(context, self_msg)
    end
  end
end
