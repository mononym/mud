defmodule Mud.Engine.Script do
  @moduledoc """
  Scripts perform repeated logic on Objects within the game world.

  Examples include a character slowly drying off, a wound draining vitality, an opened door automatically closing, and
  so on. They can control longer running logic such as AI behaviors that are meant to remain on the Object permanently,
  and shorter one off tasks where the script will be removed after a single run.

  While Scripts are attached to a single Object, there is no restriction on the data a Script can modify. It is up to
  the implementor to play nice with the rest of the system.

  While each Script instance has its own state, please note that this state is only for that data which helps the Script
  itself run, and should not be used to store any data expected to be used/accessed by any other entity within the
  system.
  """

  alias Mud.Engine.{Area, Character, Item, Link}
  alias Mud.Engine.Util
  alias Mud.Engine.Script.Context
  alias Mud.Engine.ScriptData
  alias Mud.Engine.Worker.ScriptWorker
  alias Mud.Engine.ScriptSupervisor
  require(Logger)

  @typedoc "Arguments passed through to a callback module."
  @type args :: term

  @typedoc "A message passed through to a callback module."
  @type message :: term

  @typedoc "How many milliseconds should pass until the run callback is called again."
  @type next_iteration :: integer

  @typedoc "A reply passed through to the caller."
  @type reply :: term

  @typedoc "An error message passed through to the caller."
  @type error :: term

  @typedoc "The reason the Script is stopping."
  @type reason :: term

  @typedoc "State used by the callback module."
  @type state :: term

  @type thing ::
          Mud.Engine.Area.t()
          | Mud.Engine.Character.t()
          | Mud.Engine.Item.t()
          | Mud.Engine.Link.t()
          | Mud.Engine.Region.t()

  @typedoc "Each script has a key which, when combined witn an ID, is what is used as the PK"
  @type key :: String.t()

  @typedoc "Type of thing the Script is being attached to. Area/character/item/link"
  @type thing_type :: String.t()

  @typedoc "The callback_module that is the implementation of the Script logic."
  @type callback_module :: atom

  @script_registry :scripts

  #
  # Manipulation of a single Script
  #

  @doc """
  Attach a Script to an Area/Character/Item/Link.

  Attaching a script starts it immediately.
  """
  @spec attach(thing, key, callback_module, args | nil) ::
          :ok | {:error, term() | :already_attached}
  def attach(thing, key, callback_module, args \\ nil) do
    if exists?(thing, key) do
      Logger.debug("exists")
      {:error, :already_attached}
    else
      Logger.debug("doesn't exist")
      context = %Context{key: key, callback_module: callback_module, thing: thing, args: args}
      context = apply(callback_module, :initialize, [context])

      if is_nil(context.error) do
        Logger.debug("successfully initialized")

        do_start(%Context{
          key: key,
          callback_module: callback_module,
          state: context.state,
          thing: thing
        })

        :ok
      else
        {:error, context.error}
      end
    end
  end

  defp exists?(thing, key) do
    ScriptData.exists?(thing, key)
  end

  def thing_to_id_key(%Character{}) do
    :character_id
  end

  def thing_to_id_key(%Item{}) do
    :item_id
  end

  def thing_to_id_key(%Link{}) do
    :ink_id
  end

  def thing_to_id_key(%Area{}) do
    :area_id
  end

  @doc """
  Call a running Script with a message.
  """
  @spec call(thing, key, message) :: {:ok, reply}
  def call(thing, key, message) do
    send_message(:call, thing, key, {:message, message})
  end

  @doc """
  Call a running Script with a message, or use that message as the argument for starting that Script on that Object.
  """
  @spec call_or_start(thing, key, message) ::
          :ok | {:ok, term} | {:error, :no_such_script}
  def call_or_start(thing, key, message) do
    case send_message(:call, thing, key, {:message, message}) do
      {:error, _} ->
        start(thing, key, message)

      ok_result ->
        ok_result
    end
  end

  @doc """
  Cast a message to a running Script.
  """
  @spec cast(thing, key, message) :: :ok
  def cast(thing, key, message) do
    send_message(:cast, thing, key, {:message, message})
  end

  @doc """
  Detach a Script from an Object.

  This method first stops the Script if it is running before moving on to removing the Script from the database. It is
  also destructive, with the state of the Script being destroyed at the time of removal.
  """
  def detach(thing, key) do
    stop(thing, key)
    purge(thing, key)
  end

  @doc """
  Get the state of a Script.

  First the running Script will be queried for the state, and then the database. Only if both fail to return a result is
  an error returned.
  """
  @spec get_state(thing, key) :: {:ok, term} | {:error, :no_such_script}
  def get_state(thing, key) do
    try do
      GenServer.call(gen_server_id(thing, key), :state, :infinity)
    catch
      :exit, {:noproc, _} ->
        ScriptData.get(thing, key)
    end
  end

  @doc """
  Check to see if a Script is attached to an Object.
  """
  @spec is_attached?(thing, key) :: boolean
  def is_attached?(thing, key) do
    ScriptData.exists?(thing, key)
  end

  @doc """
  Purge Script data from the database.

  This method does not check for a running Script, or in any way ensure that the data can't or won't be rewritten.
  It is a dumb delete.
  """
  @spec purge(thing, key) :: :ok | {:error, :no_such_script}
  def purge(thing, key) do
    ScriptData.purge(thing, key)
  end

  @doc """
  Trigger a Script to run immediately. If a Script is running while this call is made the Script will run again as soon
  as it can.

  This method ensures that the Script is active and that it will begin the process of running its main loop immediately,
  but offers no other guarantees.
  """
  @spec run(thing, key) :: :ok | {:error, :no_such_script}
  def run(thing, key) do
    send_message(:call, thing, key, :run)
  end

  @doc """
  Check to see if a Script is running on an Object.

  This method is not for checking if the Script is running its main loop at that moment, but to check if it is still
  active or if it is currently stopped. If there is no Script running matching the provided parameters, it does not
  check the database to validate that such a Script actively exists. To check if an Object has a Script attached to it,
  see the 'has?/2' method.
  """
  @spec running?(thing, key) :: boolean
  def running?(thing, key) do
    send_message(:call, thing, key, :running) == true
  end

  @doc """
  Start a specific Script on an Object. The Script must already be attached.
  """
  @spec start(thing, key, args | nil) :: :ok | {:error, :no_such_script}
  def start(thing, key, start_args \\ nil) do
    do_start(%Context{key: key, thing: thing, args: start_args})
  end

  defp do_start(context) do
    with {:ok, _} <-
           DynamicSupervisor.start_child(ScriptSupervisor, {ScriptWorker, context}) do
      :ok
    end
  end

  @doc """
  Start all Scripts on an Object. Will only start attached Scripts.
  """
  @spec start_all(thing, args) ::
          {:ok, %{required(module()) => :ok | {:error, :already_started}}}
          | {:error, :no_scripts_attached}
  def start_all(thing, start_args \\ nil) do
    ScriptData.list_all_on_thing(thing)
    |> case do
      [] ->
        {:error, :no_scripts_attached}

      scripts ->
        Enum.reduce(scripts, %{}, fn script, map ->
          Map.put(map, script.key, start(thing, script.key, start_args))
        end)
    end
  end

  @doc """
  Stops a Script if it is started.
  """
  @spec stop(thing, key) :: :ok | {:error, :no_such_script}
  def stop(thing, key) do
    case Registry.lookup(@script_registry, gen_server_key(thing, key)) do
      [{pid, _}] ->
        ref = Process.monitor(pid)
        GenServer.stop(pid, :normal)

        receive do
          {:DOWN, ^ref, :process, ^pid, :normal} ->
            :ok
        end

      _ ->
        {:error, :no_such_script}
    end
  end

  #
  # Internal Functions
  #

  @spec send_message(method :: atom, thing, key, message) ::
          :ok | term | {:ok, term} | {:error, :script_not_running}
  defp send_message(method, thing, key, message) do
    try do
      apply(GenServer, method, [
        gen_server_id(thing, key),
        message
      ])
    catch
      :exit, _ -> {:error, :no_such_script}
    end
  end

  def name(thing, key) do
    "#{thing_to_id_key(thing)}:#{thing.id}:#{key}"
  end

  def gen_server_id(thing, key) do
    Util.via(@script_registry, gen_server_key(thing, key))
  end

  defp gen_server_key(thing, key),
    do: {{thing_to_id_key(thing), thing.id}, key}
end
