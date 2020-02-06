defmodule Mud.Engine.Session do
  use GenServer, restart: :transient

  import Ecto.Query, warn: false
  require Logger
  alias Mud.Engine.CharacterSessionData

  @character_context_buffer_trim_size Application.get_env(
                                        :mud,
                                        :character_context_buffer_trim_size
                                      )

  @character_context_buffer_max_size Application.get_env(
                                       :mud,
                                       :character_context_buffer_max_size
                                     )

  @character_inactivity_timeout_warning Application.get_env(
                                          :mud,
                                          :character_inactivity_timeout_warning
                                        )

  @character_inactivity_timeout_final Application.get_env(
                                        :mud,
                                        :character_inactivity_timeout_final
                                      )

  defmodule State do
    defstruct character_id: nil,
              text_buffer: [],
              undelivered_text: [],
              subscribers: %{},
              inactivity_timer_reference: nil,
              inactivity_timer_type: :warning,
              input_buffer: [],
              input_processing_task: nil
  end

  defmodule Subscriber do
    defstruct pid: nil,
              ref: nil
  end

  #
  #
  # API
  #
  #

  def cast_message(character_id, message) do
    Logger.info("#{inspect(character_id)}, #{inspect(message)}")
    GenServer.cast(via(character_id), message)
  end

  @doc """
  Subscribe to the output of a character session.
  """
  def subscribe(character_id) do
    Logger.info("Session.subscribe(#{inspect(character_id)}}")
    GenServer.cast(via(character_id), {:subscribe, self()})
  end

  @doc """
  Unsubscribe from the output of a character session.
  """
  def unsubscribe(character_id) do
    Logger.info("Session.unsubscribe(#{inspect(character_id)}}")
    GenServer.cast(via(character_id), {:unsubscribe, self()})
  end

  @doc """
  Get the text history of the character.
  """
  def get_history(character_id) do
    Logger.info("Session.get_history(#{inspect(character_id)}}")

    try do
      GenServer.call(via(character_id), :get_history)
    catch
      _err ->
        state = load_character_session_data(character_id)

        state.text_buffer
    end
  end

  @doc """
  Start a session or let an existing one remain for a character.
  """
  def start(player_id, character_id) do
    Logger.info("Session.start(#{inspect(player_id)}, #{inspect(character_id)}}")

    spec = {__MODULE__, %{player_id: player_id, character_id: character_id}}

    case DynamicSupervisor.start_child(Mud.Engine.CharacterSessionSupervisor, spec) do
      {:ok, _pid} ->
        {:ok, :started}

      {:error, :already_started} ->
        {:ok, :already_started}

      {:error, error} ->
        {:ok, error}
    end
  end

  #
  #
  # Callbacks
  #
  #

  @doc false
  def start_link(args) do
    Logger.info("Session.start_link(#{inspect(args)})")
    GenServer.start_link(__MODULE__, args, name: via(args.character_id))
  end

  @doc false
  @impl true
  def init(args) do
    Logger.info("Session.init(#{inspect(args.character_id)})")
    # Load or initialize character session state
    state = load_character_session_data(args.character_id)

    # Set character to active
    state.character_id
    |> Mud.Engine.get_character!()
    |> Mud.Engine.update_character(%{active: true})

    # Start inactivity timer
    state = update_timeout(state, @character_inactivity_timeout_warning)

    {:ok, state}
  end

  def handle_cast(%Mud.Engine.Output{} = output, state) do
    Logger.info("Session handling cast: output: #{output.text}")

    output = %{output | text: maybe_transform_text_for_web(output.text)}

    state = update_buffer(state, output)

    state =
      if map_size(state.subscribers) != 0 do
        Map.values(state.subscribers)
        |> Enum.each(fn subscriber ->
          GenServer.cast(subscriber.pid, output)
        end)

        state
      else
        %{state | undelivered_text: [output | state.undelivered_text]}
      end

    {:noreply, state}
  end

  @impl true
  def handle_cast(%Mud.Engine.Input{} = input, state) do
    state = update_timeout(state, @character_inactivity_timeout_warning)

    Logger.info(
      "Session handling cast: input: #{
        inspect({length(state.input_buffer), state.input_processing_task})
      }"
    )

    cond do
      length(state.input_buffer) == 0 and state.input_processing_task == nil ->
        input_processing_task = send_input_for_processing(input)

        {:noreply,
         %{
           state
           | input_processing_task: input_processing_task
         }}

      length(state.input_buffer) > 0 and state.input_processing_task == nil ->
        state = execute_next_input_from_buffer(state)

        {:noreply, %{state | input_buffer: [input | state.input_buffer]}}

      state.input_processing_task != nil ->
        state = %{state | input_buffer: [input | state.input_buffer]}

        {:noreply, state}
    end
  end

  def handle_cast({:input_processing_finished, execution_context}, state) do
    Logger.info("#{inspect({:input_processing_finished, execution_context, state})}")

    if execution_context.terminate_session do
      persist_state(state)

      {:stop, :normal, state}
    else
      if length(state.input_buffer) > 0 do
        state = execute_next_input_from_buffer(state)

        {:noreply, state}
      else
        {:noreply, %{state | input_processing_task: nil}}
      end
    end
  end

  def handle_cast({:subscribe, process}, state) do
    Logger.info("#{inspect({:subscribe, process})}")
    ref = Process.link(process)

    updated_subscribers = Map.put(state.subscribers, ref, %Subscriber{pid: process})

    state =
      if length(state.undelivered_text) != 0 do
        Map.values(updated_subscribers)
        |> Enum.each(fn subscriber ->
          GenServer.cast(subscriber.pid, zip_output(state.undelivered_text))
        end)

        %{state | undelivered_text: []}
      else
        state
      end

    {:noreply, %{state | subscribers: updated_subscribers}}
  end

  def handle_cast({:unsubscribe, process}, state) do
    Logger.info("#{inspect({:unsubscribe, process})}")

    subscriber =
      Enum.find(state.subscribers, nil, fn {_ref, %{pid: pid}} ->
        pid == process
      end)

    if subscriber != nil do
      Process.demonitor(subscriber.ref)
    end

    updated_subscribers = Map.delete(state.subscribers, subscriber.ref)

    {:noreply, %{state | subscribers: updated_subscribers}}
  end

  def handle_cast(msg, state) do
    Logger.error("Received unexpected cast: #{inspect(msg)}")

    {:noreply, state}
  end

  @impl true
  def handle_call(:get_history, _from, state) do
    {:reply, state.text_buffer, state}
  end

  @impl true
  def handle_call(msg, _from, state) do
    Logger.error("Received unexpected call: #{inspect(msg)}")

    {:noreply, state}
  end

  def handle_info({ref, :ok}, state) when is_reference(ref) do
    {:noreply, state}
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, state) do
    updated_subscribers = Map.delete(state.subscribers, ref)
    {:noreply, %{state | subscribers: updated_subscribers}}
  end

  @impl true
  def handle_info(:inactivity_timeout, state = %{inactivity_timer_type: :warning}) do
    GenServer.cast(self(), %Mud.Engine.Output{
      id: UUID.uuid4(),
      character_id: state.character_id,
      text:
        "{{warning}}***** YOU HAVE BEEN IDLE FOR 10 MINUTES AND WILL BE DISCONNECTED SOON *****{{/warning}}"
    })

    state = update_timeout(state, @character_inactivity_timeout_final)

    {:noreply, %{state | inactivity_timer_type: :final}}
  end

  def handle_info(:inactivity_timeout, state = %{inactivity_timer_type: :final}) do
    GenServer.cast(self(), %Mud.Engine.Output{
      id: UUID.uuid4(),
      character_id: state.character_id,
      text:
        "{{error}}***** YOU HAVE BEEN IDLE TOO LONG AND ARE BEING DISCONNECTED *****{{/error}}"
    })

    GenServer.cast(self(), %Mud.Engine.Input{
      id: UUID.uuid4(),
      character_id: state.character_id,
      text: "quit",
      type: :silent
    })

    {:noreply, state}
  end

  def handle_info(event, state) do
    Logger.error("Received unexpected message: #{inspect(event)}")

    {:noreply, state}
  end

  def terminate(reason, _state, state) when reason != :normal do
    Logger.info("############################# SESSION TERMINATING #############################")

    Mud.Engine.Command.Quit.do_ingame_stuff(state)

    persist_state(state)
  end

  #
  #
  # Private functions
  #
  #

  defp persist_state(state) do
    Logger.info("PERSISTING STATE")

    case Mud.Repo.get(CharacterSessionData, state.character_id) do
      nil ->
        changeset =
          CharacterSessionData.changeset(
            %CharacterSessionData{},
            %{character_id: state.character_id, data: :erlang.term_to_binary(state)}
          )

        Mud.Repo.insert!(changeset)

      changeset ->
        changeset =
          CharacterSessionData.changeset(
            changeset,
            %{data: :erlang.term_to_binary(state)}
          )

        Mud.Repo.update!(changeset)
    end
  end

  defp execute_next_input_from_buffer(state) do
    {input_buffer, queued_input} = Enum.split(state.input_buffer, -1)

    state = %{state | input_buffer: input_buffer}

    input_processing_task =
      queued_input
      |> List.first()
      |> send_input_for_processing()

    %{state | input_processing_task: input_processing_task}
  end

  defp send_input_for_processing(input) do
    session_pid = self()

    # send stuff off to task
    task =
      Task.async(fn ->
        if input.type == :normal do
          GenServer.cast(session_pid, %Mud.Engine.Output{
            id: input.id,
            character_id: input.character_id,
            text: "{{echo}}> #{input.text}{{/echo}}"
          })
        end

        execution_context =
          Mud.Engine.Command.execute(%Mud.Engine.CommandContext{
            id: input.id,
            character_id: input.character_id,
            raw_input: input.text
          })

        GenServer.cast(session_pid, {:input_processing_finished, execution_context})
      end)

    task.ref
  end

  defp update_buffer(state, output) do
    text_buffer = maybe_deal_with_overflow([output | state.text_buffer])

    %{state | text_buffer: text_buffer}
  end

  defp zip_output(output_list) do
    joined_text =
      output_list
      |> Stream.map(fn output ->
        if String.contains?(output.text, "<p") do
          output.text
        else
          "<p class=\"whitespace-pre-wrap\">#{output.text}</p>"
        end
      end)
      |> Enum.reverse()
      |> Enum.join()

    output_list
    |> List.first()
    |> Map.put(:text, joined_text)
  end

  defp maybe_deal_with_overflow(text_buffer) do
    if length(text_buffer) > @character_context_buffer_max_size do
      Logger.info("TEXT BUFFER OVERFLOW")
      messages_to_trim = @character_context_buffer_max_size - @character_context_buffer_trim_size

      Enum.reverse_slice(text_buffer, 0, messages_to_trim)
    else
      Logger.info("TEXT BUFFER SAFE")
      text_buffer
    end
  end

  defp update_timeout(state, timeout) do
    Logger.info("updating timeout")

    if state.inactivity_timer_reference != nil do
      Process.cancel_timer(state.inactivity_timer_reference)
    end

    inactivity_timer_reference = Process.send_after(self(), :inactivity_timeout, timeout)

    %{state | inactivity_timer_reference: inactivity_timer_reference}
  end

  defp via(character_id) do
    {:via, Registry, {Mud.Engine.CharacterSessionRegistry, character_id}}
  end

  defp load_character_session_data(character_id) do
    Logger.info("LOADING CHARACTER DATA")

    result =
      Mud.Repo.one(
        from(
          data in Mud.Engine.CharacterSessionData,
          where: data.character_id == ^character_id
        )
      )

    case result do
      nil ->
        %State{
          character_id: character_id
        }

      state ->
        data = :erlang.binary_to_term(state.data)

        %State{
          character_id: data.character_id,
          text_buffer: data.text_buffer,
          undelivered_text: data.undelivered_text
        }
    end
  end

  def maybe_transform_text_for_web(text) do
    if String.contains?(text, "<span") do
      text
    else
      transform_text(text)
    end
  end

  defp transform_text(text) do
    case Regex.named_captures(~r/.*?{{(?<tag>.+?)}}.*/, text) do
      nil ->
        "<p class=\"whitespace-pre-wrap\">#{text}</p>"

      %{"tag" => tag} ->
        text
        |> String.replace("{{#{tag}}}", "<span class=\"#{tag_to_text_color(tag)}\">")
        |> String.replace("{{/#{tag}}}", "</span>")
        |> transform_text()
    end
  end

  defp tag_to_text_color("area-name") do
    "text-yellow-700"
  end

  defp tag_to_text_color("area-description") do
    "text-teal-700"
  end

  defp tag_to_text_color("also-present") do
    "text-green-700"
  end

  defp tag_to_text_color("denizens") do
    "text-green-700"
  end

  defp tag_to_text_color("hostiles") do
    "text-green-700"
  end

  defp tag_to_text_color("obvious-exits") do
    "text-blue-700"
  end

  defp tag_to_text_color("echo") do
    "text-gray-700"
  end

  defp tag_to_text_color("error") do
    "text-red-800"
  end

  defp tag_to_text_color("info") do
    "text-gray-700"
  end

  defp tag_to_text_color(_tag) do
    "text-gray-700"
  end
end
