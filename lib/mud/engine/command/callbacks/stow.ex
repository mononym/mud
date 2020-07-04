defmodule Mud.Engine.Command.Stow do
  @moduledoc """
  The STOW command allows a character to 'stow' items that are held or on the ground in a container.

  Not providing a place to store an item will mean the primary container, if there is one, will be used.

  Syntax:
    - stow <thing> in <place>

  Examples:
    - stow gem in gembag
    - stow rock
  """
  use Mud.Engine.Command.Callback

  alias Mud.Engine.Event.Client.{UpdateArea, UpdateInventory}
  alias Mud.Engine.Item
  alias Mud.Engine.Character
  alias Mud.Engine.Command.ExecutionContext
  alias Mud.Engine.Util
  alias Mud.Engine.Search

  require Logger

  @spec build_ast([Mud.Engine.Command.AstNode.t(), ...]) ::
          Mud.Engine.Command.AstNode.ThingAndPlace.t()
  def build_ast(ast_nodes) do
    Mud.Engine.Command.AstUtil.build_tap_ast(ast_nodes)
  end

  @impl true
  def execute(context) do
    case Item.get_primary_container(context.character) do
      nil ->
        ExecutionContext.append_error(
          context,
          "You must be wearing at least one container and have a primary container chosen for STOW to work."
        )

      primary_container ->
        ast = context.command.ast

        cond do
          is_nil(ast.thing) ->
            # put everything away
            held_items = Character.list_held_items(context.character)

            stow_items(context, held_items, primary_container, true)

          not is_nil(ast.thing) ->
            if Util.is_uuid4(ast.thing.input) do
              item = Item.get!(ast.thing.input)

              IO.inspect({item, context.character}, label: :stow)
              IO.inspect(item.holdable_held_by_id == context.character.id, label: :stow)
              IO.inspect(item.area_id == context.character.area_id, label: :stow)
              IO.inspect(not is_nil(item.container_id), label: :stow)

              cond do
                item.holdable_held_by_id == context.character.id ->
                  stow_items(context, [item], primary_container, true)

                item.area_id == context.character.area_id ->
                  stow_items(context, [item], primary_container, false)

                not is_nil(item.container_id) ->
                  validate_parentage_and_stow(context, item, primary_container)

                true ->
                  Util.dave_error(context)
              end
            else
              find_item_to_stow(context, primary_container)
            end
        end
    end
  end

  defp find_item_to_stow(context, primary_container) do
    ast = context.command.ast
    held_items = Character.list_held_items(context.character)

    case Search.generate_matches(held_items, ast.thing.input, ast.thing.which) do
      {:ok, [match]} ->
        stow_items(context, [match.match], primary_container, true)

      {:ok, _matches} ->
        Util.multiple_error(context)

      _error ->
        result =
          Search.find_matches_in_area_v2(
            [:item],
            context.character.area_id,
            ast.thing.input,
            ast.thing.which
          )

        case result do
          {:ok, [match]} ->
            stow_items(context, [match.match], primary_container, false)

          {:ok, _matches} ->
            Util.multiple_error(context)

          _error ->
            ExecutionContext.append_error(
              context,
              "Could not find anything like that to stow. Please try again."
            )
        end
    end
  end

  defp validate_parentage_and_stow(context, item, primary_container) do
    items = Item.list_all_recursive(item)
    parent = Enum.find(items, &is_nil(&1.container_id))

    if parent.area_id == context.character.area_id do
      stow_items(context, [item], primary_container, false)
    else
      Util.dave_error(context)
    end
  end

  defp stow_items(context, items, primary_container, private) do
    items =
      Enum.map(items, fn item ->
        Item.update!(item.id, %{
          area_id: nil,
          holdable_hand: nil,
          holdable_is_held: false,
          holdable_held_by_id: nil,
          container_id: primary_container.id
        })
      end)

    descriptions = Enum.map(items, & &1.short_description)
    desc_string = "{{item}}#{Enum.join(descriptions, "{{/item}} and {{item}}")}{{/item}}"

    others = Character.list_active_in_areas(context.character.id)

    all_items = Item.list_all_recursive(items)
    IO.inspect(items, label: :items)
    IO.inspect(all_items, label: :all_items)

    if private do
      ExecutionContext.append_event(
        context,
        context.character_id,
        UpdateInventory.new(:update, items)
      )
    else
      context
      |> ExecutionContext.append_event(
        context.character_id,
        UpdateInventory.new(:add, all_items)
      )
      |> ExecutionContext.append_event(
        [context.character_id | others],
        UpdateArea.new(:remove, all_items)
      )
    end
    |> ExecutionContext.append_output(
      others,
      "{{character}}#{context.character.name}{{/character}} stowed #{desc_string} in their {{item}}#{
        primary_container.short_description
      }{{/item}}.",
      "info"
    )
    |> ExecutionContext.append_output(
      context.character.id,
      "{{item}}#{String.capitalize(primary_container.short_description)}{{/item}} now contains #{
        desc_string
      }.",
      "info"
    )
  end
end
