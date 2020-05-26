defmodule Mud.Engine.Command.SingleTargetCallback do
  @moduledoc """
  A callback module for commands that focus on a single target.

  Though that doesn't mean the commands can't handle a situation where there is no target, just that the logic is built
  around a single matching item/character/link or no provided target at all. Anything else is an error.
  """

  alias Mud.Engine.Command.ExecutionContext
  alias Mud.Engine.Model.Character
  alias Mud.Engine.Message
  alias Mud.Engine.Search
  alias Mud.Engine.Util

  # @spec find_match(Mud.Engine.Command.ExecutionContext.t(), [atom()]) ::
  #         {:error, {:multiple_matches, [Mud.Engine.Search.Match.t()]} | :no_match | :out_of_range}
  #         | {:ok, any}
  # def find_match(context = %ExecutionContext{}, target_types) do
  @spec find_match(integer, String.t(), Character.t(), [:character | :item | :link]) ::
          {:error, :no_match | :out_of_range | {:multiple_matches, [map]}} | {:ok, any}
  def find_match(which_target, input, looking_character, target_types) do
    matches =
      Search.find_matches_in_area(
        target_types,
        looking_character.area_id,
        input,
        looking_character
      )

    check_matches(matches.exact_matches, which_target)

    case check_matches(matches.exact_matches, which_target) do
      {:error, :no_match} ->
        check_matches(matches.partial_matches, which_target)

      result ->
        result
    end
  end

  @spec handle_multiple_matches(
          Mud.Engine.Command.ExecutionContext.t(),
          [Mud.Engine.Search.Match.t()],
          String.t(),
          String.t()
        ) ::
          Mud.Engine.Command.ExecutionContext.t()
  def handle_multiple_matches(context, matches, multiple_matches_err, _too_many_matches_err)
      when length(matches) < 10 do
    descriptions = Enum.map(matches, & &1.glance_description)

    Util.multiple_match_error(
      context,
      descriptions,
      matches,
      multiple_matches_err,
      context.command.callback_module
    )
  end

  def handle_multiple_matches(context, _matches, _multiple_matches_err, too_many_matches_err) do
    ExecutionContext.append_message(
      context,
      Message.new_output(context.character.id, too_many_matches_err, "error")
    )
    |> ExecutionContext.set_success()
  end

  # @spec check_matches([Search.Match.t()], integer()) ::
  #         {:ok, Mud.Engine.Search.Match.t()}
  #         | {:error, :multiple_matches, :no_match, :out_of_range}
  defp check_matches(matches, which_target) do
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
