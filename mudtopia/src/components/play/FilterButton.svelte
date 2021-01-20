<script>
  import tippy from "tippy.js";
  import "tippy.js/dist/tippy.css";
  import { onMount, createEventDispatcher } from "svelte";
  export let icon = "";
  export let active = false;
  export let activeTooltip = "";
  export let inactiveTooltip = "";
  export let activeIconColor = "";
  export let inactiveIconColor = "";
  export let key = "";
  let tippyInstance;
  let buttonDiv;

  const dispatch = createEventDispatcher();

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
    dispatch("toggle", { key: key, active: active });
  }
</script>

<button
  bind:this={buttonDiv}
  class="py-1 px-1 border-r"
  on:click={toggleActive}>
  <i
    class={`fa-fw fa-lg ${icon}`}
    style="color:{active ? activeIconColor : inactiveIconColor}"
  />
</button>
