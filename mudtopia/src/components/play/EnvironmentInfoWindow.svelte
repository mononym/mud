<script>
  import { getContext } from "svelte";
  import { key } from "./state";
  // import CompassButton from "./CompassButton.svelte";

  const timeIconBaseRotationToMidnight = -144; // degrees

  const state = getContext(key);
  const { worldHourOfDay, worldTimeString } = state;

  $: finalTransformDegrees =
    timeIconBaseRotationToMidnight + ($worldHourOfDay / 24) * 360;
</script>

<div
  style="background-color:#28282D"
  class="environmentInfo h-full w-full flex flex-col place-content-center items-center"
>
  <p class="text-center text-white">{$worldTimeString}</p>
  <!-- <i class="fa-fw fa-3x fas fa-sunrise" /> -->
  <img
    src="day_and_night.svg"
    alt="time of day"
    width="75"
    height="75"
    style="transform:rotate({finalTransformDegrees}deg);"
  />
</div>
