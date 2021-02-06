defmodule Mud.Engine.Command.Store do
  @moduledoc """
  The STORE command changes how items are put into containers when using the STOW command.

  If no default container has been set, STOW will use the largest container you are wearing. To change that use this command with the DEFAULT modifier to set a default container to be used explicitly.

  See HELP STOW for further information.

  The following modifiers are valid options:
  LIST - Prints the status of the below options.
  CLEAR - Can be used with any of the below modifiers, and the special ALL modifier to clear everything.
  DEFAULT - Used when no container has been set for an item type, or a fallback is required.
  AMMUNITION/AMMO - Rocks, arrows, bolts, and other items recognized as ammunition.
  ARMOR - Any items that count as armor.
  CLOTHING - Any items that count as clothing.
  GEM - If no container has been set, a worn gem pouch will be searched for by default, and only if one of those is not found will the DEFAULT container be fallen back to.
  SHIELD - Any items that count as a shield.
  WEAPON - Any items that count as a weapon.

  Syntax:
    - STORE LIST
    - STORE CLEAR ALL
    - STORE DEFAULT silver backpack
    - STORE CLEAR ARMOR
    - STORE ARMOR in pack
  """
  use Mud.Engine.Command.Callback

  alias Mud.Engine.Command.Context
  alias Mud.Engine.Message
  alias Mud.Engine.Command.AstNode.ThingAndPlace, as: TAP
  alias Mud.Engine.Command.AstNode.{Place, Thing}
  alias Mud.Engine.Item
  alias Mud.Engine.Util
  alias Mud.Engine.Search
  alias Mud.Engine.Character.Containers
  alias Mud.Engine.Event.Client.UpdateCharacter

  alias Mud.Engine.Command.CallbackUtil
  require Logger

  def build_ast(ast_nodes) do
    Mud.Engine.Command.AstUtil.build_tap_ast(ast_nodes)
  end

  @impl true
  def execute(%Context{} = context) do
    Logger.debug("Executing Store command")
    Logger.debug(inspect(context))
    ast = context.command.ast

    # check to see that the input for "thing" is one of the viable options
    if is_nil(ast.thing) do
      Logger.debug("STORE command entered without input. Returning error with command docs.")

      Context.append_message(
        context,
        Message.new_story_output(
          context.character.id,
          Util.get_module_docs(__MODULE__),
          "system_info"
        )
      )
    else
      maybe_handle_option(context)
    end
  end

  defp maybe_handle_option(context) do
    case context.command.ast do
      %TAP{place: nil, thing: %Thing{input: "clear"}} ->
        # Clear cannot be entered on its own without anything. Doesn't make any sense. Trigger help docs
        Context.append_message(
          context,
          Message.new_story_output(
            context.character.id,
            Util.get_module_docs(__MODULE__),
            "system_info"
          )
        )

      %TAP{place: %Place{input: input}, thing: %Thing{input: "clear"}} ->
        clear_settings(context, input)

      # If a container is not provided with an option then print out the set container
      %TAP{place: nil, thing: %Thing{input: input}} ->
        print_set_container_for_option(context, input)

      # Assume a setting has been picked and a string specifying a container has been provided
      _ ->
        update_settings(context)
    end
  end

  defp clear_settings(context, option) do
    containers = context.character.containers

    params =
      case option do
        "list" ->
          %{}

        "armor" ->
          %{armor_id: nil}

        "weapon" ->
          %{weapon_id: nil}

        "weapons" ->
          %{weapon_id: nil}

        "shield" ->
          %{shield_id: nil}

        "shields" ->
          %{shield_id: nil}

        "gem" ->
          %{gem_id: nil}

        "gems" ->
          %{gem_id: nil}

        "ammo" ->
          %{ammunition_id: nil}

        "ammunition" ->
          %{ammunition_id: nil}

        "clothing" ->
          %{clothing_id: nil}

        "clothes" ->
          %{clothing_id: nil}

        "default" ->
          %{default_id: nil}
      end

    containers = Containers.update!(containers, params)

    context
    |> Context.append_event(
      context.character.id,
      UpdateCharacter.new(%{action: "containers", containers: containers})
    )
    |> Context.append_message(
      Message.new_story_output(context.character.id, "Cleared", "system_info")
    )
  end

  defp print_set_container_for_option(context, option) do
    IO.inspect(option, label: :print_set_container_for_option)
    IO.inspect(context.character.containers, label: :print_set_container_for_option)
    containers = context.character.containers

    case option do
      "list" ->
        container_ids = Map.values(context.character.containers) |> Enum.filter(&is_binary(&1))
        IO.inspect(container_ids, label: :container_ids)

        {locations_index, item_index} =
          case container_ids do
            [] ->
              {%{}, %{}}

            _ ->
              items = Item.list(container_ids)
              item_locations = Item.items_to_short_desc_with_nested_location_with_item(items)

              {Enum.reduce(item_locations, %{}, fn {item, string}, index ->
                 Map.put(index, item.id, string)
               end),
               Enum.reduce(item_locations, %{}, fn {item, _string}, index ->
                 Map.put(index, item.id, item)
               end)}
          end

        error_message = "You have not set a default container for that"

        self_message =
          context.character.id
          |> Message.new_story_output()
          |> Message.append_text("DEFAULT: ", "system_info")
          |> Message.append_text(
            Map.get(locations_index, containers.default_id, error_message),
            Mud.Engine.Util.get_item_type(
              Map.get(item_index, containers.default_id),
              "system_info"
            )
          )
          |> Message.append_text(".\n", "system_info")
          |> Message.append_text("AMMUNITION: ", "system_info")
          |> Message.append_text(
            Map.get(locations_index, containers.ammunition_id, error_message),
            Mud.Engine.Util.get_item_type(
              Map.get(item_index, containers.ammunition_id),
              "system_info"
            )
          )
          |> Message.append_text(".\n", "system_info")
          |> Message.append_text("ARMOR: ", "system_info")
          |> Message.append_text(
            Map.get(locations_index, containers.armor_id, error_message),
            Mud.Engine.Util.get_item_type(Map.get(item_index, containers.armor_id), "system_info")
          )
          |> Message.append_text(".\n", "system_info")
          |> Message.append_text("CLOTHING: ", "system_info")
          |> Message.append_text(
            Map.get(locations_index, containers.clothing_id, error_message),
            Mud.Engine.Util.get_item_type(
              Map.get(item_index, containers.clothing_id),
              "system_info"
            )
          )
          |> Message.append_text(".\n", "system_info")
          |> Message.append_text("GEMS: ", "system_info")
          |> Message.append_text(
            Map.get(locations_index, containers.gem_id, error_message),
            Mud.Engine.Util.get_item_type(Map.get(item_index, containers.gem_id), "system_info")
          )
          |> Message.append_text(".\n", "system_info")
          |> Message.append_text("SHIELD: ", "system_info")
          |> Message.append_text(
            Map.get(locations_index, containers.shield_id, error_message),
            Mud.Engine.Util.get_item_type(
              Map.get(item_index, containers.shield_id),
              "system_info"
            )
          )
          |> Message.append_text(".\n", "system_info")
          |> Message.append_text("WEAPONS: ", "system_info")
          |> Message.append_text(
            Map.get(locations_index, containers.weapon_id, error_message),
            Mud.Engine.Util.get_item_type(
              Map.get(item_index, containers.weapon_id),
              "system_info"
            )
          )
          |> Message.append_text(".\n", "system_info")

        Context.append_message(context, self_message)

      "armor" ->
        maybe_print_container(context, context.character.containers.armor_id)

      "weapon" ->
        maybe_print_container(context, context.character.containers.weapon_id)

      "weapons" ->
        maybe_print_container(context, context.character.containers.weapon_id)

      "shield" ->
        maybe_print_container(context, context.character.containers.shield_id)

      "shields" ->
        maybe_print_container(context, context.character.containers.shield_id)

      "gem" ->
        maybe_print_container(context, context.character.containers.gem_id)

      "gems" ->
        maybe_print_container(context, context.character.containers.gem_id)

      "ammo" ->
        maybe_print_container(context, context.character.containers.ammunition_id)

      "ammunition" ->
        maybe_print_container(context, context.character.containers.ammunition_id)

      "clothing" ->
        maybe_print_container(context, context.character.containers.clothing_id)

      "clothes" ->
        maybe_print_container(context, context.character.containers.clothing_id)

      "default" ->
        maybe_print_container(context, context.character.containers.default_id)
    end
  end

  defp update_settings(context) do
    # find a container somewhere in inventory and set it
    # if nothing found send out warning
    results =
      Search.find_matching_containers_in_inventory(
        context.character.id,
        context.command.ast.place.input,
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
        save_setting(context, context.command.ast.thing.input, match)

      {:ok, all_matches = [match | matches]} ->
        case context.command.ast do
          # If which is greater than 0, then more than one match was anticipated.
          # Make sure provided selection is not more than the number of items that were found
          %TAP{place: %Place{which: which}, thing: %Thing{input: input}}
          when is_integer(which) and which > 0 and which <= length(all_matches) ->
            save_setting(context, input, Enum.at(matches, which - 1))

          # If the user provided a number but it is greater than the number of items found,
          %TAP{place: %Place{which: which}} when which > 0 and which > length(all_matches) ->
            Util.not_found_error(context)

          %TAP{thing: %Thing{input: input}} ->
            case context.character.settings.commands.multiple_matches_mode do
              "silent" ->
                save_setting(context, input, match, [])

              "alert" ->
                save_setting(context, input, match, matches)

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

  defp save_setting(context, where, place = %Search.Match{}, other_matches \\ []) do
    in_inventory = Item.in_inventory?(place.match.id, context.character.id)

    if in_inventory do
      where = normalize_where(where)

      containers =
        Containers.update!(context.character.containers, %{"#{where}_id" => place.match.id})

      self_msg =
        context.character.id
        |> Message.new_story_output()
        |> Message.append_text(
          Util.upcase_first(
            List.first(Item.items_to_short_desc_with_nested_location_without_item(place.match))
          ),
          Mud.Engine.Util.get_item_type(place.match)
        )
        |> Message.append_text(
          " was set as the default container for the following category: #{where}",
          "base"
        )

      self_msg =
        if other_matches != [] do
          other_items = Enum.map(other_matches, & &1.match)

          Util.append_assumption_text(self_msg, place.match, other_items)
        else
          self_msg
        end

      context
      |> Context.append_event(
        context.character.id,
        UpdateCharacter.new(%{action: "containers", containers: containers})
      )
      |> Context.append_message(self_msg)
    else
      Util.dave_error_v2(context)
    end
  end

  defp normalize_where(where) do
    case where do
      "gems" -> "gem"
      "ammo" -> "ammunition"
      "weapons" -> "weapon"
      "shields" -> "shield"
      "clothes" -> "clothing"
      _ -> where
    end
  end

  defp maybe_print_container(context, item_id) do
    Context.append_message(
      context,
      item_to_message(context.character.id, item_id)
    )
  end

  defp item_to_message(character_id, item_id) do
    Message.new_story_output(
      character_id,
      item_to_string(item_id),
      "system_info"
    )
  end

  defp item_to_string(nil) do
    "NOT SET"
  end

  defp item_to_string(item_id) do
    item = Item.get!(item_id)
    List.first(Item.items_to_short_desc_with_nested_location_without_item(item))
  end
end
