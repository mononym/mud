defmodule Mud.Engine.System.Time do
  use GenServer

  alias Mud.Engine.Event.Client.UpdateTime
  alias Mud.Engine.Message

  defmodule State do
    @moduledoc false
    use TypedStruct

    typedstruct do
      field(:time_at_last_check, DateTime)
    end
  end

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
    {:ok, %State{}, 60_000}
  end

  @impl true
  def handle_info(:timeout, state) do
    now = DateTime.utc_now()
    minutes_into_day = Integer.mod(now.hour * 60 + now.minute, 288)
    hours_into_day = minutes_into_day / 60 * 5

    time_update =
      UpdateTime.new(%{
        action: "update",
        hour: Float.round(hours_into_day, 2),
        time_string: string_from_hour(hours_into_day)
      })

    event = Mud.Engine.Event.new("", time_update)

    Mud.Engine.Session.send_event_to_all_active_characters(event)

    result = maybe_send_messages(state.time_at_last_check, hours_into_day)

    if not is_nil(result) do
      Mud.Engine.Session.send_event_to_all_active_characters(
        Message.new_story_output([""], result, "system_info")
      )
    end

    {:noreply, %{state | time_at_last_check: hours_into_day}, 60_000}
  end

  defp maybe_send_messages(previous_time, now) do
    cond do
      previous_time <= 3 and now > 3 -> distantly_approaching_dawn_string()
      previous_time <= 4 and now > 4 -> approaching_dawn_string()
      previous_time <= 5 and now > 5 -> dawn_string()
      previous_time <= 5.5 and now > 5.5 -> approaching_sunrise_string()
      previous_time <= 6 and now > 6 -> sunrise_string()
      previous_time <= 6.25 and now > 6.25 -> after_sunrise_string()
      previous_time <= 8 and now > 8 -> higher_sun_morning_string()
      previous_time <= 10 and now > 10 -> sun_approaching_midday_string()
      previous_time <= 11.5 and now > 11.5 -> midday_sun_string()
      previous_time <= 13 and now > 13 -> early_afternoon_sun_string()
      previous_time <= 15 and now > 15 -> mid_afternoon_sun_string()
      previous_time <= 16 and now > 16 -> late_afternoon_sun_string()
      previous_time <= 17.5 and now > 17.5 -> approaching_sunset_string()
      previous_time <= 18 and now > 18 -> sunset_string()
      previous_time <= 18.25 and now > 18.25 -> after_sunset_string()
      previous_time <= 19 and now > 19 -> dusk_string()
      previous_time <= 20 and now > 20 -> early_night_string()
      previous_time <= 21 and now > 21 -> total_night_string()
      true -> nil
    end
  end

  defp distantly_approaching_dawn_string() do
    "The deep black of the night sky begins to lighten imperceptably as the Sun begins another journey around the planet."
  end

  defp approaching_dawn_string() do
    "Still too dark to be considered morning, the sky is a noticbly lighter shade, heralding the approach of the warmth of day."
  end

  defp dawn_string() do
    "The dark of night begins to give way to the light of day as the morning wears on towards sunrise."
  end

  defp approaching_sunrise_string() do
    "The sky rapidly brightens as the Sun approaches the horizon from below, marking the beginning of a new day."
  end

  defp sunrise_string() do
    "The firey star rising above the horizon baths the land in fresh, warm, sunlight"
  end

  defp after_sunrise_string() do
    "The sky continues to brighten as the Sun climbs above the horizon."
  end

  defp higher_sun_morning_string() do
    "The bright disk of the Sun rapidly retreats away from the horizon."
  end

  defp sun_approaching_midday_string() do
    "The Sun continues to climb slowly as it approaches its high point."
  end

  defp midday_sun_string() do
    "The Sun reaches its Zenith, marking the middle of the day."
  end

  defp early_afternoon_sun_string() do
    "Still high in the sky, the Sun barely appears to have moved."
  end

  defp mid_afternoon_sun_string() do
    "The Sun begins to move away from its Zenith as the middle of the day continues to fade away."
  end

  defp late_afternoon_sun_string() do
    "As the day marches on the Sun begins to lower noticably in the sky."
  end

  defp approaching_sunset_string() do
    "The sun dips low in the sky, the bottom of the brightly burning disk nearing the horizon."
  end

  defp sunset_string() do
    "The bright disk of the Sun begins to dip below the horizon as day begins to give way to night."
  end

  defp after_sunset_string() do
    "Twilight sets in as the Sun fully settles below the horizon, the brightest stars and planets beginning to shine through the pale atmosphere."
  end

  defp dusk_string() do
    "The sky darkens considerably as the Sun continues to slide further below the horizon, barely recognizable as twilight."
  end

  defp early_night_string() do
    "The dying light of the Sun, itself now far below the horizon, is now barely enough to lighten the night sky."
  end

  defp total_night_string() do
    "The last of the Sun's light fades away as it retreats further below the horizon."
  end

  @impl true
  def handle_cast({:push, element}, state) do
    {:noreply, [element | state]}
  end

  defp string_from_hour(hour) do
    cond do
      hour >= 0.5 and hour < 1 -> "Just After Midnight"
      hour >= 1 and hour < 2 -> "After Midnight"
      hour >= 2 and hour < 3 -> "Well After Midnight"
      hour >= 3 and hour < 4 -> "Well Before Dawn"
      hour >= 4 and hour < 5 -> "Just Before Dawn"
      hour >= 5 and hour < 6 -> "Dawn"
      hour >= 6 and hour < 6.25 -> "Sunrise"
      hour >= 6.25 and hour < 7.5 -> "Early Morning"
      hour >= 7.5 and hour < 9 -> "Mid Morning"
      hour >= 9 and hour < 10 -> "Late Morning"
      hour >= 10 and hour < 11.5 -> "Almost Midday"
      hour >= 11.5 and hour < 12.5 -> "Midday"
      hour >= 12.5 and hour < 14 -> "Early Afternoon"
      hour >= 14 and hour < 15 -> "Mid Afternoon"
      hour >= 15 and hour < 16 -> "Late Afternoon"
      hour >= 16 and hour < 17 -> "Well Before Sunset"
      hour >= 17 and hour < 18 -> "Just Before Sunset"
      hour >= 18 and hour < 18.25 -> "Sunset"
      hour >= 18.25 and hour < 19 -> "Just After Sunset"
      hour >= 19 and hour < 19.5 -> "Well Before Dusk"
      hour >= 19.5 and hour < 20 -> "Just Before Dusk"
      hour >= 20 and hour < 20.5 -> "Dusk"
      hour >= 20.5 and hour < 22 -> "Night"
      hour >= 22 and hour < 23 -> "Well Before Midnight"
      hour >= 23 and hour < 23.5 -> "Just Before Midnight"
      (hour >= 23.5 and hour <= 24) or (hour >= 0 and hour < 0.5) -> "Midnight"
    end
  end
end
