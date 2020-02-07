defmodule Mud.Engine.Command do
  defstruct command: nil,
            callback_module: nil

  @doc """
  Take a string, find a command it matches, and execute it if possible.

  After execution messages will be sent out.
  """
  def execute(context) do
    trimmed_input = String.trim(context.raw_input)

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

        case command.callback_module.parse_arg_string(arg_string) do
          {:ok, parsed_args} ->
            context = %{context | parsed_args: parsed_args}

            {:ok, context} =
              Mud.Repo.transaction(fn ->
                character = Mud.Engine.get_character!(context.character_id)
                context = %{context | character: character}
                command.callback_module.execute(context)

            end)

            Enum.each(context.messages, fn message ->
              Mud.Engine.cast_message_to_character_session(message)
            end)

            context

          {:error, error} ->
            {:error, error}
        end

      {:error, :not_found} ->
        :error
    end
  end
end
