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
      case SingleTargetCallback.find_match(0, input, context.character, target_types()) do
        {:ok, match} ->
          which_target =
            if context.command.ast[:number] != nil do
              min(1, List.first(context.command.ast[:number][:input]))
            else
              0
            end

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

  # @spec do_thing_to_match(ExecutionContext.t(), String.t(), integer) :: ExecutionContext.t()
  # defp do_thing_to_match(context, input, which_target \\ 0) do
  #   matches =
  #     Search.find_matches_in_area(
  #       [:item, :character, :link],
  #       context.character.area_id,
  #       input,
  #       context.character
  #     )

  #   num_exact_matches = length(matches.exact_matches)
  #   num_partial_matches = length(matches.partial_matches)

  #   # NOTE: The 'duplicate' logic here is intentional. DO NOT REFACTOR UNLESS YOU ARE SURE OF WHAT YOU ARE DOING!
  #   #
  #   # Desired behaviour is that if there are exact matches, they should be handled as if there were no partial matches.
  #   cond do
  #     # happy path with a single match with no index chosen
  #     num_exact_matches == 1 and which_target == 0 ->
  #       match = List.first(matches.exact_matches)

  #       ExecutionContext.append_message(
  #         context,
  #         Message.new_output(
  #           context.character.id,
  #           match.look_description,
  #           "info"
  #         )
  #       )
  #       |> ExecutionContext.set_success()

  #     # happy path where there are matches, and chosen index is in range
  #     num_exact_matches > 1 and which_target > 0 and which_target <= num_exact_matches ->
  #       match = Enum.at(matches.exact_matches, which_target - 1)

  #       ExecutionContext.append_message(
  #         context,
  #         Message.new_output(
  #           context.character.id,
  #           match.look_description,
  #           "info"
  #         )
  #       )
  #       |> ExecutionContext.set_success()

  #     # unhappy path where there are multiple matches
  #     num_exact_matches > 1 and which_target == 0 ->
  #       handle_multiple_matches(context, matches.exact_matches)

  #     # happy path with a single match with no index chosen
  #     num_partial_matches == 1 and which_target == 0 ->
  #       match = List.first(matches.partial_matches)

  #       ExecutionContext.append_message(
  #         context,
  #         Message.new_output(
  #           context.character.id,
  #           match.look_description,
  #           "info"
  #         )
  #       )
  #       |> ExecutionContext.set_success()

  #     # happy path where there are matches, and chosen index is in range
  #     num_partial_matches > 1 and which_target > 0 and which_target <= num_partial_matches ->
  #       match = Enum.at(matches.partial_matches, which_target - 1)

  #       ExecutionContext.append_message(
  #         context,
  #         Message.new_output(
  #           context.character.id,
  #           match.look_description,
  #           "info"
  #         )
  #       )
  #       |> ExecutionContext.set_success()

  #     # unhappy path where there are multiple matches
  #     num_partial_matches > 1 and which_target == 0 ->
  #       handle_multiple_matches(context, matches.partial_matches)

  #     # unhappy path where there are multiple matches or no matches at all
  #     true ->
  #       error_msg = "Could not find what you were looking for."

  #       ExecutionContext.append_message(
  #         context,
  #         Message.new_output(context.character.id, error_msg, "error")
  #       )
  #       |> ExecutionContext.set_success()
  #   end
  # end

  # defp handle_multiple_matches(context, matches) when length(matches) < 10 do
  #   descriptions = Enum.map(matches, & &1.glance_description)

  #   error_msg =
  #     "Multiple matches were found. Please enter the number associated with the thing you wish to `look` at."

  #   Util.multiple_match_error(context, descriptions, matches, error_msg, __MODULE__)
  # end

  # defp handle_multiple_matches(context, _matches) do
  #   error_msg = "Found too many matches. Please be more specific."

  #   ExecutionContext.append_message(
  #     context,
  #     Message.new_output(context.character.id, error_msg, "error")
  #   )
  #   |> ExecutionContext.set_success()
  # end

  defp target_types(), do: [:character, :item, :link]
end
