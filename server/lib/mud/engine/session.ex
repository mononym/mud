defmodule Mud.Engine.Session do
  use GenServer, restart: :transient

  import Ecto.Query, warn: false
  require Logger
  alias Mud.Engine.CharacterSessionData
  alias Mud.Engine.Event

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
              undelivered_events: [],
              subscribers: %{},
              inactivity_timer_reference: nil,
              inactivity_timer_type: :warning,
              input_buffer: [],
              input_processing_task: nil,
              travel_task: nil,
              continuation_data: nil,
              is_continuation: false,
              continuation_module: nil,
              continuation_type: nil
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

  @spec cast_message_or_event(
          %Mud.Engine.Message.Output{}
          | %Mud.Engine.Message.Input{}
          | Mud.Engine.Event.t()
        ) :: :ok
  def cast_message_or_event(message_or_event) do
    to = List.wrap(message_or_event.to)

    Enum.each(to, fn dest ->
      msg = %{message_or_event | to: dest}
      IO.inspect(msg, label: "cast_message_or_event/1")
      GenServer.cast(via(dest), msg)
    end)
  end

  @doc """
  Subscribe to the output of a character session.
  """
  def subscribe(character_id) do
    Logger.debug("Subscribing to character: #{character_id}")

    GenServer.call(via(character_id), {:subscribe, self()})
  end

  @doc """
  Unsubscribe from the output of a character session.
  """
  def unsubscribe(character_id) do
    GenServer.cast(via(character_id), {:unsubscribe, self()})
  end

  @doc """
  Get the text history of the character.
  """
  def get_history(character_id) do
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
  def start(character_id) do
    Logger.debug("Starting character: #{character_id}", label: "Mud.Engine.Session.start/2")
    spec = {__MODULE__, %{character_id: character_id}}

    case DynamicSupervisor.start_child(Mud.Engine.CharacterSessionSupervisor, spec) do
      {:ok, _pid} ->
        {:ok, :started}

      {:error, :already_started} ->
        {:ok, :already_started}

      {:error, error} ->
        {:error, error}
    end
  end

  #
  #
  # Callbacks
  #
  #

  @doc false
  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: via(args.character_id))
  end

  @doc false
  @impl true
  def init(args) do
    IO.inspect(args, label: "Mud.Engine.Session.init/1")
    # Load or initialize character session state
    state = load_character_session_data(args.character_id)
    IO.inspect(state, label: "Mud.Engine.Session.init/1")

    # Set character to active
    state.character_id
    |> Mud.Engine.Character.get_by_id!()
    |> IO.inspect()
    |> Mud.Engine.Character.update(%{active: true})
    |> IO.inspect(label: "update")

    IO.inspect("update", label: "Mud.Engine.Session.init/1")

    # Start inactivity timer
    state = update_timeout(state, @character_inactivity_timeout_warning)
    IO.inspect("ok", label: "Mud.Engine.Session.init/1")

    {:ok, state}
  end

  def handle_cast(%Event{} = event, state) do
    Logger.debug("#{inspect(event)}")
    Logger.debug("Subscribers: #{inspect(state.subscribers)}")

    state =
      if map_size(state.subscribers) != 0 do
        Map.values(state.subscribers)
        |> Enum.each(fn subscriber ->
          GenServer.cast(subscriber.pid, event)
        end)

        state
      else
        %{state | undelivered_events: [event | state.undelivered_events]}
      end

    {:noreply, state}
  end

  def handle_cast(%Mud.Engine.Message.Output{} = output, state) do
    Logger.debug("#{inspect(output)}", label: "session_handle_cast")
    Logger.debug("Subscribers: #{inspect(state.subscribers)}")

    output = %{output | text: Mud.Engine.Message.Output.transform_for_web(output)}

    state = update_buffer(state, output.text)

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
  def handle_cast(%Mud.Engine.Message.Input{} = input, state) do
    Logger.debug("#{inspect(input)}", label: "session_handle_cast")
    # Logger.debug("#{inspect(state)}", label: "handle_cast")
    state = update_timeout(state, @character_inactivity_timeout_warning)

    cond do
      length(state.input_buffer) == 0 and state.input_processing_task == nil ->
        input_processing_task = send_input_for_processing(input, state)

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
    state = %{
      state
      | continuation_data: execution_context.continuation_data,
        is_continuation: execution_context.is_continuation,
        continuation_module: execution_context.continuation_module,
        continuation_type: execution_context.continuation_type
    }

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

  def handle_cast({:unsubscribe, process}, state) do
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

  def handle_call({:subscribe, process}, _from, state) do
    Logger.debug("Recieved subscription request from: #{inspect(process)}")
    ref = Process.monitor(process)

    updated_subscribers = Map.put(state.subscribers, ref, %Subscriber{pid: process})

    Map.values(updated_subscribers)
    |> Enum.each(fn subscriber ->
      if length(state.text_buffer) > 0 do
        GenServer.cast(subscriber.pid, zip_output(state.text_buffer))
      end
    end)

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

    state =
      if length(state.undelivered_events) != 0 do
        Map.values(updated_subscribers)
        |> Enum.each(fn subscriber ->
          GenServer.cast(subscriber.pid, zip_output(state.undelivered_events))
        end)

        %{state | undelivered_events: []}
      else
        state
      end

    Logger.debug("Finished subscription request from: #{inspect(process)}")

    {:reply, :ok, %{state | subscribers: updated_subscribers}}
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
    GenServer.cast(self(), %Mud.Engine.Message.Output{
      id: UUID.uuid4(),
      to: state.character_id,
      text:
        "{{warning}}***** YOU HAVE BEEN IDLE FOR 10 MINUTES AND WILL BE DISCONNECTED SOON *****{{/warning}}"
    })

    state = update_timeout(state, @character_inactivity_timeout_final)

    {:noreply, %{state | inactivity_timer_type: :final}}
  end

  def handle_info(:inactivity_timeout, state = %{inactivity_timer_type: :final}) do
    GenServer.cast(self(), %Mud.Engine.Message.Output{
      id: UUID.uuid4(),
      to: state.character_id,
      text:
        "{{error}}***** YOU HAVE BEEN IDLE TOO LONG AND ARE BEING DISCONNECTED *****{{/error}}"
    })

    GenServer.cast(self(), %Mud.Engine.Message.Input{
      id: UUID.uuid4(),
      to: state.character_id,
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
    Mud.Engine.Command.Quit.do_ingame_stuff(state)

    persist_state(state)
  end

  #
  #
  # Private functions
  #
  #

  defp persist_state(state) do
    state =
      state
      |> Map.put(:is_continuation, false)
      |> Map.put(:continuation_data, nil)
      |> Map.put(:continuation_module, nil)
      |> Map.put(:continuation_type, nil)

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
      |> send_input_for_processing(state)

    %{state | input_processing_task: input_processing_task}
  end

  defp send_input_for_processing(input, state) do
    session_pid = self()

    # send stuff off to task
    task =
      Task.async(fn ->
        if input.type == :normal do
          GenServer.cast(session_pid, %Mud.Engine.Message.Output{
            id: input.id,
            to: input.to,
            text: "<span id=\"#{input.id}-echo\">{{echo}}> #{input.text}{{/echo}}</span>"
          })
        end

        execution_context =
          Mud.Engine.Command.execute(%Mud.Engine.Command.Context{
            id: input.id,
            character_id: input.to,
            input: input.text,
            continuation_data: state.continuation_data,
            is_continuation: state.is_continuation,
            continuation_module: state.continuation_module,
            continuation_type: state.continuation_type
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
          "<p id=\"#{output.id}\" class=\"whitespace-pre-wrap\">#{output.text}</p>"
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
      messages_to_trim = @character_context_buffer_max_size - @character_context_buffer_trim_size

      Enum.reverse_slice(text_buffer, 0, messages_to_trim)
    else
      text_buffer
    end
  end

  defp update_timeout(state, timeout) do
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
end
