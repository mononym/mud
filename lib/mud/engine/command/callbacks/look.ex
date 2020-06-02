defmodule Mud.Engine.Command.Look do
  @moduledoc """
  Allows a Character to 'see' the world around them.

  Current algorithm allows for looking at items and characters, and into the next area.
  """
  use Mud.Engine.Command.Callback

  alias Mud.Engine.Area
  alias Mud.Engine.Search
  alias Mud.Engine.Item
  alias Mud.Engine.Command.ExecutionContext
  alias Mud.Engine.Util
  alias Mud.Engine.Message
  alias Mud.Engine.Command.SingleTargetCallback

  require Logger

  defmodule ContinuationData do
    @enforce_keys [:data, :type]
    defstruct type: nil,
              data: nil
  end

  @impl true
  def continue(context) do
    match = Util.refresh_thing(context.input.match)
    do_thing_to_match(context, match)
  end

  @impl true
  def execute(context) do
    Logger.debug(inspect(context.command.ast))

    input =
      get_in(context.command.ast, [:target, :input]) ||
        get_in(context.command.ast, [:in, :target, :input]) ||
        get_in(context.command.ast, [:at, :target, :input])

    if input == nil do
      description = Area.describe_look(context.character.area_id, context.character)

      context
      |> ExecutionContext.append_message(Message.new_output(context.character_id, description))
      |> ExecutionContext.set_success()
    else
      which_target =
        cond do
          context.command.ast[:number] != nil ->
            min(1, List.first(context.command.ast[:number][:input]))

          context.command.ast[:at][:number] != nil ->
            min(1, List.first(context.command.ast[:at][:number][:input]))

          context.command.ast[:in][:number] != nil ->
            min(1, List.first(context.command.ast[:in][:number][:input]))

          true ->
            0
        end

      result =
        Search.find_matches_in_area_v2(
          target_types(),
          context.character.area_id,
          input,
          context.character,
          which_target
        )

      case result do
        {:ok, [match]} ->
          do_thing_to_match(context, match, which_target)

        {:ok, matches} ->
          SingleTargetCallback.handle_multiple_matches(
            context,
            matches,
            "What were you trying to look at?",
            "Please be more specific."
          )

        _error ->
          ExecutionContext.append_output(
            context,
            context.character.id,
            "Could not find anything to look at.",
            "error"
          )
          |> ExecutionContext.set_success()
      end
    end
  end

  @spec do_thing_to_match(ExecutionContext.t(), Mud.Engine.Search.Match.t(), integer) ::
          ExecutionContext.t()
  defp do_thing_to_match(context, match, _which_target \\ 0) do
    ast = context.command.ast

    cond do
      get_in(ast, [:in]) != nil ->
        thing = match.match

        cond do
          thing.is_container and thing.container_open ->
            # get things in container and look at them
            thing = Mud.Repo.preload(thing, :container_items)

            items_description =
              Stream.map(thing.container_items, fn item ->
                Item.describe_glance(item, context.character)
              end)
              |> Enum.join("{{/item}}, {{item}}")

            container_desc = String.capitalize(match.glance_description)

            if length(thing.container_items) > 0 do
              ExecutionContext.append_message(
                context,
                Message.new_output(
                  context.character.id,
                  "{{item}}#{container_desc}{{/item}} contains: {{item}}#{items_description}{{/item}}.",
                  "info"
                )
              )
              |> ExecutionContext.set_success()
            else
              ExecutionContext.append_message(
                context,
                Message.new_output(
                  context.character.id,
                  "{{item}}#{container_desc}{{/item}} is empty.",
                  "info"
                )
              )
              |> ExecutionContext.set_success()
            end

          thing.is_container and not thing.container_open ->
            ExecutionContext.append_message(
              context,
              Message.new_output(
                context.character.id,
                String.capitalize(
                  "{{item}}#{match.glance_description}{{/item}} must be opened first."
                ),
                "info"
              )
            )
            |> ExecutionContext.set_success()

          not thing.is_container ->
            ExecutionContext.append_message(
              context,
              Message.new_output(
                context.character.id,
                "You cannot look inside {{item}}#{match.glance_description}{{/item}}.",
                "info"
              )
            )
            |> ExecutionContext.set_success()
        end

      true ->
        ExecutionContext.append_message(
          context,
          Message.new_output(
            context.character.id,
            match.look_description,
            "info"
          )
        )
        |> ExecutionContext.set_success()
    end
  end

  defp target_types(), do: [:character, :item, :link]
end
