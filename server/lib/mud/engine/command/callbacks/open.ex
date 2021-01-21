defmodule Mud.Engine.Command.Open do
  @moduledoc """
  The CLOSE command allows the Character to open something such as a door or a chest.

  Syntax:
    - open <target>

  Examples:
    - open backpack
    - open door
    - open pouch in backpack
  """

  alias Mud.Engine.Event.Client.{UpdateInventory}
  alias Mud.Engine.Message
  alias Mud.Engine.Util
  alias Mud.Engine.Command.Context
  alias Mud.Engine.{Character, Item}

  require Logger

  use Mud.Engine.Command.Callback

  @spec build_ast([Mud.Engine.Command.AstNode.t(), ...]) ::
          Mud.Engine.Command.AstNode.OneThing.t()
  def build_ast(ast_nodes) do
    Mud.Engine.Command.AstUtil.build_one_thing_ast(ast_nodes)
  end

  @impl true
  def execute(context) do
    ast = context.command.ast

    if is_nil(ast.thing) do
      Context.append_output(
        context,
        context.character.id,
        Util.get_module_docs(__MODULE__),
        "error"
      )
    else
      if Util.is_uuid4(context.command.ast.thing.input) do
        item = Item.get!(context.command.ast.thing.input)

        # Open an item that is worn on the character executing the command
        if Util.is_item_on_character?(item, context.character) do
          open_thing(context, item)
        else
          Util.dave_error(context)
        end
      else
        find_thing_to_open(context)
      end
    end
  end

  defp find_thing_to_open(context) do
    # held_items = Character.list_held_items(context.character)

    # if length(held_items) == 0 do
    #   context
    #   |> Context.append_error("You aren't holding anything.")
    # else
    #   ast = context.command.ast

    #   matches = Search.generate_matches(held_items, ast.thing.input, ast.thing.which)

    #   case matches do
    #     {:ok, [match]} ->
    #       open_thing(context, match.match)

    #     {:ok, matches} when length(matches) > 1 ->
    #       Util.multiple_error(context)

    #     _ ->
    #       context
    #       |> Context.append_error("Could not find what you were attempting to open.")
    #   end
    # end
    context
  end

  defp open_thing(context, item) do
    item =
      Item.update!(item, %{
        container_open: true
      })

    others =
      Character.list_others_active_in_areas(context.character.id, context.character.area_id)

    other_msg =
      others
      |> Message.new_story_output()
      |> Message.append_text("[#{context.character.name}]", "character")
      |> Message.append_text(" opens ", "base")
      |> Message.append_text(item.short_description, Mud.Engine.Util.get_item_type(item))

    self_msg =
      context.character.id
      |> Message.new_story_output()
      |> Message.append_text("You", "character")
      |> Message.append_text(" open ", "base")
      |> Message.append_text(item.short_description, Mud.Engine.Util.get_item_type(item))

    context
    |> Context.append_message(other_msg)
    |> Context.append_message(self_msg)
    |> Context.append_event(
      context.character_id,
      UpdateInventory.new(:update, item)
    )
  end
end
