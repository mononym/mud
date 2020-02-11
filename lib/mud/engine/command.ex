defmodule Mud.Engine.Command do
  defstruct command: nil,
            callback_module: nil

  require Logger

  @doc """
  Take a string, find a command it matches, and execute it if possible.

  After execution messages will be sent out.
  """
  def execute(context) do
    trimmed_input = String.trim(context.raw_input)

    if context.is_continuation == true do
      context = Map.put(context, :raw_input, trimmed_input)

      case context.continuation_module.parse_continuation_arg_string(trimmed_input) do
        {:ok, parsed_args} ->
          context = %{context | parsed_args: parsed_args}

          {:ok, context} = transaction(context, &context.continuation_module.continue/1)

          process_messages(context)

          context

        {:error, _error} ->
          context
          |> Mud.Engine.CommandContext.append_message(%Mud.Engine.Output{
            id: UUID.uuid4(),
            character_id: context.character_id,
            text:
              "{{error}}Selection not recognized. Please try the original command again.{{/error}}"
          })
          |> Mud.Engine.CommandContext.clear_continuation_data()
          |> Mud.Engine.CommandContext.clear_continuation_module()
          |> Mud.Engine.CommandContext.set_is_continuation(false)
          |> Mud.Engine.CommandContext.set_success(true)
          |> process_messages()
      end
    else

      split_string =
        String.split(trimmed_input, " ", parts: 2, trim: true) |> Enum.map(&String.trim/1)

      raw_command = List.first(split_string)

      case Mud.Engine.Commands.find_command(raw_command) do
        {:ok, command} ->
          arg_string =
            if length(split_string) == 1 do
              ""
            else
              List.last(split_string)
            end

          context = %{
            context
            | command: command,
              raw_input: trimmed_input,
              raw_argument_string: arg_string
          }

          case command.callback_module.parse_execute_arg_string(arg_string) do
            {:ok, parsed_args} ->
              context = %{context | parsed_args: parsed_args}

              {:ok, context} = transaction(context, &command.callback_module.execute/1)

              process_messages(context)

              context

            {:error, _error} ->
              context
              |> Mud.Engine.CommandContext.append_message(%Mud.Engine.Output{
                id: UUID.uuid4(),
                character_id: context.character_id,
                text: "{{error}}Failed to parse arguements for `#{command.raw_input}`.{{/error}}"
              })
              |> Mud.Engine.CommandContext.set_success(true)
              |> process_messages()
          end

        {:error, :not_found} ->
          Logger.debug("No Command found")

          context
          |> Mud.Engine.CommandContext.append_message(%Mud.Engine.Output{
            id: UUID.uuid4(),
            character_id: context.character_id,
            text: "{{error}}You want to do what?{{/error}}"
          })
          |> Mud.Engine.CommandContext.set_success(true)
          |> process_messages()
      end
    end
  end

  defp transaction(context, function) do
    Mud.Repo.transaction(fn ->
      character = Mud.Engine.get_character!(context.character_id)
      context = %{context | character: character}

      if context.is_continuation do
        function.(context)
      else
        function.(context)
      end
    end)
  end

  defp process_messages(context) do
    if context.success do
      Enum.each(context.messages, fn message ->
        Mud.Engine.cast_message_to_character_session(message)
      end)
    end
  end
end
