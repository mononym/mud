defmodule Mud.Engine.Command.Look do
  @moduledoc """
  Allows a Character to 'see' the world around them.

  Current algorithm allows for looking at items and characters, and into the next area.
  """
  use Mud.Engine.Command.Callback

  alias Mud.Engine.Model.Area
  alias Mud.Engine.Model.Item
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

    Logger.debug(inspect(context.command.ast))
    Logger.debug(inspect(input))

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

      case SingleTargetCallback.find_match(which_target, input, context.character, target_types()) do
        {:ok, match} ->
          do_thing_to_match(context, match, which_target)

        {:error, {:multiple_matches, matches}} ->
          SingleTargetCallback.handle_multiple_matches(
            context,
            matches,
            "What were you trying to look at?",
            "Please be more specific."
          )

        {:error, type} ->
          error_msg =
            case type do
              :no_match ->
                "Could not find anything to look at."

              :out_of_range ->
                "It's...it's gone! It's just not there! Maybe try again?"
            end

          ExecutionContext.append_output(
            context,
            context.character.id,
            error_msg,
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

        if thing.is_container do
          # get things in container and look at them
          thing = Mud.Repo.preload(thing, :container_items)

          items_description =
            Stream.map(thing.container_items, fn item ->
              Item.describe_glance(item, context.character)
            end)
            |> Enum.join(", ")

          container_desc = String.capitalize(match.glance_description)

          ExecutionContext.append_message(
            context,
            Message.new_output(
              context.character.id,
              container_desc <> " contains: " <> items_description,
              "info"
            )
          )
          |> ExecutionContext.set_success()
        else
          ExecutionContext.append_message(
            context,
            Message.new_output(
              context.character.id,
              "You cannot look inside " <> match.glance_description,
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

    # if we are looking in the target, check to see if container
    # if container, look at all the items in it
    # if not container, error message
  end

  defp target_types(), do: [:character, :item, :link]
end
