defmodule Mud.Engine.Command.Store do
  @moduledoc """
  The STORE command allows a character to 'store' things in a container.

  Syntax:
    - store <thing> in <place>

  Examples:
    - store gem in gembag
  """
  use Mud.Engine.Command.Callback

  alias Mud.Engine.Command.ExecutionContext
  alias Mud.Engine.Search
  alias Mud.Engine.Model.Character
  alias Mud.Engine.Model.Item
  alias Mud.Engine.Util

  require Logger

  defmodule ContinuationData do
    defstruct type: nil,
              thing: nil,
              place: nil
  end

  @impl true
  def execute(%ExecutionContext{} = context) do
    ast = context.command.ast

    thing_search_results =
      Search.find_matches_in_area_v2(
        [:item],
        context.character.area_id,
        ast[:thing][:input],
        context.character,
        0
      )

    place_search_results =
      Search.find_matches_in_area_v2(
        [:item],
        context.character.area_id,
        ast[:thing][:path][:place][:input],
        context.character,
        0
      )

    with {:ok, thing_matches} <- thing_search_results,
         {:ok, place_matches} <- place_search_results,
         num_things <- length(thing_matches),
         num_places <- length(place_matches) do
      cond do
        num_things == 1 and num_places == 1 ->
          thing = List.first(thing_matches).match
          place = List.first(place_matches).match

          cond do
            place.is_container and place.container_open ->
              msg =
                if place.container_locked do
                  " is closed and locked"
                else
                  " is closed"
                end

              ExecutionContext.append_output(
                context,
                context.character.id,
                "{{item}}#{place.glance_description}{{/item}} #{msg}.",
                "info"
              )
              |> ExecutionContext.set_success()

            place.is_container ->
              Item.update!(thing, %{area_id: nil, container_id: place.id})

              others =
                Character.list_others_active_in_areas(
                  context.character,
                  context.character.area_id
                )

              context
              |> ExecutionContext.append_output(
                others,
                "{{character}}#{context.character.name}{{/character}} picks up and stores {{item}}#{
                  thing.glance_description
                }{{/item}} inside {{item}}#{place.glance_description}{{/item}}.",
                "info"
              )
              |> ExecutionContext.append_output(
                context.character.id,
                "{{item}}#{thing.glance_description}{{/item}} is now inside {{item}}#{
                  place.glance_description
                }{{/item}}",
                "info"
              )
              |> ExecutionContext.set_success()

            not place.is_container ->
              ExecutionContext.append_output(
                context,
                context.character.id,
                "{{item}}#{place.glance_description}{{/item}} is not a container",
                "info"
              )
              |> ExecutionContext.set_success()
          end

        num_things > 1 ->
          indexed_things =
            Enum.map(thing_matches, & &1.match)
            |> Util.list_to_index_map()

          cont_data = %ContinuationData{thing: indexed_things, type: :thing, place: place_matches}

          handle_multiple_matches(
            context,
            thing_matches,
            cont_data,
            "What were you trying to store?",
            "There were too many items to choose from. Please be more specific."
          )

        num_places > 1 ->
          indexed_places =
            Enum.map(place_matches, & &1.match)
            |> Util.list_to_index_map()

          thing = List.first(thing_matches)

          cont_data = %ContinuationData{
            thing: List.first(thing_matches),
            type: :place,
            place: indexed_places
          }

          handle_multiple_matches(
            context,
            thing_matches,
            cont_data,
            "Where were you trying to store {{item}}#{thing.glance_description}{{/item}}?",
            "There were too many places to choose from. Please be more specific."
          )
      end
    else
      _err ->
        ExecutionContext.append_output(
          context,
          context.character.id,
          "Could not find what you were looking for. Please try again.",
          "error"
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
end
