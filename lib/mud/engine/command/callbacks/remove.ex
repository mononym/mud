defmodule Mud.Engine.Command.Remove do
  @moduledoc """
  The REMOVE command allows a character to 'remove' things from a container and place them on the ground.

  Syntax:
    - remove <thing> from <place>

  Examples:
    - remove gem from gembag
  """
  use Mud.Engine.Command.Callback

  alias Mud.Engine.Item
  alias Mud.Engine.Character
  alias Mud.Engine.Command.ExecutionContext
  alias Mud.Engine.Util
  alias Mud.Engine.Search

  require Logger

  defmodule ContinuationData do
    use TypedStruct

    typedstruct do
      field(:type, atom(), required: true)
      field(:thing, Mud.Engine.Search.Match.t(), required: true)
      field(:place, Mud.Engine.Search.Match.t(), required: true)
    end
  end

  @impl true
  def continue(context) do
    held_items = Character.list_held_items(context.character)

    if length(held_items) == 2 do
      ExecutionContext.append_output(
        context,
        context.character.id,
        "Your hands are full. Empty at least one of them first.",
        "error"
      )
      |> ExecutionContext.set_success()
    else
      remove_thing(context, context.input, held_items)
    end
  end

  @spec build_ast([Mud.Engine.Command.AstNode.t(), ...]) ::
          Mud.Engine.Command.AstNode.OneThing.t()
  def build_ast(ast_nodes) do
    Mud.Engine.Command.AstUtil.build_one_thing_ast(ast_nodes)
  end

  @impl true
  def execute(context) do
    ast = context.command.ast

    if is_nil(ast.thing) do
      ExecutionContext.append_output(
        context,
        context.character.id,
        Util.get_module_docs(__MODULE__),
        "error"
      )
      |> ExecutionContext.set_success()
    else
      held_items = Character.list_held_items(context.character)

      if length(held_items) == 2 do
        ExecutionContext.append_output(
          context,
          context.character.id,
          "Your hands are full. Empty at least one of them first.",
          "error"
        )
        |> ExecutionContext.set_success()
      else
        ast = context.command.ast
        worn_items = Character.list_worn_items(context.character)

        matches =
          Search.generate_matches(worn_items, ast.thing.input, context.character, ast.thing.which)

        case matches do
          {:ok, [match]} ->
            remove_thing(context, match, worn_items)

          {:ok, matches} when length(matches) > 1 ->
            Util.handle_multiple_items(
              context,
              Enum.map(matches, & &1.glance_description),
              matches,
              "Which thing did you wish to remove?"
            )

          _ ->
            ExecutionContext.append_output(
              context,
              context.character.id,
              "Could not find what you were attempting to remove.",
              "error"
            )
            |> ExecutionContext.set_success()
        end
      end
    end
  end

  defp remove_thing(context, match, held_items) do
    Item.update!(match.match, %{
      wearable_worn_by_id: nil,
      wearable_is_worn: false,
      holdable_held_by_id: context.character.id,
      holdable_is_held: true,
      holdable_hand: Character.which_hand(context.character, held_items)
    })

    others = Character.list_others_active_in_areas(context.character, context.character.area_id)

    context
    |> ExecutionContext.append_output(
      others,
      "{{character}}#{context.character.name}{{/character}} removed {{item}}#{
        match.glance_description
      }{{/item}} from their {{bodypart}}#{match.match.wearable_location}{{/bodypart}}.",
      "info"
    )
    |> ExecutionContext.append_output(
      context.character.id,
      String.capitalize(
        "You remove {{item}}#{match.glance_description}{{/item}} from your {{bodypart}}#{
          match.match.wearable_location
        }{{/bodypart}}."
      ),
      "info"
    )
    |> ExecutionContext.set_success()
  end
end
