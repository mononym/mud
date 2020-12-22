<script language="ts">
  import { onMount } from "svelte";
  export let locked = false;
  import interact from 'interactjs'

  let isLocked;
  let layoutItemWrapper;

  export let width = 400
  export let height = 400

  onMount(() => {
    isLocked = locked;
  });

  function toggleLocked() {
    isLocked = !isLocked;

    interact(layoutItemWrapper).draggable(!isLocked).resizable(!isLocked).reflow()
  }
</script>

<div
bind:this={layoutItemWrapper}
  class="layoutItemWrapper flex flex-col absolute bg-gray-700" style="height:{height}px;width:{width}px;"
  data-x="0"
  data-y="0">
  <div class="flex-shrink h-8 bg-gray-900 flex items-center">
    <i
      on:click={toggleLocked}
      class="pl-2 fas fa-{isLocked ? 'lock text-green-200' : 'unlock text-red-300'} cursor-pointer" />
    <i
      class="drag-handle text-{isLocked ? 'gray-500 cursor-not-allowed' : 'green-200 cursor-move'} pl-2 fas fa-arrows-alt" />
  </div>
  <div class="flex-1 overflow-hidden">
    <slot />
  </div>
</div>
