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
  alias Mud.Repo
  alias Mud.Engine.Command.SingleTargetCallback

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
  def continue(%ExecutionContext{} = context) do
    {input, continuation_data} = context.input

    integer = String.to_integer(input)
    match = continuation_data[continuation_data.type][integer]

    if context.character.area_id == match.match.area_id do
      case continuation_data.type do
        :thing ->
          remove_thing_from_place(context, match, continuation_data.place)

        :place ->
          find_thing(context, match)
      end
    else
      ExecutionContext.append_output(
        context,
        context.character.id,
        "The #{context.input.glance_description} is no longer present.",
        "error"
      )
      |> ExecutionContext.set_success()
    end
  end

  @impl true
  def execute(context) do
    ast = context.command.ast

    cond do
      # Take something from a container and put it on the ground
      ast[:thing][:from][:place] != nil ->
        remove_item_from_container(context)

      # Remove something that is worn
      ast[:my][:thing] != nil or ast[:thing] != nil ->
        remove_worn_item(context)
    end

    # if is_valid_ast?(ast) do
    #   case find_place_in_area(ast[:thing][:from][:place][:input], context.character) do
    #     {:ok, place} ->
    #       cond do
    #         place.match.is_container and place.match.container_open ->
    #           find_thing(context, place)

    #         place.match.is_container and not place.match.container_open ->
    #           ExecutionContext.append_output(
    #             context,
    #             context.character.id,
    #             "{{item}}#{place.glance_description}{{/item}} must be opened first.",
    #             "error"
    #           )
    #           |> ExecutionContext.set_success()

    #         not place.match.is_container ->
    #           ExecutionContext.append_output(
    #             context,
    #             context.character.id,
    #             "{{item}}#{place.glance_description}{{/item}} is not a container.",
    #             "error"
    #           )
    #           |> ExecutionContext.set_success()
    #       end

    #     {:multiple, matches} ->
    #       indexed_places =
    #         Enum.map(matches, & &1.match)
    #         |> Util.list_to_index_map()

    #       cont_data = %ContinuationData{place: indexed_places, type: :place}

    #       handle_multiple_matches(
    #         context,
    #         matches,
    #         cont_data,
    #         "Which container did you mean?",
    #         "There were too many places to choose from. Please be more specific."
    #       )

    #     {:error, :no_match} ->
    #       ExecutionContext.append_output(
    #         context,
    #         context.character.id,
    #         "Could not find any matching containers to remove anything from.",
    #         "error"
    #       )
    #       |> ExecutionContext.set_success()
    #   end
    # else
    #   help_docs = Util.get_module_docs(__MODULE__)

    #   ExecutionContext.append_output(
    #     context,
    #     context.character.id,
    #     help_docs,
    #     "help_docs"
    #   )
    #   |> ExecutionContext.set_success()
    # end
  end

  defp remove_worn_item(context) do
    ast = context.command.ast
    input = ast[:thing][:input] || ast[:my][:thing][:input]

    character = Repo.preload(context.character, :worn_items)
    worn_items = character.worn_items

    matches = Search.generate_matches(worn_items, input, context.character)

    case matches do
      {:ok, [match]} ->
        remove_single_worn_item(context, match)

      {:ok, matches} when is_list(matches) ->
        SingleTargetCallback.handle_multiple_matches(
          context,
          matches,
          "What would you like to remove?",
          "You can't remove all that!"
        )

      _error ->
        ExecutionContext.append_output(
          context,
          context.character.id,
          String.capitalize("Could find nothing to remove."),
          "warning"
        )
        |> ExecutionContext.set_success()
    end
  end

  defp remove_single_worn_item(context, match) do
    Item.update!(match.match, %{
      area_id: context.character.area_id,
      wearable_worn_by_id: nil,
      wearable_is_worn: false
    })

    others = Character.list_others_active_in_areas(context.character, context.character.area_id)

    context
    |> ExecutionContext.append_output(
      others,
      "{{character}}#{context.character.name}{{/character}} removed {{item}}#{
        match.glance_description
      }{{/item}} from their {{bodypart}}#{match.glance_description}{{/bodypart}} and placed it on the ground.",
      "info"
    )
    |> ExecutionContext.append_output(
      context.character.id,
      String.capitalize("{{item}}#{match.glance_description}{{/item}} is now on the ground."),
      "info"
    )
    |> ExecutionContext.set_success()
  end

  defp remove_item_from_container(context) do
    ast = context.command.ast

    case find_place_in_area(ast[:thing][:from][:place][:input], context.character) do
      {:ok, place} ->
        cond do
          place.match.is_container and place.match.container_open ->
            find_thing(context, place)

          place.match.is_container and not place.match.container_open ->
            ExecutionContext.append_output(
              context,
              context.character.id,
              "{{item}}#{place.glance_description}{{/item}} must be opened first.",
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

        handle_multiple_matches(
          context,
          matches,
          cont_data,
          "Which container did you mean?",
          "There were too many places to choose from. Please be more specific."
        )

      {:error, :no_match} ->
        ExecutionContext.append_output(
          context,
          context.character.id,
          "Could not find any matching containers to remove anything from.",
          "error"
        )
        |> ExecutionContext.set_success()
    end
  end

  defp find_thing(context, place) do
    ast = context.command.ast

    case find_thing_in_place(place, ast[:thing][:input], context.character) do
      {:ok, thing} ->
        remove_thing_from_place(context, thing, place)

      {:multiple, matches} ->
        indexed_things =
          Enum.map(matches, & &1.match)
          |> Util.list_to_index_map()

        cont_data = %ContinuationData{thing: indexed_things, type: :thing, place: place}

        handle_multiple_matches(
          context,
          matches,
          cont_data,
          "What did you want to remove from from #{place.glance_description}?",
          "There were too many things to choose from. Please be more specific."
        )

      {:error, :no_match} ->
        ExecutionContext.append_output(
          context,
          context.character.id,
          "Could not find any matching thing to remove from #{place.glance_description}.",
          "help_docs"
        )
        |> ExecutionContext.set_success()
    end
  end

  @spec handle_multiple_matches(
          Mud.Engine.Command.ExecutionContext.t(),
          [Mud.Engine.Search.Match.t()],
          ContinuationData.t(),
          String.t(),
          String.t()
        ) ::
          Mud.Engine.Command.ExecutionContext.t()
  defp handle_multiple_matches(
         context,
         matches,
         continuation_data,
         multiple_matches_err,
         _too_many_matches_err
       )
       when length(matches) < 10 do
    descriptions = Enum.map(matches, & &1.glance_description)

    Util.multiple_match_error(
      context,
      descriptions,
      continuation_data,
      multiple_matches_err,
      context.command.callback_module
    )
  end

  defp handle_multiple_matches(
         context,
         _matches,
         _continuation_data,
         _multiple_matches_err,
         too_many_matches_err
       ) do
    ExecutionContext.append_output(
      context,
      context.character.id,
      too_many_matches_err,
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

  @spec remove_thing_from_place(
          Mud.Engine.Command.ExecutionContext.t(),
          Mud.Engine.Search.Match.t(),
          Mud.Engine.Search.Match.t()
        ) :: Mud.Engine.Command.ExecutionContext.t()
  defp remove_thing_from_place(context, thing, place) do
    item = place.match

    if item.is_container and item.container_is_open do
      Item.update!(thing.match, %{area_id: context.character.area_id, container_id: nil})

      others = Character.list_others_active_in_areas(context.character, context.character.area_id)

      context
      |> ExecutionContext.append_output(
        others,
        "{{character}}#{context.character.name}{{/character}} just removed {{item}}#{
          thing.glance_description
        }{{/item}} from {{item}}#{place.glance_description}{{/item}} and placed it on the ground.",
        "info"
      )
      |> ExecutionContext.append_output(
        context.character.id,
        "{{item}}#{thing.glance_description}{{/item}} has been removed from inside {{item}}#{
          place.glance_description
        }{{/item}}.",
        "info"
      )
      |> ExecutionContext.set_success()
    else
      ExecutionContext.append_output(
        context,
        context.character.id,
        "{{item}}#{place.glance_description}{{/item}} must be opened first.",
        "error"
      )
      |> ExecutionContext.set_success()
    end
  end

  defp target_types(), do: [:item]
end
