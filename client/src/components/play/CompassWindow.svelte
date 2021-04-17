<script>
  import { getContext } from "svelte";
  import { key } from "./state";
  const state = getContext(key);
  const { selectedCharacter } = state;
  import CompassButton from "./CompassButton.svelte";
</script>

<div
  class="compassWindow h-full w-full grid grid-cols-4 grid-rows-12 ga"
  style="background-color:{$selectedCharacter.settings.directionsWindow[
    'background_color'
  ]}"
>
  <CompassButton
    rowSpan="3"
    icon="fas fa-arrow-up rotate-315"
    exit="northwest"
  />
  <CompassButton rowSpan="3" icon="fas fa-arrow-up" exit="north" />
  <CompassButton
    rowSpan="3"
    icon="fas fa-arrow-up rotate-45"
    exit="northeast"
  />
  <CompassButton rowSpan="6" icon="fas fa-arrow-from-bottom" exit="up" />
  <CompassButton rowSpan="6" icon="fas fa-arrow-up rotate-270" exit="west" />

  <CompassButton rowSpan="6" icon="fas fa-sign-out" exit="out" />

  <CompassButton rowSpan="6" icon="fas fa-arrow-up rotate-90" exit="east" />
  <CompassButton rowSpan="6" icon="fas fa-arrow-from-top" exit="down" />
  <CompassButton
    rowSpan="3"
    icon="fas fa-arrow-up rotate-225"
    exit="southwest"
  />
  <CompassButton rowSpan="3" icon="fas fa-arrow-up rotate-180" exit="south" />
  <CompassButton
    rowSpan="3"
    icon="fas fa-arrow-up rotate-135"
    exit="southeast"
  />
</div>
