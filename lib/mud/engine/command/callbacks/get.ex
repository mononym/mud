defmodule Mud.Engine.Command.Get do
  @moduledoc """
  The GET command allows a character to pick things up, whether from the ground or on/in something.

  Syntax:
    - get <thing> <on|in> <place>

  Examples:
    - get backpack
    - get quiver on shelf
    - get shirt in drawer
  """
  use Mud.Engine.Command.Callback

  alias Mud.Engine.Item
  alias Mud.Engine.Character
  alias Mud.Engine.Command.ExecutionContext
  alias Mud.Engine.Util
  alias Mud.Engine.Search
  alias Mud.Repo
  alias Mud.Engine.Command.AstNode.ThingAndPlace, as: TAP
  alias Mud.Engine.Command.AstNode.{Thing, Place}

  require Logger

  defmodule ContinuationData do
    use TypedStruct

    typedstruct do
      field(:type, atom(), required: true)
      field(:thing, Mud.Engine.Search.Match.t(), required: true)
      field(:place, Mud.Engine.Search.Match.t(), required: true)
    end
  end

  @spec build_ast([Mud.Engine.Command.AstNode.t(), ...]) ::
          Mud.Engine.Command.AstNode.ThingAndPlace.t()
  def build_ast(ast_nodes) do
    Mud.Engine.Command.AstUtil.build_tap_ast(ast_nodes)
  end

  @impl true
  def execute(context) do
    # Make sure command was given with additional input, if not give help docs
    if context.command.ast.thing != nil do
      character = Repo.preload(context.character, :held_items)
      context = %{context | character: character}

      # No reason to go further if hands are full. Check them first.
      if length(character.held_items) == 2 do
        ExecutionContext.append_output(
          context,
          context.character.id,
          "Your hands are full. Empty them first.",
          "error"
        )
        |> ExecutionContext.set_success()
      else
        case context.command.ast do
          # get thing from any container on character
          %TAP{place: nil, thing: %Thing{personal: true}} ->
            get_item_in_worn_container(context)

          # get thing on ground, fallback to worn container
          %TAP{place: nil, thing: %Thing{personal: false}} ->
            get_item_from_ground_or_worn_container(context)

          # get thing from container on ground, fallback to worn containers
          %TAP{place: %Place{personal: false}, thing: %Thing{personal: false}} ->
            get_item_in_area_container_or_worn_container(context)

          # get thing from container on character
          %TAP{place: %Place{personal: place}, thing: %Thing{personal: thing}} when place or thing ->
            get_item_in_worn_container(context)
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

  defp get_item_in_area_container_or_worn_container(context) do
    case get_item_in_area_container(context) do
      {:error, _} ->
        get_item_in_worn_container(context)

      result ->
        result
    end
  end

  defp get_item_from_ground_or_worn_container(context) do
    case get_item_from_ground(context) do
      {:error, _} ->
        get_item_in_worn_container(context)

      result ->
        result
    end
  end

  defp get_item_from_ground(context) do
    ast = context.command.ast
    which_target = ast.thing.which
    input = ast.thing.input

    result =
      Search.find_matches_in_area_v2(
        [:item],
        context.character.area_id,
        input,
        context.character,
        which_target
      )

    Logger.debug(inspect(result))

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
            Character.list_others_active_in_areas(context.character.id, context.character.area_id)

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

      {:ok, _things} ->
        ExecutionContext.append_output(
          context,
          context.character.id,
          "Multiple potential items found, please be more specific.",
          "error"
        )
        |> ExecutionContext.set_success()

      error ->
        error
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

  defp held_containers(items) do
    Enum.filter(items, & &1.is_container)
  end

  defp get_item_in_worn_container(context) do
    worn_containers = Character.list_worn_containers(context.character)
    all_containers = held_containers(context.character.held_items) ++ worn_containers
    ast = context.command.ast

    cond do
      # character is wearing at least one container and the container has been specified
      not is_nil(ast.place) and length(all_containers) > 0 ->
        case Search.generate_matches(
               all_containers,
               ast.place.input,
               context.character,
               ast.place.which
             ) do
          # single worn container matched
          {:ok, [match]} ->
            check_worn_container(context, match.match)

          # multiple worn containers matched
          {:ok, _matches} ->
            ExecutionContext.append_output(
              context,
              context.character.id,
              "Multiple potential containers found, please be more specific.",
              "error"
            )
            |> ExecutionContext.set_success()

          # no worn containers matches
          {:error, :no_match} ->
            ExecutionContext.append_output(
              context,
              context.character.id,
              "Could not find that container.",
              "error"
            )
            |> ExecutionContext.set_success()
        end

      # character is wearing exactly one container and the container has not been specified
      is_nil(ast.place) and length(all_containers) == 1 ->
        check_worn_container(context, List.first(all_containers))

      # character is wearing multiple containers and the container has not been specified
      # just check first one for now, all this logic will need to change at some point
      is_nil(ast.place) and length(all_containers) > 1 ->
        check_worn_container(context, List.first(all_containers))

      # character is not wearing any containers and no container has been specified
      not is_nil(ast.place) and length(all_containers) == 0 ->
        ExecutionContext.append_output(
          context,
          context.character.id,
          "Could not find that item.",
          "error"
        )
        |> ExecutionContext.set_success()

      # character is not wearing any containers and container has been specified
      is_nil(ast.place) and length(all_containers) == 0 ->
        ExecutionContext.append_output(
          context,
          context.character.id,
          "Could not find where you wanted to get the item from.",
          "error"
        )
        |> ExecutionContext.set_success()
    end
  end

  @spec check_worn_container(ExecutionContext.t(), Item.t()) :: ExecutionContext.t()
  defp check_worn_container(context, item) do
    character = context.character

    cond do
      item.container_open or
        (not item.container_open and not item.container_locked and character.auto_open_containers) or
          (item.container_locked and character.auto_unlock_containers) ->
        match = %Search.Match{
          match_string: "",
          match: item,
          glance_description: Item.describe_glance(item, context.character),
          look_description: Item.describe_look(item, context.character)
        }

        find_thing(context, match)

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

    Logger.debug(inspect(ast))

    result =
      Search.find_matches_in_area_v2(
        target_types(),
        character.area_id,
        ast.place.input,
        character,
        0
      )

    # look for container in area
    case result do
      # single match
      {:ok, [place]} ->
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

      {:ok, _matches} ->
        ExecutionContext.append_output(
          context,
          context.character.id,
          "Multiple potential containers found, please be more specific.",
          "error"
        )
        |> ExecutionContext.set_success()

      error ->
        error
    end
  end

  @spec find_thing(ExecutionContext.t(), Search.Match.t()) :: ExecutionContext.t()
  defp find_thing(context, place) do
    ast = context.command.ast

    case find_thing_in_place(place, ast.thing.input, context.character) do
      {:ok, thing} ->
        get_thing_in_place(context, thing, place)

      {:multiple, _matches} ->
        ExecutionContext.append_output(
          context,
          context.character.id,
          "Multiple potential matches found inside {{item}}#{place.glance_description}{{/item}}, please be more specific.",
          "error"
        )
        |> ExecutionContext.set_success()

      {:error, :no_match} ->
        ExecutionContext.append_output(
          context,
          context.character.id,
          "Could not find any matching item to get from {{item}}#{place.glance_description}{{/item}}.",
          "help_docs"
        )
        |> ExecutionContext.set_success()
    end
  end

  @spec find_thing_in_place(Search.Match.t(), String.t(), Character.t()) ::
          {:ok, Search.Match.t()}
          | {:multiple, [Search.Match.t()]}
          | {:error, :no_match | :out_of_range}
  defp find_thing_in_place(place, input, character) do
    place = Repo.preload(place.match, :container_items)
    items = place.container_items

    case Search.generate_matches(items, input, character) do
      {:ok, [result]} ->
        {:ok, result}

      {:ok, multiple} ->
        {:multiple, multiple}

      error ->
        error
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
    others = Character.list_others_active_in_areas(context.character.id, context.character.area_id)

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
    item = thing.match
    container = place.match

    Item.update!(item, %{
      hand: which_hand(character),
      holdable_held_by_id: character.id,
      container_id: nil
    })

    cond do
      container.container_open ->
        {"You get {{item}}#{thing.glance_description}{{/item}} from inside {{item}}#{
           place.glance_description
         }{{/item}}.",
         "{{character}}#{character.name}{{/character}} gets {{item}}#{thing.glance_description}{{/item}} from inside {{item}}#{
           place.glance_description
         }{{/item}}."}

      not container.container_open and not container.container_locked and
          character.auto_open_containers ->
        if character.auto_close_containers do
          {"You open {{item}}#{place.glance_description}{{/item}} just long enough to get {{item}}#{
             thing.glance_description
           }{{/item}} from inside.",
           "{{character}}#{character.name}{{/character}} opens {{item}}#{place.glance_description}{{/item}} just long enough to get {{item}}#{
             thing.glance_description
           }{{/item}} from inside."}
        else
          Item.update!(container, %{
            container_open: true
          })

          {"You open {{item}}#{place.glance_description}{{/item}} and get {{item}}#{
             thing.glance_description
           }{{/item}} from inside.",
           "{{character}}#{character.name}{{/character}} opens {{item}}#{place.glance_description}{{/item}} and gets {{item}}#{
             thing.glance_description
           }{{/item}} from inside."}
        end

      container.container_locked and character.auto_unlock_containers ->
        close = character.auto_close_containers
        lock = character.auto_lock_containers

        cond do
          close and lock ->
            {"You unlock and open {{item}}#{place.glance_description}{{/item}} just long enough to get {{item}}#{
               thing.glance_description
             }{{/item}} from inside it, securing it once more.",
             "{{character}}#{character.name}{{/character}} fiddles with {{item}}#{
               place.glance_description
             }{{/item}} a moment before opening it just long enough to get {{item}}#{
               thing.glance_description
             }{{/item}} from inside, fiddling with it again once it is closed."}

          close ->
            Item.update!(container, %{
              container_locked: false
            })

            {"You unlock and open {{item}}#{place.glance_description}{{/item}} just long enough to get {{item}}#{
               thing.glance_description
             }{{/item}} from inside it.",
             "{{character}}#{character.name}{{/character}} fiddles with {{item}}#{
               place.glance_description
             }{{/item}} a moment before opening it just long enough to get {{item}}#{
               thing.glance_description
             }{{/item}} from inside."}

          true ->
            Item.update!(container, %{
              container_locked: false,
              container_open: true
            })

            {"You unlock and open {{item}}#{place.glance_description}{{/item}}, getting {{item}}#{
               thing.glance_description
             }{{/item}} from inside it.",
             "{{character}}#{character.name}{{/character}} fiddles with {{item}}#{
               place.glance_description
             }{{/item}} a moment before opening it to get {{item}}#{thing.glance_description}{{/item}} from inside."}
        end
    end
  end

  defp target_types(), do: [:item]
end
