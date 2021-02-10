defmodule Mud.Engine.Command.Put do
  @moduledoc """
  The PUT command allows you to put something in your hand somewhere such as the ground or a container.

  Syntax:
    - put {left|right|all|[my] [<which>] <thing>} {down|on ground|{in|on|under|over|behind|beside} [my] [<which>] <thing>}

  Examples:
    - put backpack down (same as drop)
    - put quiver on shelf
    - put 2 shirt in 3 drawer
    - put 2 diamond in my 5 gem pouch
    - put my pouch in chest in bottom drawer
  """
  use Mud.Engine.Command.Callback

  alias Mud.Engine.Event.Client.{UpdateArea, UpdateInventory}
  alias Mud.Engine.Item
  alias Mud.Engine.Character
  alias Mud.Engine.Command.CallbackUtil
  alias Mud.Engine.Command.Context
  alias Mud.Engine.Util
  alias Mud.Engine.Search
  alias Mud.Engine.Message
  alias Mud.Engine.Command.AstNode.ThingAndPlace, as: TAP
  alias Mud.Engine.Command.AstNode.{Place, Thing}

  require Logger

  @spec build_ast([Mud.Engine.Command.AstNode.t(), ...]) ::
          Mud.Engine.Command.AstNode.ThingAndPlace.t()
  def build_ast(ast_nodes) do
    Mud.Engine.Command.AstUtil.build_tap_ast(ast_nodes)
  end

  @impl true
  def execute(context) do
    Logger.debug("Executing Put command")
    Logger.debug(inspect(context))
    ast = context.command.ast

    if is_nil(ast.thing) do
      Logger.debug("Put command entered without input. Returning error with command docs.")

      Context.append_message(
        context,
        Message.new_story_output(
          context.character.id,
          Util.get_module_docs(__MODULE__),
          "system_info"
        )
      )
    else
      # A UUID was passed in which means the put command is being attempted on a specific item.
      # This sort of command should only be triggered by the UI.
      if Util.is_uuid4(context.command.ast.thing.input) do
        Logger.debug("Put command provided with uuid: #{context.command.ast.thing.input}")

        put_item_in_place_by_uuid(context)
      else
        Logger.debug("Provided input was not a uuid: #{context.command.ast.thing.input}")

        # If there is input but that input is not a UUID, that means the player typed text in. Go searching for the item.
        find_thing_to_put(context)
      end
    end
  end

  defp put_item_in_place_by_uuid(context) do
    case Item.get(context.command.ast.thing.input) do
      {:ok, item} ->
        if item.location.held_in_hand and item.location.character.id == context.character.id do
          find_place_to_put_thing(context, List.first(Search.things_to_match(item)), [])
        else
          Util.dave_error_v2(context)
        end

      _ ->
        Util.dave_error_v2(context)
    end
  end

  defp find_place_to_put_thing(
         context = %Mud.Engine.Command.Context{},
         thing,
         other_thing_matches
       ) do
    case context.command.ast do
      # The place where the thing being put is not *necessarily* on the character. Look around area first.
      %TAP{place: %Place{personal: false}} ->
        find_place_in_area_or_inventory_to_put_thing(context, thing, other_thing_matches)

      # This thing will be in a place, but that place might not be on the character
      %TAP{place: %Place{personal: true}} ->
        find_place_in_inventory_to_put_thing(context, thing, other_thing_matches)
    end
  end

  defp find_place_in_area_or_inventory_to_put_thing(context, thing, other_thing_matches) do
    results =
      Search.find_matches_in_area(
        context.character.id,
        context.command.ast.place.input,
        context.character.settings.commands.search_mode
      )

    case results do
      {:ok, matches} ->
        sorted_results = CallbackUtil.sort_matches(matches)

        handle_search_results(context, {:ok, sorted_results}, thing, other_thing_matches)

      _ ->
        find_place_in_inventory_to_put_thing(context, thing, other_thing_matches)
    end
  end

  defp find_place_in_inventory_to_put_thing(context, thing, other_thing_matches) do
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
        handle_search_results(context, {:ok, sorted_results}, thing, other_thing_matches)

      _ ->
        handle_search_results(context, results, thing, other_thing_matches)
    end
  end

  defp find_thing_to_put(context = %Mud.Engine.Command.Context{}) do
    results =
      Search.find_matches_in_held_items(
        context.character.id,
        context.command.ast.thing.input,
        context.character.settings.commands.search_mode
      )

    case results do
      {:ok, [match]} ->
        find_place_to_put_thing(context, match, [])

      {:ok, matches} ->
        case context.character.settings.commands.multiple_matches_mode do
          "silent" ->
            [match | other_thing_matches] = CallbackUtil.sort_matches(matches)

            find_place_to_put_thing(context, match, other_thing_matches)

          "full path" ->
            [match | other_thing_matches] = CallbackUtil.sort_matches(matches)

            find_place_to_put_thing(context, match, other_thing_matches)

          "choose" ->
            Context.append_message(
              context,
              Message.new_story_output(
                context.character.id,
                "Multiple items to put were found, please be more specific.",
                "system_alert"
              )
            )
        end

      _ ->
        Util.not_found_error(context)
    end
  end

  defp handle_search_results(context, results, thing, other_thing_matches) do
    case results do
      # found a single place to put the thing
      {:ok, [match]} ->
        put_item(context, thing, other_thing_matches, match, [])

      # Found multiple places to put the thing
      {:ok, all_matches = [match | matches]} ->
        case context.command.ast do
          # If which is greater than 0, then more than one match was anticipated.
          # Make sure provided selection is not more than the number of items that were found
          %TAP{place: %Place{which: which}}
          when is_integer(which) and which > 0 and which <= length(all_matches) ->
            put_item(context, thing, other_thing_matches, Enum.at(matches, which - 1), [])

          # If the user provided a number but it is greater than the number of items found,
          %TAP{place: %Place{which: which}} when which > 0 and which > length(all_matches) ->
            Util.not_found_error(context)

          _ ->
            case context.character.settings.commands.multiple_matches_mode do
              "silent" ->
                put_item(context, thing, other_thing_matches, match, [])

              "full path" ->
                put_item(context, thing, other_thing_matches, match, matches)

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

      _ ->
        Util.not_found_error(context)
    end
  end

  defp put_item(
         context,
         thing = %Search.Match{},
         other_thing_matches \\ [],
         place,
         other_place_matches
       ) do
    item = thing.match
    destination = place.match

    # if item.location.held_in_hand and item.location.character_id == context.character.id do
    #   # NEED TO KNOW WHERE THE HELL TO PUT IT
    location = Location.update_relative_to_item!(item.location, destination.id, "in")

    item = Map.put(thing.match, :location, location)

    others =
      Character.list_others_active_in_areas(
        context.character.id,
        context.character.area_id
      )

    other_msg =
      others
      |> Message.new_story_output()
      |> Message.append_text("[#{context.character.name}]", "character")
      |> Message.append_text(" puts ", "base")
      |> Message.append_text(item.description.short, Mud.Engine.Util.get_item_type(item))
      |> Message.append_text(".", "base")

    #   self_msg =
    #     context.character.id
    #     |> Message.new_story_output()
    #     |> Message.append_text("You", "character")
    #     |> Message.append_text(" put ", "base")
    #     |> Message.append_text(
    #       List.first(Item.items_to_short_desc_with_nested_location_without_item(item)),
    #       Mud.Engine.Util.get_item_type(item)
    #     )
    #     |> Message.append_text(".", "base")

    #   self_msg =
    #     if other_matches != [] do
    #       other_items = Enum.map(other_matches, & &1.match)

    #       Util.append_assumption_text(self_msg, item, other_items)
    #     else
    #       self_msg
    #     end

    #   # for items that are not root items, check to see whether the update needs to go to inventory or the area
    #   context =
    #     cond do
    #       item.location.worn_on_character or item.location.held_in_hand ->
    #         Context.append_event(
    #           context,
    #           context.character_id,
    #           UpdateInventory.new(:update, item)
    #         )

    #       item.location.on_ground ->
    #         Context.append_event(
    #           context,
    #           [context.character_id | others],
    #           UpdateArea.new(%{action: :update, on_ground: [item]})
    #         )
    #     end

    #   context
    #   |> Context.append_message(other_msg)
    #   |> Context.append_message(self_msg)
    # else
    #   Util.dave_error_v2(context)
    # end
  end
end
