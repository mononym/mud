defmodule Mud.Engine.Command.Put do
  @moduledoc """
  The PUT command allows a character to 'put' things...somewhere.

  If no target is provided, the Character will sit in place.

  Syntax:
    - put <thing> in <place>

  Examples:
    - put gem in gembag
  """
  use Mud.Engine.Command.Callback

  alias Mud.Engine.Command.ExecutionContext
  alias Mud.Engine.Search
  alias Mud.Engine.Model.Item

  require Logger

  @impl true
  def execute(%ExecutionContext{} = context) do
    ast = context.command.ast

    thing_search_results =
      Search.find_matches_in_area_v2(
        [:item],
        context.character.area_id,
        ast[:thing][:input],
        context.character
      )

    place_search_results =
      Search.find_matches_in_area_v2(
        [:item],
        context.character.area_id,
        ast[:thing][:path][:place][:input],
        context.character
      )

    Logger.debug(inspect(thing_search_results))
    Logger.debug(inspect(place_search_results))

    with {:ok, thing_matches} <- thing_search_results,
         {:ok, place_matches} <- place_search_results,
         num_things <- length(thing_matches),
         num_places <- length(place_matches) do
      cond do
        num_things == 1 and num_places == 1 ->
          thing = List.first(thing_matches).match
          place = List.first(place_matches).match

          Logger.debug(inspect(thing))
          Logger.debug(inspect(place))

          context =
            if thing.is_container do
              ExecutionContext.append_output(
                context,
                context.character.id,
                thing.glance_description <> " is a container",
                "info"
              )
            else
              ExecutionContext.append_output(
                context,
                context.character.id,
                thing.glance_description <> " is not a container",
                "info"
              )
            end

          Logger.debug(inspect(context))

          cond do
            place.is_container and place.container_closed ->
              Logger.debug(inspect("closed"))

              msg =
                if place.container_locked do
                  " is closed and locked"
                else
                  " is closed"
                end

              ExecutionContext.append_output(
                context,
                context.character.id,
                place.glance_description <> msg,
                "info"
              )
              |> ExecutionContext.set_success()

            place.is_container ->
              Logger.debug(inspect("open"))

              Item.update!(thing, %{area_id: nil, container_id: place.id})

              ExecutionContext.append_output(
                context,
                context.character.id,
                thing.glance_description <> " is now inside " <> place.glance_description,
                "info"
              )
              |> ExecutionContext.set_success()

            not place.is_container ->
              Logger.debug(inspect("not"))

              ExecutionContext.append_output(
                context,
                context.character.id,
                place.glance_description <> " is not a container",
                "info"
              )
              |> ExecutionContext.set_success()
          end

        true ->
          ExecutionContext.append_output(
            context,
            context.character.id,
            "I SAID GOOD DAY SIR!",
            "warning"
          )
          |> ExecutionContext.set_success()
      end
    else
      _err ->
        ExecutionContext.append_output(
          context,
          context.character.id,
          "I SAID GOOD DAY TO YOU, SIR!",
          "warning"
        )
        |> ExecutionContext.set_success()
    end
  end
end
