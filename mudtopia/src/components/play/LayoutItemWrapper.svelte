<script language="ts">
  import { onMount, onDestroy } from "svelte";
  import interact from "interactjs";
  import { interactable } from "../../utils/interactable";
  const storage = require("electron-json-storage");
  import { getContext } from "svelte";
  import { key } from "./state";

  const state = getContext(key);
  const { selectedCharacter } = state;

  let layoutItemWrapper;

  export let locked = true;
  export let x = "0";
  export let y = "0";
  export let initialWidth = "400";
  export let initialHeight = "400";
  export let initialX = "0";
  export let initialY = "0";
  export let id;
  export let label = "";

  let localX = "0";
  let localY = "0";
  let localHeight = 400;
  let localWidth = 400;
  let localIsLocked = true;

  onMount(() => {
    // if (!initialized) {
    storage.has(`${$selectedCharacter.name}-${id}`, function (error, hasKey) {
      if (error) throw error;

      if (hasKey) {
        storage.get(`${$selectedCharacter.name}-${id}`, function (error, data) {
          if (error) throw error;

          localX = data.x;
          layoutItemWrapper.style.left = `${data.x}px`;
          localY = data.y;
          layoutItemWrapper.style.top = `${data.y}px`;
          localHeight = data.height;
          localWidth = data.width;
          localIsLocked = data.locked || true;
        });
      } else {
        localX = initialX;
        layoutItemWrapper.style.left = `${initialX}px`;
        localY = initialY;
        layoutItemWrapper.style.top = `${initialY}px`;
        localHeight = initialHeight;
        localWidth = initialWidth;
        localIsLocked = locked || true;
      }

      interactable(layoutItemWrapper);

      interact(layoutItemWrapper)
        .draggable(!localIsLocked)
        .resizable(!localIsLocked);
    });
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

    const x = Math.max(
      parseInt(localX) + parseInt(layoutItemWrapper.dataset.x),
      0
    );
    const y = Math.max(
      parseInt(localY) + parseInt(layoutItemWrapper.dataset.y),
      0
    );

    storage.set(
      `${$selectedCharacter.name}-${id}`,
      {
        width: layoutItemWrapper.offsetWidth,
        height: layoutItemWrapper.offsetHeight,
        x: x.toString(),
        y: y.toString(),
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
  style="height:{localHeight}px;width:{localWidth}px;touch-action:none;border-width:1px">
  <div
    style="background-color:{$selectedCharacter.settings.colors.window_toolbar_background}"
    class="flex-shrink h-8 grid grid-cols-3">
    <div class="flex items-center">
      <i
        on:click={toggleLocked}
        style="color:{localIsLocked ? `${$selectedCharacter.settings.colors.window_lock_locked}` : `${$selectedCharacter.settings.colors.window_lock_unlocked}`}"
        class="pl-2 fas fa-{localIsLocked ? `lock` : `unlock`} cursor-pointer" />
      <i
        style="color:{localIsLocked ? `${$selectedCharacter.settings.colors.window_move_locked}` : `${$selectedCharacter.settings.colors.window_move_unlocked}`}"
        class="drag-handle {localIsLocked ? `cursor-not-allowed` : `cursor-move`} pl-2 fas fa-arrows-alt" />
    </div>
    <span class="text-white place-self-center">{label}</span>
  </div>
  <div class="flex-1 overflow-hidden">
    <slot />
  </div>
</div>
