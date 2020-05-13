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

  alias Mud.Engine.{CommandContext, Object}
  alias Mud.Engine.Component.{CharacterPhysicalStatus}
  alias Mud.Repo

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

        sit_on_target(
          context,
          Enum.join(target.input, " "),
          context.character.physical_status.location_id
        )

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
        case sit_on_target_using_partial_description(context, target, area_id) do
          {:ok, context} ->
            context

          {:error, :nomatch} ->
            :ok
        end
    end
  end

  defp sit_on_target_using_exact_description(context, target, area_id) do
    case Object.list_furniture_by_exact_glance_description_in_area(target, area_id) do
      [match] ->
        make_character_sit(context, match)

      _matches ->
        {:error, :nomatch}
    end
  end

  @spec make_character_sit(context :: CommandContext.t(), furniture_object :: Object.t()) ::
          {:ok, CommandContext.t()} | {:error, :nomatch}
  defp make_character_sit(context, furniture_object) do
    if furniture_object.furniture.is_furniture do
      physical_status = context.character.physical_status

      update = %{
        position: "sitting",
        relative_position: "on",
        relative_object: furniture_object.id
      }

      CharacterPhysicalStatus.changeset(physical_status, update)
      |> Repo.update!()

      context =
        context
        |> append_message(
          output(
            context.character_id,
            "{{info}}You sit down on the #{furniture_object.description.look_description}{{/info}}"
          )
        )
        |> set_success()

      {:ok, context}
    else
      context =
        context
        |> append_message(
          output(
            context.character_id,
            "{{warning}}Unfortunately, #{furniture_object.description.glance_description} can not be sat on.{{/warning}}"
          )
        )
        |> set_success()

      {:ok, context}
    end
  end

  defp sit_on_target_using_partial_description(context, target, area_id) do
    case Object.list_furniture_by_partial_glance_description_in_area(target, area_id) do
      [] ->
        {:error, :nomatch}

      [match] ->
        make_character_sit(context, match)

      matches when length(matches) < 10 ->
        descriptions = Enum.map(matches, & &1.description.glance_description)
        objects = Enum.map(matches, & &1.id)

        error =
          "{{warning}}Multiple matching pieces of furniture were found. Please enter the number associated with the furniture you wish to sit on.{{/warning}}"

        context =
          context
          |> multiple_match_error("move", descriptions, objects, error, __MODULE__)
          |> set_success()

        {:ok, context}

      _matched ->
        context =
          context
          |> append_message(
            output(
              context.character_id,
              "{{warning}}You want to sit where? There are too many options!{{/warning}}"
            )
          )
          |> set_success()

        {:ok, context}
    end
  end
end
