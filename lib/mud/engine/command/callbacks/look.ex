defmodule Mud.Engine.Command.Look do
  @moduledoc """
  Allows a Character to 'see' the world around them.

  Current algorithm allows for looking at items and characters, and into the next area.
  """
  use Mud.Engine.Command.Callback

  alias Mud.Engine.Area
  alias Mud.Engine.Search
  alias Mud.Engine.Character
  alias Mud.Engine.Item
  alias Mud.Engine.Command.ExecutionContext
  alias Mud.Engine.Util
  alias Mud.Engine.Command.AstUtil
  alias Mud.Engine.Command.AstNode.ThingAndPlace, as: TAP
  alias Mud.Engine.Command.AstNode.{Thing, Place}
  alias Mud.Engine.Message
  alias Mud.Engine.Command.SingleTargetCallback

  require Logger

  defmodule ContinuationData do
    @enforce_keys [:data, :type]
    defstruct type: nil,
              data: nil
  end

  def build_ast(ast_nodes) do
    AstUtil.build_tap_ast(ast_nodes)
  end

  @impl true
  def continue(context) do
    match = Util.refresh_thing(context.input.match)
    look_in_or_at(context, match)
  end

  @impl true
  def execute(context) do
    Logger.debug(inspect(context.command.ast))

    ast = context.command.ast

    case ast do
      %TAP{thing: nil} ->
        description = Area.describe_look(context.character.area_id, context.character)

        context
        |> ExecutionContext.append_message(Message.new_output(context.character_id, description))
        |> ExecutionContext.set_success()

      %TAP{place: nil, thing: %Thing{personal: false}} ->
        look_area_then_worn(context)

      %TAP{place: nil, thing: %Thing{personal: true}} ->
        look_worn(context)

      %TAP{place: %Place{personal: place}, thing: %Thing{personal: thing}} when place or thing ->
        look_worn(context)

      %TAP{place: %Place{personal: place}, thing: %Thing{personal: thing}}
      when not place and not thing ->
        look_area_then_worn(context)
    end
  end

  defp look_area_then_worn(context) do
    ast = context.command.ast

    if is_nil(ast.place) do
      result =
        Search.find_matches_in_area_v2(
          target_types(),
          context.character.area_id,
          ast.thing.input,
          context.character,
          ast.thing.which
        )

      case result do
        {:ok, [match]} ->
          look_in_or_at(context, match)

        {:ok, matches} ->
          SingleTargetCallback.handle_multiple_matches(
            context,
            matches,
            "What were you trying to look at?",
            "Please be more specific."
          )

        _error ->
          look_worn(context)
      end
    else
      items = Item.list_in_area(context.character.area_id)

      case follow_path(context, ast.place, items) do
        {:ok, items} ->
          look_items(context, items)

        {:error, _error} ->
          look_worn(context)

        result ->
          result
      end
    end
  end

  # May or may not have place specified
  defp look_worn(context) do
    ast = context.command.ast

    held_items = Character.list_held_items(context.character)
    worn_items = Character.list_worn_items(context.character)
    all_personal_items = held_items ++ worn_items

    if is_nil(ast.place) do
      look_items(context, all_personal_items)
    else
      case follow_path(context, ast.place, all_personal_items) do
        {:ok, items} ->
          look_items(context, items)

        {:error, _error} ->
          ExecutionContext.append_output(
            context,
            context.character.id,
            "Could not find what you were looking for.",
            "error"
          )
          |> ExecutionContext.set_success()

        result ->
          result
      end
    end
  end

  defp look_items(context, items) do
    ast = context.command.ast

    case Search.generate_matches(items, ast.thing.input, context.character, ast.thing.which) do
      {:ok, [match]} ->
        look_in_or_at(context, match)

      {:ok, matches} ->
        SingleTargetCallback.handle_multiple_matches(
          context,
          matches,
          "What were you trying to look at?",
          "Please be more specific."
        )

      _error ->
        ExecutionContext.append_output(
          context,
          context.character.id,
          "Could not find what you were looking for.",
          "error"
        )
        |> ExecutionContext.set_success()
    end
  end

  # given a place, which may or may not have nested children, and a set of items to test against, dig through the stack
  # to see if there is a match.
  defp follow_path(context, place, items) do
    ast = context.command.ast

    case Search.generate_matches(items, place.input, context.character, ast.place.which) do
      {:ok, [match]} ->
        if is_nil(place.path) do
          {:ok, list_relative_items(place.where, match.match)}
        else
          items = list_relative_items(place.where, match.match)
          follow_path(context, place.path, items)
        end

      {:ok, matches} ->
        SingleTargetCallback.handle_multiple_matches(
          context,
          matches,
          "Which of these containers did you mean?",
          "Please be more specific."
        )

      error ->
        error
    end
  end

  defp list_relative_items("in", item) do
    Item.list_contained_items(item.id)
  end

  @spec look_in_or_at(ExecutionContext.t(), Mud.Engine.Search.Match.t()) ::
          ExecutionContext.t()
  defp look_in_or_at(context, match) do
    ast = context.command.ast

    cond do
      ast.thing.where == "in" ->
        thing = match.match

        cond do
          thing.is_container and thing.container_open ->
            # get things in container and look at them
            thing = Mud.Repo.preload(thing, :container_items)

            items_description =
              Stream.map(thing.container_items, fn item ->
                Item.describe_glance(item, context.character)
              end)
              |> Enum.join("{{/item}}, {{item}}")

            container_desc = String.capitalize(match.glance_description)

            if length(thing.container_items) > 0 do
              ExecutionContext.append_message(
                context,
                Message.new_output(
                  context.character.id,
                  "{{item}}#{container_desc}{{/item}} contains: {{item}}#{items_description}{{/item}}.",
                  "info"
                )
              )
              |> ExecutionContext.set_success()
            else
              ExecutionContext.append_message(
                context,
                Message.new_output(
                  context.character.id,
                  "{{item}}#{container_desc}{{/item}} is empty.",
                  "info"
                )
              )
              |> ExecutionContext.set_success()
            end

          thing.is_container and not thing.container_open ->
            ExecutionContext.append_message(
              context,
              Message.new_output(
                context.character.id,
                String.capitalize(
                  "{{item}}#{match.glance_description}{{/item}} must be opened first."
                ),
                "info"
              )
            )
            |> ExecutionContext.set_success()

          not thing.is_container ->
            ExecutionContext.append_message(
              context,
              Message.new_output(
                context.character.id,
                "You cannot look inside {{item}}#{match.glance_description}{{/item}}.",
                "info"
              )
            )
            |> ExecutionContext.set_success()
        end

      true ->
        ExecutionContext.append_message(
          context,
          Message.new_output(
            context.character.id,
            match.look_description,
            "info"
          )
        )
        |> ExecutionContext.set_success()
    end
  end

  defp target_types(), do: [:character, :item, :link]
end
