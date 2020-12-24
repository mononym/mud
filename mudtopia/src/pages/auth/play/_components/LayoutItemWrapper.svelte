<script language="ts">
  import { beforeUpdate, onMount, onDestroy, afterUpdate, tick } from "svelte";
  export let locked = false;
  import interact from "interactjs";
  import { interactable } from "../../../../utils/interactable";
  const storage = require("electron-json-storage");

  let isLocked;
  let layoutItemWrapper;

  export let x = "0";
  export let y = "0";
  export let width = 400;
  export let height = 400;
  export let id;
  export let label = "";

  let initialized = false;

  let reflow = false;

  beforeUpdate(() => {
    if (!initialized) {
      storage.has(id, function (error, hasKey) {
        if (error) throw error;

        if (hasKey) {
          console.log("There is data stored as " + id);
          storage.get(id, function (error, data) {
            if (error) throw error;

            console.log("beforeUpdate: " + id);
            console.log(data);
            if (data.width > 10 && data.height > 10) {
              width = data.width;
              height = data.height;
            }

            // const interactable = interact(layoutItemWrapper);

            x = data.x;
            y = data.y;
            isLocked = data.locked || false;

            reflow = true;

            // await tick();

            // const drag = { name: "drag", axis: "x" };

            // interactable.reflow(drag);
          });
        }
      });
    }

    initialized = true;
  });

  afterUpdate(() => {
    if (reflow) {
      const interactable = interact(layoutItemWrapper);

      const drag = { name: "drag", axis: "x" };

      interactable.reflow(drag);

      reflow = false;
    }
  });

  onMount(() => {
    isLocked = locked;
    interactable(layoutItemWrapper);
  });

  onDestroy(() => {
    saveData();
  });

  function saveData() {
    if (
      layoutItemWrapper.clientWidth == 0 ||
      layoutItemWrapper.clientHeight == 0
    ) {
      return;
    }

    console.log("saving data for key " + id);
    console.log(layoutItemWrapper.dataset);
    console.log(layoutItemWrapper.clientWidth);
    console.log(layoutItemWrapper.clientHeight);
    storage.set(
      id,
      {
        width: layoutItemWrapper.clientWidth,
        height: layoutItemWrapper.clientHeight,
        x: layoutItemWrapper.dataset.x,
        y: layoutItemWrapper.dataset.y,
        locked: isLocked,
      },
      function (error) {
        if (error) throw error;
      }
    );
  }

  function toggleLocked() {
    isLocked = !isLocked;

    interact(layoutItemWrapper).draggable(!isLocked).resizable(!isLocked);

    if (isLocked) {
      saveData();
    }
  }
</script>

<div
  bind:this={layoutItemWrapper}
  class="layoutItemWrapper flex flex-col absolute bg-gray-700"
  style="height:{height}px;width:{width}px;touch-action:none"
  data-x={x}
  data-y={y}>
  <div class="flex-shrink h-8 bg-gray-900 grid grid-cols-3">
    <div class="flex items-center">
      <i
        on:click={toggleLocked}
        class="pl-2 fas fa-{isLocked ? 'lock text-green-200' : 'unlock text-red-300'} cursor-pointer" />
      <i
        class="drag-handle text-{isLocked ? 'gray-500 cursor-not-allowed' : 'green-200 cursor-move'} pl-2 fas fa-arrows-alt" />
    </div>
    <span class="text-white place-self-center">{label}</span>
  </div>
  <div class="flex-1 overflow-hidden">
    <slot />
  </div>
</div>
