defmodule Mud.Engine.Command.SingleTargetCallback do
  @moduledoc """
  A callback module for commands that focus on a single target.

  Though that doesn't mean the commands can't handle a situation where there is no target, just that the logic is built
  around a single matching item/character/link or no provided target at all. Anything else is an error.
  """

  alias Mud.Engine.Command.Context
  alias Mud.Engine.Character
  alias Mud.Engine.Message
  alias Mud.Engine.Search
  alias Mud.Engine.Util

  @spec find_match(integer(), String.t(), Character.t(), [:character | :item | :link]) ::
          {:error, :no_match | :out_of_range | {:multiple_matches, [Mud.Engine.Search.Match.t()]}}
          | {:ok, Mud.Engine.Search.Match.t()}
  def find_match(which_target, input, looking_character, target_types) do
    result =
      Search.find_matches_in_area_v2(
        target_types,
        looking_character.area_id,
        input,
        which_target
      )

    case result do
      {:ok, [match]} ->
        {:ok, match}

      {:ok, matches} ->
        {:error, {:multiple_matches, matches}}

      error ->
        error
    end
  end

  @spec handle_multiple_matches(
          Mud.Engine.Command.Context.t(),
          [Mud.Engine.Search.Match.t()],
          String.t(),
          String.t()
        ) ::
          Mud.Engine.Command.Context.t()
  def handle_multiple_matches(context, matches, multiple_matches_err, _too_many_matches_err)
      when length(matches) < 10 do
    descriptions = Enum.map(matches, & &1.short_description)

    Util.multiple_match_error(
      context,
      descriptions,
      matches,
      multiple_matches_err,
      context.command.callback_module
    )
  end

  def handle_multiple_matches(context, _matches, _multiple_matches_err, too_many_matches_err) do
    Context.append_message(
      context,
      Message.new_output(context.character.id, too_many_matches_err, "error")
    )
  end
end
