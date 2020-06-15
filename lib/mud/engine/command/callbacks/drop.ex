defmodule Mud.Engine.Command.Drop do
  @moduledoc """
  The DROP command allows a character to drop a held item onto the ground.

  An optional number, which selects which item in case of a multiple match conflict, may be provided.

  Syntax:
    - drop <which> <item>

  Examples:
    - drop sword
    - drop pink uni
    - drop 2 appl
  """

  use Mud.Engine.Command.Callback

  alias Mud.Engine.Search
  alias Mud.Engine.Util
  alias Mud.Engine.Command.ExecutionContext
  alias Mud.Engine.{Character, Item}

  require Logger

  @impl true
  def continue(context) do
    drop_thing(context, context.input)
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

      if length(held_items) == 0 do
        ExecutionContext.append_output(
          context,
          context.character.id,
          "You aren't holding anything.",
          "error"
        )
        |> ExecutionContext.set_success()
      else
        ast = context.command.ast

        matches =
          Search.generate_matches(held_items, ast.thing.input, context.character, ast.thing.which)

        case matches do
          {:ok, [match]} ->
            drop_thing(context, match)

          {:ok, matches} when length(matches) > 1 ->
            Util.handle_multiple_items(
              context,
              Enum.map(matches, & &1.glance_description),
              matches,
              "Which thing did you wish to drop?",
              ""
            )

          _ ->
            ExecutionContext.append_output(
              context,
              context.character.id,
              "Could not find what you were attempting to drop.",
              "error"
            )
            |> ExecutionContext.set_success()
        end
      end
    end
  end

  defp drop_thing(context, match) do
    Item.update!(match.match, %{
      holdable_held_by_id: nil,
      holdable_hand: nil,
      area_id: context.character.area_id
    })

    other_msg =
      "{{character}}#{context.character.name}{{/character}} drops {{item}}#{
        match.glance_description
      }{{/item}} on the ground."

    self_msg = "You drop {{item}}#{match.glance_description}{{/item}} on the ground."

    others = Character.list_others_active_in_areas(context.character.id, context.character.area_id)

    context
    |> ExecutionContext.append_output(
      others,
      other_msg,
      "info"
    )
    |> ExecutionContext.append_output(
      context.character.id,
      self_msg,
      "info"
    )
    |> ExecutionContext.set_success()
  end
end
