defmodule Mud.Engine.Command.Sit do
  @moduledoc """
  The SIT command moves the character into a sitting position.

  If no target is provided to sit on the Character will sit on the ground.

  Syntax:
    - sit [on] target

  Examples:
    - sit
    - sit chair
    - sit on chair
  """
  use Mud.Engine.Command.Callback

  alias Mud.Engine.Command.CallbackUtil
  alias Mud.Engine.Command.Context
  alias Mud.Engine.{Character, Item}
  alias Mud.Engine.Util
  alias Mud.Engine.Search
  alias Mud.Engine.Message
  alias Mud.Engine.Event.Client.{UpdateArea, UpdateCharacter}
  alias Mud.Engine.Item.Surface

  require Logger

  def build_ast(ast_nodes) do
    Mud.Engine.Command.AstUtil.build_one_thing_ast(ast_nodes)
  end

  @impl true
  def execute(%Context{} = context) do
    ast = context.command.ast

    cond do
      context.character.status.position == "sitting" ->
        Context.append_message(
          context,
          Message.new_story_output(
            context.character.id,
            "You are already sitting.",
            "system_info"
          )
        )

      is_nil(ast.thing) ->
        maybe_sit_on_ground(context)

      Util.is_uuid4(ast.thing.input) ->
        Logger.debug("Sit command provided with uuid: #{ast.thing.input}")

        case Item.get(ast.thing.input) do
          {:ok, item} ->
            maybe_sit_relative_to_item(
              context,
              List.first(Search.things_to_match(item)),
              ast.thing.where || "on"
            )

          _ ->
            Util.dave_error_v2(context)
        end

      true ->
        find_furniture_to_sit_relative_to(context)
    end
  end

  defp find_furniture_to_sit_relative_to(context) do
    ast = context.command.ast

    area_results =
      Search.find_matches_on_ground(
        context.character.area_id,
        ast.thing.input,
        context.character.settings.commands.search_mode
      )

    case area_results do
      {:ok, area_matches} when area_matches != [] ->
        area_matches = area_matches

        maybe_sit_relative_to_item(
          context,
          List.first(area_matches),
          ast.thing.where || "on",
          Enum.slice(area_matches, 1..length(area_matches))
        )

      _ ->
        Util.not_found_error(context)
    end
  end

  defp maybe_sit_relative_to_item(
         context,
         thing = %Search.Match{},
         relative_place,
         other_matches \\ []
       ) do
    cond do
      thing.match.flags.has_surface and thing.match.surface.can_hold_characters and
          not context.character.status.position_relative_to_item ->
        sit_relative_to_item(
          context,
          thing,
          relative_place,
          other_matches
        )

      thing.match.flags.has_surface and thing.match.surface.can_hold_characters and
        context.character.status.position_relative_to_item and
          context.character.status.item_id != thing.match.id ->
        Context.append_message(
          context,
          Message.new_story_output(
            context.character.id,
            "You must stand before you can move to another piece of furniture.",
            "system_info"
          )
        )

      not thing.match.flags.has_surface or
          (thing.match.flags.has_surface and not thing.match.surface.can_hold_characters) ->
        message =
          Message.new_story_output(context.character.id)
          |> Message.append_text(
            Util.upcase_first(thing.match.description.short),
            Util.get_item_type(thing.match)
          )
          |> Message.append_text(" cannot be sat on.", "system_alert")

        Context.append_message(
          context,
          message
        )
    end
  end

  defp sit_relative_to_item(
         context,
         thing = %Search.Match{},
         relative_place,
         other_matches \\ []
       ) do
    furniture_slots_used = Surface.character_slots_used(thing.match.id, context.character.id)

    if furniture_slots_used + 1 > thing.match.surface.character_limit do
      CallbackUtil.furniture_full_error(context, thing.match, relative_place)
    else
      original_status = context.character.status

      updated_status =
        Mud.Engine.Character.Status.update!(original_status, %{
          position: "sitting",
          position_relation: relative_place,
          position_relative_to_item: true,
          item_id: thing.match.id
        })

      character = Map.put(context.character, :status, updated_status)

      others =
        Character.list_others_active_in_areas(
          context.character.id,
          context.character.area_id
        )

      other_msg =
        others
        |> Message.new_story_output()
        |> Message.append_text("[#{context.character.name}]", "character")
        |> Message.append_text(
          " #{other_sitting_message(original_status.position)} #{relative_place} ",
          "base"
        )
        |> Message.append_text(thing.match.description.short, Util.get_item_type(thing.match))
        |> Message.append_text(".", "base")

      self_msg =
        context.character.id
        |> Message.new_story_output()
        |> Message.append_text("You", "character")
        |> Message.append_text(
          " #{self_sitting_message(original_status.position)} #{relative_place} ",
          "base"
        )
        |> Message.append_text(thing.match.description.short, Util.get_item_type(thing.match))
        |> Message.append_text(".", "base")

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

      context
      |> Context.append_event(
        character.id,
        UpdateCharacter.new(%{action: "status", status: updated_status})
      )
      |> Context.append_event(
        [context.character_id | others],
        UpdateArea.new(%{action: :update, other_characters: [character]})
      )
      |> Context.append_message(other_msg)
      |> Context.append_message(self_msg)
    end
  end

  defp maybe_sit_on_ground(context) do
    if context.character.status.position_relative_to_item do
      case Item.get(context.character.status.item_id) do
        {:ok, item} ->
          sit_relative_to_item(
            context,
            List.first(Search.things_to_match(item)),
            "on"
          )

        _ ->
          Util.dave_error_v2(context)
      end
    else
      sit_on_ground(context)
    end
  end

  defp sit_on_ground(context) do
    original_status = context.character.status

    updated_status = Mud.Engine.Character.Status.update!(original_status, %{position: "sitting"})

    character = Map.put(context.character, :status, updated_status)

    others =
      Character.list_others_active_in_areas(
        context.character.id,
        context.character.area_id
      )

    other_msg =
      others
      |> Message.new_story_output()
      |> Message.append_text("[#{context.character.name}]", "character")
      |> Message.append_text(
        " #{other_sitting_message(original_status.position)}.",
        "base"
      )

    self_msg =
      context.character.id
      |> Message.new_story_output()
      |> Message.append_text("You", "character")
      |> Message.append_text(
        " #{self_sitting_message(original_status.position)}.",
        "base"
      )

    context
    |> Context.append_event(
      character.id,
      UpdateCharacter.new(%{action: "status", status: updated_status})
    )
    |> Context.append_event(
      [context.character_id | others],
      UpdateArea.new(%{action: :update, other_characters: [character]})
    )
    |> Context.append_message(other_msg)
    |> Context.append_message(self_msg)
  end

  defp other_sitting_message("lying"),
    do: "sits up"

  defp other_sitting_message(_), do: "sits down"

  defp self_sitting_message("lying"), do: "sit up"
  defp self_sitting_message(_old_position), do: "sit down"
end
