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
        sit_on_ground(context)

      Util.is_uuid4(ast.thing.input) ->
        Logger.debug("Sit command provided with uuid: #{ast.thing.input}")

        case Item.get(ast.thing.input) do
          {:ok, item} ->
            sit_relative_to_item(context, List.first(Search.things_to_match(item)))

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
        sit_relative_to_item(
          context,
          List.first(area_matches),
          Enum.slice(area_matches, 1..length(area_matches))
        )

      _ ->
        Util.not_found_error(context)
    end
  end

  defp sit_relative_to_item(context, thing = %Search.Match{}, _other_matches \\ []) do
    # TODO: Check to see if there are already too many characters already sitting relative to the item
    # and reject the attempt if there is.
    furniture_full = false
    relative_place = thing.match.where || "on"

    if furniture_full do
      CallbackUtil.furniture_full_error(context, thing.match, relative_place)
    else
      updated_status =
        Mud.Engine.Character.Status.update!(context.character.status, %{
          position: "sitting",
          position_relation: relative_place,
          position_relative_to_item: true
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
        |> Message.append_text(" sits down #{relative_place} ", "base")
        |> Message.append_text(thing.match.description.short, Util.get_item_type(thing.match))
        |> Message.append_text(".", "base")

      self_msg =
        context.character.id
        |> Message.new_story_output()
        |> Message.append_text("You", "character")
        |> Message.append_text(" sit down #{relative_place} ", "base")
        |> Message.append_text(thing.match.description.short, Util.get_item_type(thing.match))
        |> Message.append_text(".", "base")

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

  defp sit_on_ground(context) do
    updated_status =
      Mud.Engine.Character.Status.update!(context.character.status, %{position: "sitting"})

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
      |> Message.append_text(" sits down.", "base")

    self_msg =
      context.character.id
      |> Message.new_story_output()
      |> Message.append_text("You", "character")
      |> Message.append_text(" sit down.", "base")

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
