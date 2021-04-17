defmodule Mud.Engine.Command.Lie do
  @moduledoc """
  The CROUCH command moves the character into a laying down position.

  If no target is provided, the Character will lie in place.

  Syntax:
    - lie [on] target

  Examples:
    - lie
    - lie chair
    - lie on chair
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
      context.character.status.position == "lying" ->
        Context.append_message(
          context,
          Message.new_story_output(
            context.character.id,
            "You are already laying down.",
            "system_info"
          )
        )

      is_nil(ast.thing) ->
        maybe_lie_on_ground(context)

      Util.is_uuid4(ast.thing.input) ->
        Logger.debug("Lie command provided with uuid: #{ast.thing.input}")

        case Item.get(ast.thing.input) do
          {:ok, item} ->
            maybe_lie_relative_to_item(
              context,
              List.first(Search.things_to_match(item)),
              ast.thing.where || "on"
            )

          _ ->
            Util.dave_error_v2(context)
        end

      true ->
        find_furniture_to_lie_relative_to(context)
    end
  end

  defp find_furniture_to_lie_relative_to(context) do
    ast = context.command.ast

    area_results =
      Search.find_furniture_in_area(
        context.character.area_id,
        ast.thing.input,
        context.character.settings.commands.search_mode
      )

    case area_results do
      {:ok, area_matches} when area_matches != [] ->
        maybe_lie_relative_to_item(
          context,
          List.first(area_matches),
          ast.thing.where || "on",
          Enum.slice(area_matches, 1..length(area_matches))
        )

      _ ->
        Util.not_found_error(context)
    end
  end

  defp maybe_lie_relative_to_item(
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
      lie_relative_to_item(
        context,
        thing,
        relative_place,
        other_matches
      )
    end
  end

  defp lie_relative_to_item(
         context,
         thing = %Search.Match{},
         relative_place,
         other_matches \\ []
       ) do
    furniture_slots_used = Furniture.slots_used(thing.match.id, context.character.id)

    if furniture_slots_used + 3 > thing.match.furniture.external_surface_size do
      CallbackUtil.furniture_full_error(context, thing.match, relative_place)
    else
      original_status = context.character.status

      updated_status =
        Mud.Engine.Character.Status.update!(context.character.status, %{
          position: "lying",
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
          " #{other_laying_down_message(original_status.position)} #{relative_place} ",
          "base"
        )
        |> Message.append_text(thing.match.description.short, Util.get_item_type(thing.match))
        |> Message.append_text(".", "base")

      self_msg =
        context.character.id
        |> Message.new_story_output()
        |> Message.append_text("You", "character")
        |> Message.append_text(
          " #{self_laying_down_message(original_status.position)} #{relative_place} ",
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

  defp maybe_lie_on_ground(context) do
    if context.character.status.position_relative_to_item do
      case Item.get(context.character.status.item_id) do
        {:ok, item} ->
          lie_relative_to_item(
            context,
            List.first(Search.things_to_match(item)),
            "on"
          )

        _ ->
          Util.dave_error_v2(context)
      end
    else
      lie_on_ground(context)
    end
  end

  defp lie_on_ground(context) do
    original_status = context.character.status

    updated_status = Mud.Engine.Character.Status.update!(original_status, %{position: "lying"})

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
        " #{other_laying_down_message(original_status.position)}.",
        "base"
      )

    self_msg =
      context.character.id
      |> Message.new_story_output()
      |> Message.append_text("You", "character")
      |> Message.append_text(
        " #{self_laying_down_message(original_status.position)}.",
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

  defp other_laying_down_message(_), do: "lays down"

  defp self_laying_down_message(_), do: "lie down"
end
