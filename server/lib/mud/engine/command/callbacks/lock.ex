defmodule Mud.Engine.Command.Lock do
  @moduledoc """
  The LOCK command allows the Character to lock something such as a door or a chest.

  Syntax:
    - lock <target>

  Examples:
    - lock backpack
    - lock door
  """

  alias Mud.Repo
  alias Mud.Engine.Search
  alias Mud.Engine.Event.Client.{UpdateArea, UpdateInventory}
  alias Mud.Engine.Util
  alias Mud.Engine.Command.Context
  alias Mud.Engine.Command.SingleTargetCallback
  alias Mud.Engine.{Character, Item}

  require Logger

  @behaviour Mud.Engine.Command.Callback

  defp target_types(), do: [:item]

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

  @spec do_thing_to_match(Context.t(), Mud.Engine.Match.t(), boolean) ::
          Context.t()
  defp do_thing_to_match(context, match, private) do
    item = match.match

    cond do
      item.container_lockable and not item.container_open and not item.container_locked ->
        Item.update!(item, %{container_locked: true})

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
          "#{context.character.name} locked #{match.long_description}.",
          "info"
        )
        |> Context.append_output(
          context.character.id,
          String.capitalize("#{match.description.short} is now locked."),
          "info"
        )

      item.container_lockable and item.container_open ->
        Context.append_output(
          context,
          context.character.id,
          String.capitalize("#{match.description.short} can't be locked while open."),
          "error"
        )

      item.container_locked ->
        Context.append_output(
          context,
          context.character.id,
          String.capitalize("#{match.description.short} is already locked."),
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
