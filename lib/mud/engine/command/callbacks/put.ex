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

  alias Mud.Engine.Command.AstNode
  alias Mud.Engine.Item
  alias Mud.Engine.Character
  alias Mud.Engine.Command.ExecutionContext
  alias Mud.Engine.Util
  alias Mud.Engine.Search
  alias Mud.Repo

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
  #     "{{item}}#{String.capitalize(context.input.glance_description)}{{/item}} is no longer present.",
  #     "error"
  #   )
  #   |> ExecutionContext.set_success()
  # end
  # end

  @impl true
  def execute(context) do
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
      context
      # process_ast(context.command.ast)
      # put = %PutNode{thing, place, path}
      # thing = %ThingNode{which, thing}
      # place = %PlaceNode{where, which, personal, place}
      # path = %PathNode{where, which, personal, place}

    #   cond do
    #     # Take something from a container on the ground
    #     ast[:which_thing][:thing][:in][:which_place][:place] != nil or
    #       ast[:which_thing][:thing][:in][:place] or ast[:thing][:in][:which_place][:place] or
    #         ast[:thing][:in][:place] ->
    #       get_item_in_area_container(context)

    #     # Take something from a worn container
    #     ast[:thing][:in][:my][:place] != nil ->
    #       get_item_in_worn_container(context)

    #     # Assume the item is on the ground
    #     true ->
    #       get_item_from_ground(context)
    #   end
    end
  end

  defp build_ast(ast_node = %AstNode{key: :put}) do
    #create new %PutNode{thing, place, path}
    # build thing and pass ast
    # thing returns thing and rest of ast
    # build place and pass ast
    # place returns place and rest of ast
    # build path and pass ast
    # path returns path and rest of ast
    # ast should be empty and new Put ast should be created and returned
  end

  defp build_thing(ast_node = %AstNode{key: :put}) do
    # maybe grab which thing
    # definitely grab thing
  end

  defp get_item_from_ground(context) do
    ast = context.command.ast
    which_target = min(0, ast[:number][:input] || 0)
    input = ast[:number][:thing][:input] || ast[:thing][:input]

    result =
      Search.find_matches_in_area_v2(
        [:item],
        context.character.area_id,
        input,
        context.character,
        which_target
      )

    case result do
      {:ok, [thing]} ->
        if thing.match.is_holdable do
          hand = which_hand(context.character)

          Item.update!(thing.match, %{
            area_id: nil,
            holdable_held_by_id: context.character.id,
            holdable_is_held: true,
            holdable_hand: hand
          })

          others =
            Character.list_others_active_in_areas(context.character, context.character.area_id)

          context
          |> ExecutionContext.append_output(
            others,
            "{{character}}#{context.character.name}{{/character}} picked up {{item}}#{
              thing.glance_description
            }{{/item}} from the ground.",
            "info"
          )
          |> ExecutionContext.append_output(
            context.character.id,
            "You pick up {{item}}#{thing.glance_description}{{/item}}.",
            "info"
          )
          |> ExecutionContext.set_success()
        else
          ExecutionContext.append_output(
            context,
            context.character.id,
            "You cannot pick up {{item}}#{thing.glance_description}{{/item}}.",
            "error"
          )
          |> ExecutionContext.set_success()
        end

      {:ok, things} ->
        indexed_things =
          Enum.map(things, & &1.match)
          |> Util.list_to_index_map()

        cont_data = %ContinuationData{thing: indexed_things, type: :thing}

        handle_multiple_items(
          context,
          things,
          cont_data,
          "Which thing did you mean?",
          "There were too many things to choose from. Please be more specific."
        )

      {:error, _} ->
        ExecutionContext.append_output(
          context,
          context.character.id,
          "Could not find what you were looking for.",
          "error"
        )
        |> ExecutionContext.set_success()
    end
  end

  defp which_hand(character) do
    held_items =
      if Ecto.assoc_loaded?(character.held_items) do
        character.held_items
      else
        character = Repo.preload(character, :held_items)
        character.held_items
      end

    case held_items do
      [item] ->
        if item.holdable_hand == "left" do
          "right"
        else
          "left"
        end

      _items ->
        character.handedness
    end
  end

  defp get_item_in_worn_container(context) do
    character = Repo.preload(context.character, :worn_items)

    worn_containers = Enum.filter(character.worn_items, & &1.is_container)

    case worn_containers do
      [container] ->
        check_worn_container(context, container)

      [] ->
        ExecutionContext.append_output(
          context,
          context.character.id,
          "Could not find where you wanted to get the item from.",
          "error"
        )
        |> ExecutionContext.set_success()

      multiple_items ->
        indexed_places =
          Enum.map(multiple_items, & &1.match)
          |> Util.list_to_index_map()

        cont_data = %ContinuationData{place: indexed_places, type: :place}

        handle_multiple_items(
          context,
          multiple_items,
          cont_data,
          "Which container did you mean?",
          "There were too many places to choose from. Please be more specific."
        )
    end
  end

  defp check_worn_container(context, item) do
    character = context.character

    cond do
      item.container_open or
        (not item.container_open and not item.container_locked and character.auto_open_containers) or
          (item.container_locked and character.auto_unlock_containers) ->
        find_thing(context, item)

      item.container_locked and not character.auto_unlock_containers and
          not character.auto_open_containers ->
        ExecutionContext.append_output(
          context,
          context.character.id,
          "{{item}}#{String.capitalize(Item.describe_glance(item, context.character))}{{/item}} must be unlocked and open first.",
          "error"
        )
        |> ExecutionContext.set_success()

      item.container_locked and not character.auto_unlock_containers ->
        ExecutionContext.append_output(
          context,
          context.character.id,
          "{{item}}#{String.capitalize(Item.describe_glance(item, context.character))}{{/item}} must be unlocked first.",
          "error"
        )
        |> ExecutionContext.set_success()

      not item.container_open and not character.auto_open_containers ->
        ExecutionContext.append_output(
          context,
          context.character.id,
          "{{item}}#{String.capitalize(Item.describe_glance(item, context.character))}{{/item}} must be open first.",
          "error"
        )
        |> ExecutionContext.set_success()
    end
  end

  defp get_item_in_area_container(context) do
    character = context.character
    ast = context.command.ast

    # look for container in area
    case find_place_in_area(ast[:thing][:from][:place][:input], context.character) do
      # single match
      {:ok, place} ->
        item = place.match

        cond do
          (item.is_container and item.container_open) or
            (item.is_container and character.auto_unlock_containers) or
              (item.is_container and not item.container_locked and character.auto_open_containers) ->
            find_thing(context, place)

          (item.is_container and item.container_locked and not character.auto_unlock_containers) or
              (item.is_container and not item.container_open and
                 not character.auto_open_containers) ->
            ExecutionContext.append_output(
              context,
              context.character.id,
              "{{item}}#{place.glance_description}{{/item}} must be open first.",
              "error"
            )
            |> ExecutionContext.set_success()

          not place.match.is_container ->
            ExecutionContext.append_output(
              context,
              context.character.id,
              "{{item}}#{place.glance_description}{{/item}} is not a container.",
              "error"
            )
            |> ExecutionContext.set_success()
        end

      {:multiple, matches} ->
        indexed_places =
          Enum.map(matches, & &1.match)
          |> Util.list_to_index_map()

        cont_data = %ContinuationData{place: indexed_places, type: :place}

        handle_multiple_items(
          context,
          matches,
          cont_data,
          "Which container did you mean?",
          "There were too many places to choose from. Please be more specific."
        )

      {:error, :no_match} ->
        get_item_in_worn_container(context)
    end
  end

  defp find_thing(context, place) do
    ast = context.command.ast

    case find_thing_in_place(place, ast[:thing][:input], context.character) do
      {:ok, thing} ->
        get_thing_in_place(context, thing, place)

      {:multiple, matches} ->
        indexed_things =
          Enum.map(matches, & &1.match)
          |> Util.list_to_index_map()

        cont_data = %ContinuationData{thing: indexed_things, type: :thing, place: place}

        handle_multiple_items(
          context,
          matches,
          cont_data,
          "What did you want to get from from {{item}}#{place.glance_description}{{/item}}?",
          "There were too many things to choose from. Please be more specific."
        )

      {:error, :no_match} ->
        ExecutionContext.append_output(
          context,
          context.character.id,
          "Could not find any matching thing to get from {{item}}#{place.glance_description}{{/item}}.",
          "help_docs"
        )
        |> ExecutionContext.set_success()
    end
  end

  @spec handle_multiple_items(
          Mud.Engine.Command.ExecutionContext.t(),
          [Mud.Engine.Search.Match.t()],
          ContinuationData.t(),
          String.t(),
          String.t()
        ) ::
          Mud.Engine.Command.ExecutionContext.t()
  defp handle_multiple_items(
         context,
         items,
         continuation_data,
         multiple_items_err,
         _too_many_items_err
       )
       when length(items) < 10 do
    descriptions = Enum.map(items, fn item -> Item.describe_glance(item, context.character) end)

    Util.multiple_match_error(
      context,
      descriptions,
      continuation_data,
      multiple_items_err,
      context.command.callback_module
    )
  end

  defp handle_multiple_items(
         context,
         _items,
         _continuation_data,
         _multiple_items_err,
         too_many_items_err
       ) do
    ExecutionContext.append_output(
      context,
      context.character.id,
      too_many_items_err,
      "error"
    )
    |> ExecutionContext.set_success()
  end

  defp find_place_in_area(input, character) do
    {:ok, results} =
      Search.find_matches_in_area_v2(
        target_types(),
        character.area_id,
        input,
        character,
        0
      )

    num_results = length(results)

    cond do
      num_results == 1 ->
        {:ok, List.first(results)}

      num_results == 0 ->
        {:error, :no_match}

      true ->
        {:multiple, results}
    end
  end

  defp find_thing_in_place(place, input, character) do
    place = Repo.preload(place.match, :container_items)
    items = place.container_items

    {:ok, thing_search_results} = Search.generate_matches(items, input, character)

    num_results = length(thing_search_results)

    cond do
      num_results == 1 ->
        {:ok, List.first(thing_search_results)}

      num_results == 0 ->
        {:error, :no_match}

      true ->
        {:multiple, thing_search_results}
    end
  end

  @spec get_thing_in_place(
          Mud.Engine.Command.ExecutionContext.t(),
          Mud.Engine.Search.Match.t(),
          Mud.Engine.Search.Match.t()
        ) :: Mud.Engine.Command.ExecutionContext.t()
  defp get_thing_in_place(context, thing, place) do
    character = context.character

    {self_msg, others_msg} = do_get_thing_in_place(thing, place, character)
    others = Character.list_others_active_in_areas(context.character, context.character.area_id)

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

  defp do_get_thing_in_place(thing, place, character) do
    item = place.match

    cond do
      item.container_open ->
        Item.update!(item, %{
          hand: which_hand(character),
          holdable_held_by_id: character.id,
          container_id: nil
        })

        {"You get {{item}}#{thing.glance_description}{{/item}} from inside {{item}}#{
           place.glance_description
         }{{/item}}.",
         "{{character}}#{character.name}{{/character}} gets {{item}}#{thing.glance_description}{{/item}} from inside {{item}}#{
           place.glance_description
         }{{/item}}."}

      not item.container_open and not item.container_locked and character.auto_open_containers ->
        Item.update!(item, %{
          hand: which_hand(character),
          holdable_held_by_id: character.id,
          container_id: nil
        })

        {"You open {{item}}#{place.glance_description}{{/item}} just long enough to get {{item}}#{
           place.glance_description
         }{{/item}} from inside.",
         "{{character}}#{character.name}{{/character}} opens {{item}}#{place.glance_description}{{/item}} just long enough to get {{item}}#{
           place.glance_description
         }{{/item}} from inside."}

      item.container_locked and character.auto_unlock_containers ->
        Item.update!(item, %{
          hand: which_hand(character),
          holdable_held_by_id: character.id,
          container_id: nil
        })

        {"You unlock and open {{item}}#{place.glance_description}{{/item}} just long enough to get {{item}}#{
           place.glance_description
         }{{/item}} from inside it, locking it once more.",
         "{{character}}#{character.name}{{/character}} fiddles with {{item}}#{
           place.glance_description
         }{{/item}} a moment before opening it just long enough to get {{item}}#{
           place.glance_description
         }{{/item}} from inside, fiddling with it once more as it is closed."}
    end
  end

  defp target_types(), do: [:item]
end
