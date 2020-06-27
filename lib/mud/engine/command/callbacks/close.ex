defmodule Mud.Engine.Command.Close do
  @moduledoc """
  The CLOSE command allows the Character to close something such as a door or a chest.

  Syntax:
    - close <target>

  Examples:
    - close backpack
    - close door
  """

  alias Mud.Repo
  alias Mud.Engine.Search
  alias Mud.Engine.Util
  alias Mud.Engine.Command.ExecutionContext
  alias Mud.Engine.Command.SingleTargetCallback
  alias Mud.Engine.{Character, Item}

  require Logger

  @behaviour Mud.Engine.Command.Callback

  defp target_types(), do: [:item]

  @impl true
  def continue(context) do
    target = Util.refresh_thing(context.input.match)

    if context.character.area_id == target.area_id or context.character.id == target.worn_by_id do
      do_thing_to_match(context, %{context.input | match: target})
    else
      ExecutionContext.append_output(
        context,
        context.character.id,
        "The #{context.input.short_description} is no longer present.",
        "error"
      )
      |> ExecutionContext.set_success()
    end
  end

  @impl true
  def execute(context) do
    {input, which_target} = extract_input_and_target(context.command.ast)

    result =
      Search.find_matches_in_area_v2(
        target_types(),
        context.character.area_id,
        input,
        which_target
      )

    multi_error = "Which of these did you intend to close?"
    too_many = "You can't possibly close all of those at once. Please be more specific."

    case result do
      {:ok, [match]} ->
        do_thing_to_match(context, match)

      {:ok, matches} ->
        SingleTargetCallback.handle_multiple_matches(context, matches, multi_error, too_many)
        |> ExecutionContext.set_success()

      {:error, _} ->
        character = Repo.preload(context.character, :worn_items)
        worn_items = character.worn_items

        case Search.generate_matches(worn_items, input, which_target) do
          {:ok, [match]} ->
            do_thing_to_match(context, match)

          {:ok, matches} ->
            SingleTargetCallback.handle_multiple_matches(context, matches, multi_error, too_many)
            |> ExecutionContext.set_success()
        end
    end
  end

  defp extract_input_and_target(ast) do
    cond do
      ast.generations == 3 ->
        target = ast[:my][:number][:input]
        input = ast[:my][:number][:target][:input]

        {input, target}

      ast.generations == 2 and ast[:number] != nil ->
        target = ast[:number][:input]
        input = ast[:number][:target][:input]

        {input, target}

      ast.generations == 2 ->
        input = ast[:number][:target][:input]

        {input, 0}

      true ->
        input = ast[:target][:input]

        {input, 0}
    end
  end

  @spec do_thing_to_match(ExecutionContext.t(), Mud.Engine.Match.t()) :: ExecutionContext.t()
  defp do_thing_to_match(context, match) do
    item = match.match

    cond do
      item.is_container and item.container_open ->
        Item.update!(item, %{container_open: false})

        others =
          Character.list_others_active_in_areas(context.character.id, context.character.area_id)

        context
        |> ExecutionContext.append_output(
          others,
          "#{context.character.name} closed #{match.short_description}.",
          "info"
        )
        |> ExecutionContext.append_output(
          context.character.id,
          String.capitalize("#{match.short_description} is now closed."),
          "info"
        )
        |> ExecutionContext.set_success()

      item.is_container and not item.container_open ->
        ExecutionContext.append_output(
          context,
          context.character.id,
          String.capitalize("#{match.short_description} is already closed."),
          "error"
        )
        |> ExecutionContext.set_success()

      not item.is_container ->
        ExecutionContext.append_output(
          context,
          context.character.id,
          String.capitalize("#{match.short_description} cannot be closed."),
          "error"
        )
        |> ExecutionContext.set_success()
    end
  end
end
