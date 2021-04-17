<script>
  import { getContext, onMount } from "svelte";
  import { key } from "./state";

  import tippy from "tippy.js";
  import "tippy.js/dist/tippy.css";

  export let icon;
  export let rowSpan = 2;
  export let exit = "";

  const green = "#a7f3d0";
  const red = "#fca5a5";

  const state = getContext(key);
  const { channel, exitsInArea, selectedCharacter } = state;

  $: $exitsInArea, exitInArea();

  let buttonActive = false;
  function exitInArea() {
    var found = false;
    for (var i = 0; i < $exitsInArea.length; i++) {
      if ($exitsInArea[i].shortDescription == exit) {
        found = true;
        break;
      }
    }

    buttonActive = found;
  }

  function move() {
    console.log(`move ${exit}`);
    $channel.push("cli", { text: `move ${exit}` });
  }

  onMount(() => {
    tippy("[data-tippy-content]");
  });
</script>

<button
  on:click={move}
  data-tippy-content={exit}
  style="background-color:{buttonActive
    ? $selectedCharacter.settings.directionsWindow[
        'active_direction_background_color'
      ]
    : $selectedCharacter.settings.directionsWindow[
        'inactive_direction_background_color'
      ]};color:{buttonActive
    ? $selectedCharacter.settings.directionsWindow[
        'active_direction_icon_color'
      ]
    : $selectedCharacter.settings.directionsWindow[
        'inactive_direction_icon_color'
      ]}"
  class="row-span-{rowSpan} flex-1 m-px place-items-center"
  ><i class="fa-fw {icon}" /></button
>

<style>
  .rotate-315 {
    transform: rotate(315deg);
  }

  .rotate-45 {
    transform: rotate(45deg);
  }

  .rotate-90 {
    transform: rotate(90deg);
  }

  .rotate-135 {
    transform: rotate(135deg);
  }

  .rotate-180 {
    transform: rotate(180deg);
  }

  .rotate-225 {
    transform: rotate(225deg);
  }

  .rotate-270 {
    transform: rotate(270deg);
  }
</style>
