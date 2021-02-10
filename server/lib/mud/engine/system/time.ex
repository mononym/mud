defmodule Mud.Engine.System.Time do
  use GenServer

  #
  # Worker callback used by the supervisor when starting a new Time system.
  #

  @doc false
  @spec start_link(term) :: :ok | {:error, :already_started}
  def start_link(context) do
    case GenServer.start_link(__MODULE__, context, name: __MODULE__) do
      {:error, {:already_started, _pid}} ->
        {:error, :already_started}

      result ->
        result
    end
  end

  @doc false
  def child_spec(args) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [args]},
      restart: :permanent,
      shutdown: 5000,
      type: :worker
    }
  end

  # Callbacks

  @impl true
  def init(_) do
    {:ok, %{}, 6_000}
  end

  @impl true
  def handle_info(:timeout, state) do
    DateTime.utc_now()
    {:noreply, state}
  end

  @impl true
  def handle_cast({:push, element}, state) do
    {:noreply, [element | state]}
  end
end
