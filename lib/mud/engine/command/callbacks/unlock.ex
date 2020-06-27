defmodule Mud.Engine.Command.Unlock do
  @moduledoc """
  The UNLOCK command allows the Character to lock something such as a door or a chest.

  Syntax:
    - unlock <target>

  Examples:
    - unlock backpack
    - unlock door
  """

  alias Mud.Repo
  alias Mud.Engine.Event.Client.{UpdateArea, UpdateInventory}
  alias Mud.Engine.Search
  alias Mud.Engine.Util
  alias Mud.Engine.Command.ExecutionContext
  alias Mud.Engine.Command.SingleTargetCallback
  alias Mud.Engine.{Character, Item}

  @behaviour Mud.Engine.Command.Callback

  defp target_types(), do: [:item]

  @doc false
  @impl true
  @spec continue(Mud.Engine.Command.ExecutionContext.t()) ::
          Mud.Engine.Command.ExecutionContext.t()
  def continue(context) do
    target = Util.refresh_thing(context.input.match)

    cond do
      context.character.area_id == target.area_id ->
        do_thing_to_match(context, %{context.input | match: target}, false)

      context.character.id == target.worn_by_id ->
        do_thing_to_match(context, %{context.input | match: target}, true)

      true ->
        ExecutionContext.append_output(
          context,
          context.character.id,
          "The #{context.input.short_description} is no longer present.",
          "error"
        )
        |> ExecutionContext.set_success()
    end
  end

  @doc false
  @impl true
  @spec execute(Mud.Engine.Command.ExecutionContext.t()) ::
          Mud.Engine.Command.ExecutionContext.t()
  def execute(context) do
    {input, which_target} = extract_input_and_target(context.command.ast)

    result =
      Search.find_matches_in_area_v2(
        target_types(),
        context.character.area_id,
        input,
        which_target
      )

    multi_error = "Which of these did you intend to open?"
    too_many = "You can't possibly open all of those at once. Please be more specific."

    case result do
      {:ok, [match]} ->
        do_thing_to_match(context, match, false)

      {:ok, matches} ->
        SingleTargetCallback.handle_multiple_matches(context, matches, multi_error, too_many)
        |> ExecutionContext.set_success()

      {:error, _} ->
        character = Repo.preload(context.character, :worn_items)
        worn_items = character.worn_items

        case Search.generate_matches(worn_items, input, which_target) do
          {:ok, [match]} ->
            do_thing_to_match(context, match, true)

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

  @spec do_thing_to_match(ExecutionContext.t(), Mud.Engine.Match.t(), boolean()) ::
          ExecutionContext.t()
  defp do_thing_to_match(context, match, private) do
    item = match.match

    cond do
      item.container_locked ->
        Item.update!(item, %{container_locked: false})

        others =
          Character.list_others_active_in_areas(context.character.id, context.character.area_id)

        context =
          if private do
            ExecutionContext.append_event(
              context,
              context.character_id,
              UpdateInventory.new(:update, item)
            )
          else
            ExecutionContext.append_event(
              context,
              [context.character_id | others],
              UpdateArea.new(:update, item)
            )
          end

        context
        |> ExecutionContext.append_output(
          others,
          "#{context.character.name} unlocked #{match.short_description}.",
          "info"
        )
        |> ExecutionContext.append_output(
          context.character.id,
          String.capitalize("#{match.short_description} is now unlocked."),
          "info"
        )
        |> ExecutionContext.set_success()

      item.container_lockable and not item.container_locked ->
        ExecutionContext.append_output(
          context,
          context.character.id,
          String.capitalize("#{match.short_description} is already unlocked."),
          "error"
        )
        |> ExecutionContext.set_success()

      not item.container_lockable ->
        ExecutionContext.append_output(
          context,
          context.character.id,
          String.capitalize("#{match.short_description} is not lockable."),
          "error"
        )
        |> ExecutionContext.set_success()
    end
  end
end
