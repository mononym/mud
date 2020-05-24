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
  alias Mud.Engine.Model.{Character}
  alias Mud.Engine.Search
  alias Mud.Engine.Message

  require Logger

  import Mud.Engine.Util

  @impl true
  def execute(%ExecutionContext{} = context) do
    ast = context.command.ast

    Logger.debug(inspect(ast))

    %{partial_matches: [%{match: thing}]} =
      Search.find_matches_in_area(
        [:item],
        context.character.area_id,
        ast[:thing][:input],
        context.character
      )

    Logger.debug(inspect(thing))

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

    %{partial_matches: [%{match: place}]} =
      Search.find_matches_in_area(
        [:item],
        context.character.area_id,
        ast[:thing][:path][:place][:input],
        context.character
      )

    Logger.debug(inspect(place))
    Logger.debug(inspect(place))

    if place.is_container do
      ExecutionContext.append_output(
        context,
        context.character.id,
        place.glance_description <> " is a container",
        "info"
      )
      |> ExecutionContext.set_success()
    else
      ExecutionContext.append_output(
        context,
        context.character.id,
        place.glance_description <> " is not a container",
        "info"
      )
      |> ExecutionContext.set_success()
    end
  end

  defp check_matches(matches, which_target) do
    # if single object

    num_matches = length(matches)

    cond do
      # happy path with a single match with no index chosen
      num_matches == 1 and which_target == 0 ->
        match = List.first(matches)

        {:ok, match}

      # happy path where there are multiple matches, and chosen index is in range
      num_matches > 0 and which_target > 0 and which_target <= num_matches ->
        match = Enum.at(matches, which_target - 1)

        {:ok, match}

      # unhappy path where there are multiple matches and no preselected choice
      num_matches > 1 and which_target == 0 ->
        {:error, {:multiple_matches, matches}}

      # unhappy path where there are multiple matches but chosen index is out of range
      num_matches > 0 and which_target > num_matches ->
        {:error, :out_of_range}

      # unhappy path where there are no matches
      num_matches == 0 ->
        {:error, :no_match}
    end
  end
end
