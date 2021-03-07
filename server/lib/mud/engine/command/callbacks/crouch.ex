defmodule Mud.Engine.Command.Crouch do
  @moduledoc """
  The CROUCH command moves the character into a crouching position.

  If no target is provided, the Character will crouch in place.

  Syntax:
    - crouch [on] target

  Examples:
    - crouch
    - crouch chair
    - crouch on chair
  """
  use Mud.Engine.Command.Callback

  alias Mud.Engine.Command.Context
  alias Mud.Engine.Command.CallbackUtil
  alias Mud.Engine.{Character, Item}
  alias Mud.Engine.Event.Client.UpdateArea
  alias Mud.Engine.Event.Client.UpdateCharacter
  alias Mud.Engine.Message
  alias Mud.Engine.Search
  alias Mud.Engine.Util
  alias Mud.Engine.Item.Furniture

  require Logger

  def build_ast(ast_nodes) do
    Mud.Engine.Command.AstUtil.build_one_thing_ast(ast_nodes)
  end

  @impl true
  def execute(%Context{} = context) do
    ast = context.command.ast

    cond do
      context.character.status.position == "crouching" ->
        Context.append_message(
          context,
          Message.new_story_output(
            context.character.id,
            "You are already crouching.",
            "system_info"
          )
        )

      is_nil(ast.thing) ->
        maybe_crouch_on_ground(context)

      Util.is_uuid4(ast.thing.input) ->
        Logger.debug("Crouch command provided with uuid: #{ast.thing.input}")

        case Item.get(ast.thing.input) do
          {:ok, item} ->
            maybe_crouch_relative_to_item(
              context,
              List.first(Search.things_to_match(item)),
              ast.thing.where || "on"
            )

          _ ->
            Util.dave_error_v2(context)
        end

      true ->
        find_furniture_to_crouch_relative_to(context)
    end
  end

  defp find_furniture_to_crouch_relative_to(context) do
    ast = context.command.ast

    area_results =
      Search.find_furniture_in_area(
        context.character.area_id,
        ast.thing.input,
        context.character.settings.commands.search_mode
      )

    case area_results do
      {:ok, area_matches} when area_matches != [] ->
        maybe_crouch_relative_to_item(
          context,
          List.first(area_matches),
          ast.thing.where || "on",
          Enum.slice(area_matches, 1..length(area_matches))
        )

      _ ->
        Util.not_found_error(context)
    end
  end

  defp maybe_crouch_relative_to_item(
         context,
         thing = %Search.Match{},
         relative_place,
         other_matches \\ []
       ) do
    if context.character.status.position_relative_to_item and
         context.character.status.item_id != thing.match.id do
      Context.append_message(
        context,
        Message.new_story_output(
          context.character.id,
          "You must stand before you can move to another piece of furniture.",
          "system_info"
        )
      )
    else
      crouch_relative_to_item(
        context,
        thing,
        relative_place,
        other_matches
      )
    end
  end

  defp crouch_relative_to_item(
         context,
         thing = %Search.Match{},
         relative_place,
         other_matches \\ []
       ) do
    furniture_slots_used = Furniture.slots_used(thing.match.id, context.character.id)

    if furniture_slots_used + 1 > thing.match.furniture.external_surface_size do
      CallbackUtil.furniture_full_error(context, thing.match, relative_place)
    else
      original_status = context.character.status

      updated_status =
        Mud.Engine.Character.Status.update!(original_status, %{
          position: "crouching",
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
          " #{other_crouching_message(original_status.position, character)} #{relative_place} ",
          "base"
        )
        |> Message.append_text(thing.match.description.short, Util.get_item_type(thing.match))
        |> Message.append_text(".", "base")

      self_msg =
        context.character.id
        |> Message.new_story_output()
        |> Message.append_text("You", "character")
        |> Message.append_text(
          " #{self_crouching_message(original_status.position)} #{relative_place} ",
          "base"
        )
        |> Message.append_text(thing.match.description.short, Util.get_item_type(thing.match))
        |> Message.append_text(".", "base")

      self_msg =
        if other_matches != [] do
          other_items = Enum.map(other_matches, & &1.match)

          Util.append_assumption_text(
            self_msg,
            thing.match,
            other_items,
            context.character.settings.commands.multiple_matches_mode
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

  defp maybe_crouch_on_ground(context) do
    if context.character.status.position_relative_to_item do
      case Item.get(context.character.status.item_id) do
        {:ok, item} ->
          crouch_relative_to_item(
            context,
            List.first(Search.things_to_match(item)),
            "on"
          )

        _ ->
          Util.dave_error_v2(context)
      end
    else
      crouch_on_ground(context)
    end
  end

  defp crouch_on_ground(context) do
    original_status = context.character.status

    updated_status =
      Mud.Engine.Character.Status.update!(original_status, %{position: "crouching"})

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
        " #{other_crouching_message(original_status.position, character)}.",
        "base"
      )

    self_msg =
      context.character.id
      |> Message.new_story_output()
      |> Message.append_text("You", "character")
      |> Message.append_text(
        " #{self_crouching_message(original_status.position)}.",
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

  defp other_crouching_message("standing", _pronoun), do: "crouches down"

  defp other_crouching_message("sitting", _pronoun),
    do: "rises to a crouch"

  defp other_crouching_message("kneeling", pronoun),
    do: "shifts #{Util.his_her_their(pronoun)} weight backwards and crouches"

  defp other_crouching_message("lying", __pronoun),
    do: "rises to a crouch"

  defp self_crouching_message("standing"), do: "crouch down"
  defp self_crouching_message("sitting"), do: "rise to a crouch"
  defp self_crouching_message("crouching"), do: "shift your weight backwards and crouch"
  defp self_crouching_message("lying"), do: "rise to a crouch"
end
