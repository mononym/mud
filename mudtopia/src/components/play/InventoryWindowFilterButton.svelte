<script>
  import tippy from "tippy.js";
  import "tippy.js/dist/tippy.css";
  import { getContext, onMount, tick } from "svelte";
  import { key } from "./state";
  export let icon = "";
  export let active = false;
  export let activeTooltip = "";
  export let inactiveTooltip = "";
  let tippyInstance;
  let buttonDiv;

  const state = getContext(key);
  const { selectedCharacter, saveCharacterSettings } = state;

  $: active, updateTooltip();

  function updateTooltip() {
    if (tippyInstance != undefined) {
      tippyInstance.setContent(active ? activeTooltip : inactiveTooltip);
    }
  }

  onMount(() => {
    tippyInstance = tippy(buttonDiv, {
      content: active ? activeTooltip : inactiveTooltip,
    });
  });

  function toggleActive() {
    active = !active;
    saveCharacterSettings();
  }
</script>

<button
  bind:this={buttonDiv}
  class="InventoryWindowFilterButton py-1 px-1 border-r"
  on:click={toggleActive}>
  <i
    class={icon}
    style="color:{$selectedCharacter.settings.inventoryWindow[
      active ? 'filter_active_icon_color' : 'filter_inactive_icon_color'
    ]}"
  />
</button>
