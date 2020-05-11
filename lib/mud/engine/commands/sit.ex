defmodule Mud.Engine.Command.Sit do
  @moduledoc """
  The SIT command moves the character into a sitting position.

  If no target is provided, the Character will sit in place.

  Syntax:
    - sit < on | in > target

  Examples:
    - sit
    - sit chair
    - sit on chair
  """
  use Mud.Engine.CommandCallback

  alias Mud.Engine.Object

  require Logger

  import Mud.Engine.Util

  @impl true
  def execute(%Mud.Engine.CommandContext{} = context) do
    segments = context.command.segments

    cond do
      get_in(segments.children, [:sit, :position, :target]) != nil or
          get_in(segments.children, [:sit, :target]) != nil ->
        target =
          get_in(segments.children, [:sit, :position, :target]) ||
            get_in(segments.children, [:sit, :target])

        sit_on_target(context, Enum.join(target.input, " "), context.character.physical_status.location_id)

      true ->
        help_docs = Mud.Util.get_module_docs(__MODULE__)

        context
        |> append_message(
          output(
            context.character_id,
            "{{help_docs}}#{help_docs}{{/help_docs}}"
          )
        )
        |> set_success()
    end
  end

  def sit_on_target(context, target, area_id) do
    case sit_on_target_using_exact_description(context, target, area_id) do
      {:ok, context} ->
        context

      {:error, :nomatch} ->
        case sit_on_target_using_partial_description() do
          {:ok, context} ->
            context

          {:error, :nomatch} ->
            :ok
        end
    end
  end

  defp sit_on_target_using_exact_description(context, target, area_id) do
    case Object.list_furniture_by_exact_glance_description_in_area(target, area_id) do
      [] ->
        {:error, :nomatch}

      matches when length(matches) < 10 ->
        glance_descriptions = Enum.map(matches, fn match -> match.glance_description end)

        error =
          "{{warning}}Multiple matching objects were found. Please enter the number associated with the exit you wish to use.{{/warning}}"

        multiple_link_error(
          context,
          "sit",
          glance_descriptions,
          glance_descriptions,
          error,
          __MODULE__
        )
    end
  end

  defp sit_on_target_using_partial_description(context, target, area_id) do
    # check for exact
    #  sit
    # check for partial
    #  if one, sit
    #  if multiple, menu or error
    case list_furniture_by_partial_glance_description_in_area(target, area_id) do
      [] ->
        {:error, :nomatch}

      matches when length(matches) < 10 ->
        nil
    end
  end
end
