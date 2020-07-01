defmodule Mud.Engine.Command.Sit do
  @moduledoc """
  The SIT command moves the character into a sitting position.

  If no target is provided, the Character will sit in place.

  Syntax:
    - sit < on | in > target

  Examples:
    - sit
    - sit chair
    - sit on chair
  """
  use Mud.Engine.Command.Callback

  alias Mud.Engine.Command.ExecutionContext
  alias Mud.Engine.{Character, Item}
  alias Mud.Engine.Util
  alias Mud.Engine.Search
  alias Mud.Engine.Message
  alias Mud.Engine.Event.Client.{UpdateArea, UpdateCharacter}

  require Logger

  @spec build_ast([Mud.Engine.Command.AstNode.t(), ...]) ::
          Mud.Engine.Command.AstNode.OneThing.t()
  def build_ast(ast_nodes) do
    Mud.Engine.Command.AstUtil.build_one_thing_ast(ast_nodes)
  end

  @impl true
  def execute(%ExecutionContext{} = context) do
    ast = context.command.ast

    if is_nil(ast.thing) do
      make_character_sit(context)
    else
      sit_on_target(context)
    end
  end

  def sit_on_target(context) do
    ast = context.command.ast

    if Util.is_uuid4(ast.thing.input) do
      item = Item.get!(ast.thing.input)

      if item.area_id == context.character.area_id do
        make_character_sit(context, item)
      else
        ExecutionContext.append_output(
          context,
          context.character.id,
          "{{error}}I'm sorry #{context.character.name}, I'm afraid I can't do that.{{/error}}",
          "error"
        )
        |> ExecutionContext.set_success()
      end
    else
      result =
        Search.find_matches_in_area_v2(
          [:item],
          context.character.area_id,
          ast.thing.input,
          ast.thing.which
        )

      case result do
        {:ok, [thing]} ->
          make_character_sit(context, thing.match)

        {:ok, _matches} ->
          ExecutionContext.append_output(
            context,
            context.character.id,
            "Multiple potential places to sit found. Please be more specific.",
            "error"
          )
          |> ExecutionContext.set_success()

        {:error, :no_match} ->
          ExecutionContext.append_output(
            context,
            context.character.id,
            "Could not find anywhere to sit.",
            "error"
          )
          |> ExecutionContext.set_success()
      end
    end
  end

  @spec make_character_sit(context :: ExecutionContext.t(), furniture_object :: Object.t() | nil) ::
          ExecutionContext.t()
  defp make_character_sit(context, furniture_object \\ nil) do
    char = context.character

    cond do
      char.position == Character.sitting() ->
        ExecutionContext.append_message(
          context,
          Message.new_output(
            context.character.id,
            "You are already sitting down!",
            "error"
          )
        )
        |> ExecutionContext.set_success()

      furniture_object == nil ->
        update = %{
          position: Character.sitting(),
          relative_position: "",
          relative_item_id: nil
        }

        {:ok, char} = Character.update(context.character, update)

        others =
          Character.list_others_active_in_areas(context.character.id, context.character.area_id)

        context
        |> ExecutionContext.append_message(
          Message.new_output(
            others,
            "#{context.character.name} sits down.",
            "info"
          )
        )
        |> ExecutionContext.append_message(
          Message.new_output(
            context.character.id,
            "You sit down.",
            "info"
          )
        )
        |> ExecutionContext.append_event(
          others,
          UpdateArea.new(:update, char)
        )
        |> ExecutionContext.append_event(
          context.character.id,
          UpdateCharacter.new(:update, char)
        )
        |> ExecutionContext.set_success()

      furniture_object != nil and furniture_object.is_furniture and
          char.position != Character.sitting() ->
        update = %{
          position: Character.sitting(),
          relative_position: "on",
          relative_item_id: furniture_object.id
        }

        Character.update(context.character, update)

        others =
          Character.list_others_active_in_areas(context.character.id, context.character.area_id)

        context
        |> ExecutionContext.append_message(
          Message.new_output(
            others,
            "#{context.character.name} sits down on #{furniture_object.short_description}.",
            "info"
          )
        )
        |> ExecutionContext.append_message(
          Message.new_output(
            context.character.id,
            "You sit down on #{furniture_object.short_description}.",
            "info"
          )
        )
        |> ExecutionContext.append_event(
          others,
          UpdateArea.new(:update, char)
        )
        |> ExecutionContext.append_event(
          context.character.id,
          UpdateCharacter.new(:update, char)
        )
        |> ExecutionContext.set_success()

      true ->
        ExecutionContext.append_message(
          context,
          Message.new_output(
            context.character.id,
            "Unfortunately, #{furniture_object.short_description} can not be sat on.",
            "error"
          )
        )
        |> ExecutionContext.set_success()
    end
  end
end
