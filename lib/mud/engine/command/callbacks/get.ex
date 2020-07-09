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

  alias Mud.Engine.Event.Client.{UpdateArea, UpdateInventory}
  alias Mud.Engine.Item
  alias Mud.Engine.Character
  alias Mud.Engine.Command.Context
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
    Logger.debug(inspect(context))
    # Make sure command was given with additional input, if not give help docs
    if context.command.ast.thing != nil do
      character = Repo.preload(context.character, :held_items)
      context = %{context | character: character}

      # No reason to go further if hands are full. Check them first.
      if length(character.held_items) == 2 do
        context
        |> Context.append_error("Your hands are full. Empty them first.")
      else
        case context.command.ast do
          # get thing from any container on character
          %TAP{place: nil, thing: %Thing{personal: true}} ->
            get_item_in_worn_container(context)

          # get thing on ground, fallback to worn container
          %TAP{place: nil, thing: %Thing{personal: false}} ->
            if Util.is_uuid4(context.command.ast.thing.input) do
              get_item_by_uuid(context)
            else
              get_item_from_ground_or_worn_container(context)
            end

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
      Context.append_output(
        context,
        context.character.id,
        Util.get_module_docs(__MODULE__),
        "docs"
      )
    end
  end

  # primarily triggered by actions on the client
  defp get_item_by_uuid(context) do
    ast = context.command.ast
    item = Item.get!(ast.thing.input)

    # if the item selected is in the area/on the ground
    if not is_nil(item.area_id) do
      # make sure it's in the same area as the character
      if item.area_id == context.character.area_id do
        [match] = Search.things_to_match([item])

        do_get_item_from_ground(context, match)
      else
        Util.dave_error(context)
      end
    else
      # the item is assumed to be inside a container
      items = Item.list_all_recursive_parents(ast.thing.input)
      char = context.character

      # is item inside containers either on character or in character's area or in character's hand
      parent =
        Enum.find(items, fn item ->
          item.wearable_worn_by_id == char.id or item.area_id == char.area_id or
            item.holdable_held_by_id == char.id
        end)

      if parent do
        [thing, place] = Search.things_to_match([item, parent])

        private = is_nil(parent.area_id)
        get_thing_in_place(context, thing, place, private)
      else
        Util.dave_error(context)
      end
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
        which_target
      )

    case result do
      {:ok, [thing]} ->
        do_get_item_from_ground(context, thing)

      {:ok, _things} ->
        context
        |> Context.append_error("Multiple potential items found, please be more specific.")

      error ->
        error
    end
  end

  defp do_get_item_from_ground(context, thing) do
    if thing.match.is_holdable do
      hand = which_hand(context.character)

      item =
        Item.update!(thing.match, %{
          area_id: nil,
          holdable_held_by_id: context.character.id,
          holdable_is_held: true,
          holdable_hand: hand
        })

      others =
        Character.list_others_active_in_areas(context.character.id, context.character.area_id)

      all_items = Item.list_all_recursive(item)

      context
      |> Context.append_output(
        others,
        "{{character}}#{context.character.name}{{/character}} picked up {{item}}#{
          thing.short_description
        }{{/item}} from the ground.",
        "info"
      )
      |> Context.append_output(
        context.character.id,
        "You pick up {{item}}#{thing.short_description}{{/item}}.",
        "info"
      )
      |> Context.append_event(
        context.character_id,
        UpdateInventory.new(:add, all_items)
      )
      |> Context.append_event(
        [context.character_id | others],
        UpdateArea.new(:remove, all_items)
      )
    else
      context
      |> Context.append_error("You cannot pick up {{item}}#{thing.short_description}{{/item}}.")
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
               ast.place.which
             ) do
          # single worn container matched
          {:ok, [match]} ->
            check_worn_container(context, match.match)

          # multiple worn containers matched
          {:ok, _matches} ->
            context
            |> Context.append_error(
              "Multiple potential containers found, please be more specific."
            )

          # no worn containers matches
          {:error, :no_match} ->
            context
            |> Context.append_error("Could not find that container.")
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
        context
        |> Context.append_error("Could not find that item.")

      # character is not wearing any containers and container has been specified
      is_nil(ast.place) and length(all_containers) == 0 ->
        context
        |> Context.append_error("Could not find where you wanted to get the item from.")
    end
  end

  @spec check_worn_container(Context.t(), Item.t()) :: Context.t()
  defp check_worn_container(context, item) do
    character = context.character

    cond do
      item.container_open or
        (not item.container_open and not item.container_locked and character.auto_open_containers) or
          (item.container_locked and character.auto_unlock_containers) ->
        match = %Search.Match{
          match_string: "",
          match: item,
          short_description: item.short_description,
          long_description: item.long_description
        }

        find_thing(context, match, true)

      item.container_locked and not character.auto_unlock_containers and
          not character.auto_open_containers ->
        context
        |> Context.append_error(
          "{{item}}#{String.capitalize(item.short_description)}{{/item}} must be unlocked and open first."
        )

      item.container_locked and not character.auto_unlock_containers ->
        context
        |> Context.append_error(
          "{{item}}#{String.capitalize(item.short_description)}{{/item}} must be unlocked first."
        )

      not item.container_open and not character.auto_open_containers ->
        context
        |> Context.append_error(
          "{{item}}#{String.capitalize(item.short_description)}{{/item}} must be open first."
        )
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
            find_thing(context, place, false)

          (item.is_container and item.container_locked and not character.auto_unlock_containers) or
              (item.is_container and not item.container_open and
                 not character.auto_open_containers) ->
            Context.append_output(
              context,
              context.character.id,
              "{{item}}#{place.short_description}{{/item}} must be open first.",
              "error"
            )

          not place.match.is_container ->
            Context.append_output(
              context,
              context.character.id,
              "{{item}}#{place.short_description}{{/item}} is not a container.",
              "error"
            )
        end

      {:ok, _matches} ->
        Context.append_output(
          context,
          context.character.id,
          "Multiple potential containers found, please be more specific.",
          "error"
        )

      error ->
        error
    end
  end

  @spec find_thing(Context.t(), Search.Match.t(), boolean()) :: Context.t()
  defp find_thing(context, place, private) do
    ast = context.command.ast

    case find_thing_in_place(place, ast.thing.input) do
      {:ok, thing} ->
        get_thing_in_place(context, thing, place, private)

      {:multiple, _matches} ->
        Context.append_output(
          context,
          context.character.id,
          "Multiple potential matches found inside {{item}}#{place.short_description}{{/item}}, please be more specific.",
          "error"
        )

      {:error, :no_match} ->
        Context.append_output(
          context,
          context.character.id,
          "Could not find any matching item to get from {{item}}#{place.short_description}{{/item}}.",
          "help_docs"
        )
    end
  end

  @spec find_thing_in_place(Search.Match.t(), String.t()) ::
          {:ok, Search.Match.t()}
          | {:multiple, [Search.Match.t()]}
          | {:error, :no_match | :out_of_range}
  defp find_thing_in_place(place, input) do
    place = Repo.preload(place.match, :container_items)
    items = place.container_items

    case Search.generate_matches(items, input) do
      {:ok, [result]} ->
        {:ok, result}

      {:ok, multiple} ->
        {:multiple, multiple}

      error ->
        error
    end
  end

  @spec get_thing_in_place(
          Mud.Engine.Command.Context.t(),
          Mud.Engine.Search.Match.t(),
          Mud.Engine.Search.Match.t(),
          boolean()
        ) :: Mud.Engine.Command.Context.t()
  defp get_thing_in_place(context, thing, place, private) do
    character = context.character

    {self_msg, others_msg, items} = do_get_thing_in_place(thing, place, character)

    others =
      Character.list_others_active_in_areas(context.character.id, context.character.area_id)

    all_items = Item.list_all_recursive(items)

    context =
      if private do
        Context.append_event(
          context,
          context.character_id,
          UpdateInventory.new(:update, [thing.match | all_items])
        )
      else
        context
        |> Context.append_event(
          context.character_id,
          UpdateInventory.new(:add, [thing.match | all_items])
        )
        |> Context.append_event(
          [context.character_id | others],
          UpdateArea.new(:remove, [thing.match | all_items])
        )
      end

    context
    |> Context.append_output(
      others,
      others_msg,
      "info"
    )
    |> Context.append_output(
      context.character.id,
      self_msg,
      "info"
    )
  end

  defp do_get_thing_in_place(thing, place, character) do
    item = thing.match
    container = place.match

    item =
      Item.update!(item, %{
        hand: which_hand(character),
        holdable_is_held: true,
        holdable_held_by_id: character.id,
        container_id: nil
      })

    cond do
      container.container_open ->
        {"You get {{item}}#{thing.short_description}{{/item}} from inside {{item}}#{
           place.short_description
         }{{/item}}.",
         "{{character}}#{character.name}{{/character}} gets {{item}}#{thing.short_description}{{/item}} from inside {{item}}#{
           place.short_description
         }{{/item}}.", [item]}

      not container.container_open and not container.container_locked and
          character.auto_open_containers ->
        if character.auto_close_containers do
          {"You open {{item}}#{place.short_description}{{/item}} just long enough to get {{item}}#{
             thing.short_description
           }{{/item}} from inside.",
           "{{character}}#{character.name}{{/character}} opens {{item}}#{place.short_description}{{/item}} just long enough to get {{item}}#{
             thing.short_description
           }{{/item}} from inside.", [item]}
        else
          container =
            Item.update!(container, %{
              container_open: true
            })

          {"You open {{item}}#{place.short_description}{{/item}} and get {{item}}#{
             thing.short_description
           }{{/item}} from inside.",
           "{{character}}#{character.name}{{/character}} opens {{item}}#{place.short_description}{{/item}} and gets {{item}}#{
             thing.short_description
           }{{/item}} from inside.", [item, container]}
        end

      container.container_locked and character.auto_unlock_containers ->
        close = character.auto_close_containers
        lock = character.auto_lock_containers

        cond do
          close and lock ->
            {"You unlock and open {{item}}#{place.short_description}{{/item}} just long enough to get {{item}}#{
               thing.short_description
             }{{/item}} from inside it, securing it once more.",
             "{{character}}#{character.name}{{/character}} fiddles with {{item}}#{
               place.short_description
             }{{/item}} a moment before opening it just long enough to get {{item}}#{
               thing.short_description
             }{{/item}} from inside, fiddling with it again once it is closed."}

          close ->
            container =
              Item.update!(container, %{
                container_locked: false
              })

            {"You unlock and open {{item}}#{place.short_description}{{/item}} just long enough to get {{item}}#{
               thing.short_description
             }{{/item}} from inside it.",
             "{{character}}#{character.name}{{/character}} fiddles with {{item}}#{
               place.short_description
             }{{/item}} a moment before opening it just long enough to get {{item}}#{
               thing.short_description
             }{{/item}} from inside.", [item, container]}

          true ->
            container =
              Item.update!(container, %{
                container_locked: false,
                container_open: true
              })

            {"You unlock and open {{item}}#{place.short_description}{{/item}}, getting {{item}}#{
               thing.short_description
             }{{/item}} from inside it.",
             "{{character}}#{character.name}{{/character}} fiddles with {{item}}#{
               place.short_description
             }{{/item}} a moment before opening it to get {{item}}#{thing.short_description}{{/item}} from inside.",
             [item, container]}
        end
    end
  end

  defp target_types(), do: [:item]
end
