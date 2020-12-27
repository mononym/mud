<script language="ts">
  import { beforeUpdate, onMount, onDestroy, afterUpdate, tick } from "svelte";
  import interact from "interactjs";
  import { interactable } from "../../../../utils/interactable";
  const storage = require("electron-json-storage");

  let isLocked;
  let layoutItemWrapper;

  export let locked = true;
  export let x = "0";
  export let y = "0";
  export let width = 400;
  export let height = 400;
  export let id;
  export let label = "";

  let localX = "0";
  let localY = "0";
  let localHeight = 400;
  let localWidth = 400;
  let localIsLocked = true;

  let initialized = false;

  // $: localX, flow;
  // $: localY, flow;

  // async function flow() {
  //   await tick();
  //   const interactable = interact(layoutItemWrapper);
  //   const drag = { name: "drag", axis: "xy" };

  //   interactable.reflow(drag);
  // }

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

            // if (data.width > 10 && data.height > 10) {
            //   width = data.width;
            //   height = data.height;
            // }

            layoutItemWrapper.dataset.x = localX = data.x;
            layoutItemWrapper.dataset.y = localY = data.y;
            localHeight = data.height;
            localWidth = data.width;
            localIsLocked = data.locked || false;

            const interactable = interact(layoutItemWrapper);

            const drag = { name: "drag", axis: "xy" };
            const resize = {
              name: "resize",
              edges: { left: true, bottom: true },
            };

            interactable.reflow(drag);
            interactable.reflow(resize);
          });
        } else {
          layoutItemWrapper.dataset.x = localX = x;
          layoutItemWrapper.dataset.y = localY = y;
          localHeight = height;
          localWidth = width;
          localIsLocked = locked;

          const interactable = interact(layoutItemWrapper);

          const drag = { name: "drag", axis: "xy" };
          const resize = {
            name: "resize",
            edges: { left: true, bottom: true },
          };

          interactable.reflow(drag);
          interactable.reflow(resize);
        }
      });

      initialized = true;
    }
  });

  onMount(() => {
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

    storage.set(
      id,
      {
        width: layoutItemWrapper.clientWidth,
        height: layoutItemWrapper.clientHeight,
        x: layoutItemWrapper.dataset.x,
        y: layoutItemWrapper.dataset.y,
        locked: localIsLocked,
      },
      function (error) {
        if (error) throw error;
      }
    );
  }

  function toggleLocked() {
    localIsLocked = !localIsLocked;

    interact(layoutItemWrapper)
      .draggable(!localIsLocked)
      .resizable(!localIsLocked);

    if (localIsLocked) {
      saveData();
    }
  }
</script>

<div
  bind:this={layoutItemWrapper}
  class="layoutItemWrapper flex flex-col absolute bg-gray-700"
  style="height:{localHeight}px;width:{localWidth}px;touch-action:none">
  <div class="flex-shrink h-8 bg-gray-900 grid grid-cols-3">
    <div class="flex items-center">
      <i
        on:click={toggleLocked}
        class="pl-2 fas fa-{localIsLocked ? 'lock text-green-200' : 'unlock text-red-300'} cursor-pointer" />
      <i
        class="drag-handle text-{localIsLocked ? 'gray-500 cursor-not-allowed' : 'green-200 cursor-move'} pl-2 fas fa-arrows-alt" />
    </div>
    <span class="text-white place-self-center">{label}</span>
  </div>
  <div class="flex-1 overflow-hidden">
    <slot />
  </div>
</div>
