<script>
  import { getContext } from "svelte";
  import { key } from "./state";

  const timeIconBaseRotationToMidnight = -144; // degrees

  const state = getContext(key);
  const { worldHourOfDay, worldTimeString, selectedCharacter } = state;

  $: finalTransformDegrees =
    timeIconBaseRotationToMidnight + ($worldHourOfDay / 24) * 360;
</script>

<div
  style="background-color:{$selectedCharacter.settings.environmentWindow[
    'background_color'
  ]}"
  class="environmentInfo h-full w-full flex flex-col place-content-center items-center"
>
  <p
    style="color:{$selectedCharacter.settings.environmentWindow[
      'time_text_color'
    ]}"
    class="text-center"
  >
    {$worldTimeString}
  </p>
  <img
    src="day_and_night.svg"
    alt="time of day"
    width="75"
    height="75"
    style="transform:rotate({finalTransformDegrees}deg);"
  />
</div>
