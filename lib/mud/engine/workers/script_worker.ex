defmodule Mud.Engine.Worker.ScriptWorker do
  @moduledoc false

  alias Mud.Engine.Script
  alias Mud.Engine.Script.Context
  import Mud.Engine.Script.Context
  alias Mud.Engine.ScriptData
  alias Mud.Engine.Util
  require Logger
  use GenServer

  @typedoc "Arguments passed through to a callback module."
  @type args :: term

  @typedoc "A message passed through to a callback module."
  @type message :: term

  @typedoc "A reply passed through to the caller."
  @type reply :: term

  @typedoc "An error message passed through to the caller."
  @type error :: term

  @typedoc "A response from the ScriptWorker or the callback module."
  @type response :: term

  @typedoc "The reason the Script is stopping."
  @type reason :: term

  @typedoc "State used by the callback module."
  @type state :: term

  @typedoc "A child spec for starting a process under a Supervisor."
  @type child_spec :: term

  @typedoc "a :via tuple allowing for Systems and Scripts to be registered seperately."
  @type registered_name :: term

  @typedoc "The callback_module that is the implementation of the Script logic."
  @type callback_module :: atom

  @typedoc "Each script has a key which, when combined witn an ID, is what is used as the PK"
  @type key :: String.t()

  @type thing ::
          Mud.Engine.Area.t()
          | Mud.Engine.Character.t()
          | Mud.Engine.Item.t()
          | Mud.Engine.Link.t()
          | Mud.Engine.Region.t()

  @type context :: Mud.Engine.Script.Context.t()

  #
  # Worker callback used by the supervisor when starting a new Script Runner.
  #

  @doc false
  @spec child_spec(args :: term) :: child_spec
  def child_spec(args) do

    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [args]},
      restart: :transient,
      shutdown: 1000,
      type: :worker
    }
  end

  @doc false
  @spec start_link(context) :: :ok | {:error, :already_started}
  def start_link(context) do
    registered_name = Script.gen_server_id(context.thing, context.key)

    case GenServer.start_link(__MODULE__, context, name: registered_name) do
      {:error, {:already_started, _pid}} -> {:error, :already_started}
      result -> result
    end
  end

  #
  # Initialization of the GenServer and the script it is managing.
  #

  @doc false
  @spec init(context) :: {:ok, state} | {:stop, error}
  def init(context) do

    if context.initialized do
      {:ok, context, {:continue, :run}}
    else
      with {:ok, context} <- load_state(context) do
        context
        |> transaction(fn context ->
          apply(context.callback_module, :start, [context])
        end)
        |> case do
          {:ok, context} ->
            context = clear_args(context)

            {:ok, context, {:continue, :run}}

          {:error, error} ->
            {:stop, error}
        end
      else
        {:error, error} -> {:stop, error}
      end
    end
  end

  defp load_state(context) do
    case ScriptData.get(context.thing, context.key) do
      {:ok, script} ->

        {:ok,
         %Context{
           key: script.key,
           callback_module: script.callback_module,
           state: script.state,
           thing: context.thing
         }}

      error ->
        error
    end
  end

  defp process_transaction_result(result, context) do

    case result do
      {:ok, context = %Context{halt: false}} ->
        ref = Process.send_after(self(), :run, context.next_iteration)
        context = %{context | timer_ref: ref}
        context = process(context)

        cond do
          not is_nil(context.response) ->
            {:reply, context.response, clear_response(context)}

          is_nil(context.response) ->
            {:noreply, context}
        end

      {:ok, context = %Context{halt: true}} ->
        context = process(context)

        if not context.detach do
          persist(context)
        else
          ScriptData.purge(context.thing, context.key)
        end

        cond do
          not is_nil(context.response) ->
            {:stop, :normal, context.response, clear_response(context)}

          is_nil(context.response) ->
            {:stop, :normal, context}
        end

      {:error, error} ->
        {:stop, error, context}
    end
  end

  defp process(context) do
    context
    |> process_events()
    |> process_messages()
  end

  @doc false
  @spec handle_call(:run, from :: term, context) :: {:reply, :ok, context}
  def handle_call(:run, _from, context) do
    if is_reference(context.timer_ref) do
      Process.cancel_timer(context.timer_ref)
    end

    {:reply, :ok, context, {:continue, :run}}
  end

  @doc false
  @spec handle_call({:message, message}, from :: term, context) ::
          {:reply, {:ok, response}, context} | {:reply, {:error, error}, context}
  def handle_call({:message, message}, _from, context) do
    transaction(context, fn context ->
      apply(context.callback_module, :handle_message, [
        context.thing,
        message,
        context.state
      ])
    end)
    |> process_transaction_result(context)
  end

  @doc false
  @spec handle_call(:state, from :: term, context) :: {:reply, {:ok, response}, context}
  def handle_call(:state, _from, context) do
    {:reply, {:ok, context.state}, context}
  end

  @doc false
  @spec handle_call(:running, from :: term, context) :: {:reply, true, context}
  def handle_call(:running, _from, context) do
    {:reply, true, context}
  end

  @doc false
  @spec handle_call({:stop, args}, from :: term, context) ::
          {:reply, :ok, context} | {:reply, {:error, error}, context}
  def handle_call({:stop, args}, _from, context) do
    if is_reference(context.timer_ref) do
      Process.cancel_timer(context.timer_ref)
    end

    {:ok, context} =
      transaction(context, fn context ->
        apply(context.callback_module, :stop, [context, :call, args])
        |> persist()
      end)

    {:stop, :normal, :ok, context}
  end

  @doc false
  @spec handle_cast({:message, message}, context) :: {:noreply, context}
  def handle_cast({:message, message}, context) do
    context
    |> put_args(message)
    |> transaction(fn context ->
      apply(context.callback_module, :handle_message, [
        context,
        message
      ])
    end)
    |> case do
      {:ok, context} ->
        {:noreply, clear_args(context)}

      {:error, error} ->
        {:stop, error, context}
    end
  end

  @doc false
  @spec handle_continue(:run, context) :: {:noreply, context} | {:stop, :normal, context}
  def handle_continue(:run, context) do
    context = %{context | timer_ref: nil}

    refreshed_thing = Util.refresh_thing(context.thing)
    context = %{context | thing: refreshed_thing}

    transaction(context, fn context ->
      apply(context.callback_module, :run, [context])
    end)
    |> process_transaction_result(context)
  end

  #
  # Private Functions
  #

  @spec persist(context) :: context
  defp persist(context) do
    {:ok, state} = ScriptData.update(context.thing, context.key, context.state)

    %{context | state: state}
  end

  defp process_events(context) do
    Enum.each(context.events, fn event ->
      Mud.Engine.Session.cast_message_or_event(event)
    end)

    clear_events(context)
  end

  defp process_messages(context) do
    Enum.each(context.messages, fn message ->
      Mud.Engine.Session.cast_message_or_event(message)
    end)

    clear_messages(context)
  end

  defp transaction(context, function) do

    Mud.Util.retryable_transaction_v2(fn ->
      thing = Util.refresh_thing(context.thing)
      context = %{context | thing: thing}

      function.(context)
    end)
  end
end
