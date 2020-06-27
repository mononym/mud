defmodule Mud.Engine.Command.Put do
  @moduledoc """
  The PUT command allows a character to put something in their hand somewhere such as the ground or a container.

  Syntax:
    - put <which> <thing> down
    - put <which> <thing> <on|in> <my> <which> <place>

  Examples:
    - put backpack down (same as drop)
    - put quiver on shelf
    - put 2 shirt in 3 drawer
    - put 2 diamond in my 5 gem pouch
  """
  use Mud.Engine.Command.Callback

  alias Mud.Engine.Event.Client.{UpdateArea, UpdateInventory}
  alias Mud.Engine.Item
  alias Mud.Engine.Character
  alias Mud.Engine.Command.ExecutionContext
  alias Mud.Engine.Util
  alias Mud.Engine.Search
  alias Mud.Repo
  alias Mud.Engine.Command.AstNode.ThingAndPlace, as: TAP
  alias Mud.Engine.Command.AstNode.Place

  require Logger

  defmodule ContinuationData do
    use TypedStruct

    typedstruct do
      field(:type, atom(), required: true)
      field(:thing, Mud.Engine.Search.Match.t(), required: true)
      field(:place, Mud.Engine.Search.Match.t(), required: true)
    end
  end

  # @impl true
  # def continue(%ExecutionContext{} = context) do
  # {input, continuation_data} = context.input

  # integer = String.to_integer(input)
  # match = continuation_data[continuation_data.type][integer]

  # if context.character.area_id == match.match.area_id do
  #   case continuation_data.type do
  #     :thing ->
  #       get_thing_in_place(context, match, continuation_data.place)

  #     :place ->
  #       find_thing(context, match)
  #   end
  # else
  #   ExecutionContext.append_output(
  #     context,
  #     context.character.id,
  #     "{{item}}#{String.capitalize(context.input.short_description)}{{/item}} is no longer present.",
  #     "error"
  #   )
  #   |> ExecutionContext.set_success()
  # end
  # end

  @spec build_ast([Mud.Engine.Command.AstNode.t(), ...]) ::
          Mud.Engine.Command.AstNode.ThingAndPlace.t()
  def build_ast(ast_nodes) do
    Mud.Engine.Command.AstUtil.build_tap_ast(ast_nodes)
  end

  @impl true
  def execute(context) do
    ast = context.command.ast

    # Make sure command was given with additional input, if not give help docs
    if not is_nil(ast.thing) and not is_nil(ast.place) do
      # No reason to go further if hands are empty. Check them first.
      character = Repo.preload(context.character, :held_items)
      Logger.debug(inspect(character.held_items))

      context = %{context | character: character}

      if length(character.held_items) == 0 do
        ExecutionContext.append_output(
          context,
          context.character.id,
          "Your hands are empty.",
          "error"
        )
        |> ExecutionContext.set_success()
      else
        case Search.generate_matches(
               character.held_items,
               ast.thing.input,
               ast.thing.which
             ) do
          # single worn container matched
          {:ok, [match]} ->
            put_item_away(context, match)

          # multiple held items matched
          {:ok, matches} ->
            indexed_things =
              Enum.map(matches, & &1.match)
              |> Util.list_to_index_map()

            cont_data = %ContinuationData{thing: indexed_things, type: :thing}

            descriptions = Enum.map(matches, & &1.short_description)

            Util.handle_multiple_items(
              context,
              descriptions,
              cont_data,
              "Which item were you referring to?",
              "There were too many items to choose from. Please be more specific."
            )

          # no held items match
          {:error, :no_match} ->
            ExecutionContext.append_output(
              context,
              context.character.id,
              "You are not holding any such item.",
              "error"
            )
            |> ExecutionContext.set_success()
        end
      end
    else
      # get help docs if get command was entered without additional input
      ExecutionContext.append_output(
        context,
        context.character.id,
        Util.get_module_docs(__MODULE__),
        "docs"
      )
      |> ExecutionContext.set_success()
    end
  end

  defp put_item_away(context, item_match) do
    ast = context.command.ast

    case ast do
      %TAP{place: %Place{personal: false}} ->
        case put_item_in_area_container(context, item_match) do
          {:error, _} ->
            put_item_in_held_or_worn_container(context, item_match)

          result ->
            result
        end

      %TAP{place: %Place{personal: true}} ->
        put_item_in_held_or_worn_container(context, item_match)
    end
  end

  defp held_containers(items) do
    Enum.filter(items, & &1.is_container)
  end

  defp put_item_in_held_or_worn_container(context, item_match) do
    ast = context.command.ast
    worn_containers = Character.list_worn_containers(context.character)
    all_containers = held_containers(context.character.held_items) ++ worn_containers

    case Search.generate_matches(all_containers, ast.place.input) do
      {:ok, [match]} ->
        put_item_in_container(context, item_match, match, true)

      {:ok, matches} ->
        indexed_places =
          Enum.map(matches, & &1.match)
          |> Util.list_to_index_map()

        cont_data = %ContinuationData{place: indexed_places, type: :place}

        descriptions = Enum.map(matches, & &1.short_description)

        Util.handle_multiple_items(
          context,
          descriptions,
          cont_data,
          "Which container did you mean?",
          "There were too many containers to choose from. Please be more specific."
        )

      _error ->
        ExecutionContext.append_output(
          context,
          context.character.id,
          "Could not find where you wished to put {{item}}#{item_match.short_description}{{/item}}.",
          "error"
        )
        |> ExecutionContext.set_success()
    end
  end

  defp put_item_in_area_container(context, item_match) do
    ast = context.command.ast

    results =
      Search.find_matches_in_area_v2(
        target_types(),
        context.character.area_id,
        ast.place.input,
        0
      )

    case results do
      # single match
      {:ok, [container]} ->
        put_item_in_container(context, item_match, container, false)

      {:ok, matches} ->
        indexed_places = Util.list_to_index_map(matches)

        cont_data = %ContinuationData{place: indexed_places, type: :place}

        descriptions = Enum.map(matches, & &1.short_description)

        Util.handle_multiple_items(
          context,
          descriptions,
          cont_data,
          "Which container did you mean?",
          "There were too many containers to choose from. Please be more specific."
        )

      error ->
        error
    end
  end

  defp put_item_in_container(context, item, container, private) do
    character = context.character

    {self_msg, others_msg} = do_put_item_in_container(item, container, character)

    others =
      Character.list_others_active_in_areas(context.character.id, context.character.area_id)

    context =
      if private do
        ExecutionContext.append_event(
          context,
          context.character_id,
          UpdateInventory.new(:update, item.match)
        )
      else
        context
        |> ExecutionContext.append_event(
          context.character_id,
          UpdateInventory.new(:remove, item.match)
        )
        |> ExecutionContext.append_event(
          [context.character_id | others],
          UpdateArea.new(:add, item.match)
        )
      end

    context
    |> ExecutionContext.append_output(
      others,
      others_msg,
      "info"
    )
    |> ExecutionContext.append_output(
      context.character.id,
      self_msg,
      "info"
    )
    |> ExecutionContext.set_success()
  end

  defp do_put_item_in_container(item_match, container_match, character) do
    container = container_match.match
    item = item_match.match

    Item.update!(item, %{
      hand: nil,
      holdable_held_by_id: nil,
      container_id: container.id
    })

    cond do
      container.container_open ->
        {"You put {{item}}#{item_match.short_description}{{/item}} inside {{item}}#{
           container_match.short_description
         }{{/item}}.",
         "{{character}}#{character.name}{{/character}} puts {{item}}#{
           item_match.short_description
         }{{/item}} inside {{item}}#{container_match.short_description}{{/item}}."}

      not container.container_open and not container.container_locked and
          character.auto_open_containers ->
        if character.auto_close_containers do
          {"You open {{item}}#{container_match.short_description}{{/item}} just long enough to put {{item}}#{
             item_match.short_description
           }{{/item}} inside.",
           "{{character}}#{character.name}{{/character}} opens {{item}}#{
             container_match.short_description
           }{{/item}} just long enough to put {{item}}#{item_match.short_description}{{/item}} inside."}
        else
          Item.update!(container, %{
            container_open: true
          })

          {"You open {{item}}#{container_match.short_description}{{/item}} and put {{item}}#{
             item_match.short_description
           }{{/item}} inside.",
           "{{character}}#{character.name}{{/character}} opens {{item}}#{
             container_match.short_description
           }{{/item}} and puts {{item}}#{item_match.short_description}{{/item}} inside."}
        end

      container.container_locked and character.auto_unlock_containers ->
        close = character.auto_close_containers
        lock = character.auto_lock_containers

        cond do
          close and lock ->
            {"You unlock and open {{item}}#{container_match.short_description}{{/item}} just long enough to put {{item}}#{
               item_match.short_description
             }{{/item}} inside, securing it once more.",
             "{{character}}#{character.name}{{/character}} fiddles with {{item}}#{
               container_match.short_description
             }{{/item}} a moment before opening it just long enough to put {{item}}#{
               item_match.short_description
             }{{/item}} inside, fiddling with it again once it is closed."}

          close ->
            Item.update!(container, %{
              container_locked: false
            })

            {"You unlock and open {{item}}#{container_match.short_description}{{/item}} just long enough to put {{item}}#{
               item_match.short_description
             }{{/item}} inside it.",
             "{{character}}#{character.name}{{/character}} fiddles with {{item}}#{
               container_match.short_description
             }{{/item}} a moment before opening it just long enough to put {{item}}#{
               item_match.short_description
             }{{/item}} inside."}

          true ->
            Item.update!(container, %{
              container_locked: false,
              container_open: true
            })

            {"You unlock and open {{item}}#{container_match.short_description}{{/item}}, putting {{item}}#{
               item_match.short_description
             }{{/item}} inside it.",
             "{{character}}#{character.name}{{/character}} fiddles with {{item}}#{
               container_match.short_description
             }{{/item}} a moment before opening it to put {{item}}#{item_match.short_description}{{/item}} inside."}
        end
    end
  end

  defp target_types do
    [:item]
  end
end
