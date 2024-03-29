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
  alias Mud.Engine.Command.Context
  alias Mud.Engine.Command.SingleTargetCallback
  alias Mud.Engine.{Character, Item}

  @behaviour Mud.Engine.Command.Callback

  defp target_types(), do: [:item]

  @doc false
  @impl true
  @spec continue(Mud.Engine.Command.Context.t()) ::
          Mud.Engine.Command.Context.t()
  def continue(context) do
    target = Util.refresh_thing(context.input.match)

    cond do
      context.character.area_id == target.area_id ->
        do_thing_to_match(context, %{context.input | match: target}, false)

      context.character.id == target.worn_by_id ->
        do_thing_to_match(context, %{context.input | match: target}, true)

      true ->
        Context.append_output(
          context,
          context.character.id,
          "The #{context.input.description.short} is no longer present.",
          "error"
        )
    end
  end

  @doc false
  @impl true
  @spec execute(Mud.Engine.Command.Context.t()) ::
          Mud.Engine.Command.Context.t()
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

      {:error, _} ->
        character = Repo.preload(context.character, :worn_items)
        worn_items = character.worn_items

        case Search.generate_matches(worn_items, input, which_target) do
          {:ok, [match]} ->
            do_thing_to_match(context, match, true)

          {:ok, matches} ->
            SingleTargetCallback.handle_multiple_matches(context, matches, multi_error, too_many)
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

  @spec do_thing_to_match(Context.t(), Mud.Engine.Match.t(), boolean()) ::
          Context.t()
  defp do_thing_to_match(context, match, private) do
    item = match.match

    cond do
      item.container_locked ->
        Item.update!(item, %{container_locked: false})

        others =
          Character.list_others_active_in_areas(context.character.id, context.character.area_id)

        context =
          if private do
            Context.append_event(
              context,
              context.character_id,
              UpdateInventory.new(:update, item)
            )
          else
            Context.append_event(
              context,
              [context.character_id | others],
              UpdateArea.new(:update, item)
            )
          end

        context
        |> Context.append_output(
          others,
          "#{context.character.name} unlocked #{match.description.short}.",
          "info"
        )
        |> Context.append_output(
          context.character.id,
          String.capitalize("#{match.description.short} is now unlocked."),
          "info"
        )

      item.container_lockable and not item.container_locked ->
        Context.append_output(
          context,
          context.character.id,
          String.capitalize("#{match.description.short} is already unlocked."),
          "error"
        )

      not item.container_lockable ->
        Context.append_output(
          context,
          context.character.id,
          String.capitalize("#{match.description.short} is not lockable."),
          "error"
        )
    end
  end
end
