defmodule Mud.StoreManager do
  @moduledoc """
  This genserver manages the incoming webhook events from the store an acts on them.

  In general this means fulfilling orders and marking them as such in the store.
  """
  use GenServer

  alias Mud.Engine.Event.Client.UpdateTime
  alias Mud.Engine.Message
  alias Mud.Account.Player
  alias Mud.Account.Purchases
  alias Mud.Repo

  require Logger

  @store_id 62_200_074

  defmodule State do
    @moduledoc false
    use TypedStruct

    typedstruct do
      field(:private_token, String.t())
      field(:public_token, String.t())
      field(:client_secret, String.t())
      field(:order_queue, [:tuple], default: [])
      field(:store_task, term())
    end
  end

  #
  # API
  #

  def handle_webhook(signature, data) do
    GenServer.cast(__MODULE__, {:webhook, {signature, data}})
  end

  #
  # Worker callback used by the supervisor when starting the store manager system.
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
    {:ok, %State{}, {:continue, :get_token}}
  end

  @impl true
  def handle_continue(:get_token, state) do
    ecwid_config = Application.get_env(:mud, :ecwid)

    {:noreply,
     %{
       state
       | client_secret: ecwid_config[:client_secret],
         private_token: ecwid_config[:private_token],
         public_token: ecwid_config[:public_token]
     }}
  end

  @impl true
  def handle_cast({:webhook, {signature, data}}, state) do
    Logger.info("Starting processing of store event from webhook", event_id: data["eventId"])

    if data["eventType"] == "order.created" and
         Mud.Ecwid.is_webhook_sig_valid?(
           data["eventCreated"],
           data["eventId"],
           signature,
           state.client_secret
         ) do
      state = %{state | order_queue: state.order_queue ++ [data["data"]]}

      state = maybe_process_order(state)

      {:noreply, state}
    else
      {:noreply, state}
    end
  end

  # The task completed successfully
  def handle_info({ref, _answer}, %{store_task: ref} = state) do
    state = %{state | store_task: nil}
    state = maybe_process_order(state)

    {:noreply, state}
  end

  # The task failed
  def handle_info({:DOWN, ref, :process, _pid, _reason}, %{ref: ref} = state) do
    {:noreply, %{state | ref: nil}}
  end

  # The task failed
  def handle_info({:DOWN, _ref, :process, _pid, _reason}, state) do
    {:noreply, state}
  end

  defp maybe_process_order(state) do
    # something in the queue and nothing is executing
    if is_nil(state.store_task) and state.order_queue != [] do
      [order | queue] = state.order_queue

      new_task =
        Task.Supervisor.async_nolink(Mud.TaskSupervisor, fn ->
          # read the order state from the store
          # if the order is not fulfilled, fulfill it and then mark as fulfilled
          order_id = order["orderId"]

          url =
            "https://app.ecwid.com/api/v3/#{@store_id}/orders/#{order_id}?token=#{state.private_token}"

          response = HTTPoison.get!(url)
          response = Poison.decode!(response.body)

          if response["paymentStatus"] == "PAID" and response["fulfillmentStatus"] != "DELIVERED" do
            # fulfill the actual order, which right now will either be crowns or gift card, if gift card ignore
            Enum.all?(response["items"], fn item ->
              if String.contains?(item["sku"], "crowns") do
                [string_count, "crowns"] = String.split(item["sku"], "_")
                count = String.to_integer(string_count)

                case Player.get_by_email(response["email"]) do
                  {:ok, player} ->
                    player.purchases
                    |> Purchases.update(%{
                      crowns: player.purchases.crowns + count * item["quantity"]
                    })
                    |> Repo.update!()

                    true

                  error ->
                    order_no = response["id"]
                    item_no = item["id"]

                    Logger.error(
                      "Error processing item with id #{item_no} in order with id #{order_no}: #{inspect(error)}"
                    )

                    false
                end
              else
                false
              end
            end)
            |> if do
              # update the order in the store
              body = %{"fulfillmentStatus" => "DELIVERED"} |> Jason.encode!()

              headers = [{"Content-type", "application/json"}]
              response = HTTPoison.put!(url, body, headers) |> IO.inspect(label: :update_response)
            end
          end
        end)

      %{state | order_queue: queue, store_task: new_task.ref}
    else
      state
    end
  end
end
