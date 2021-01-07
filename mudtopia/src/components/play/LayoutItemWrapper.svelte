<script language="ts">
  import { onMount, onDestroy } from "svelte";
  import interact from "interactjs";
  import { interactable } from "../../utils/interactable";
  import { State } from "./state";
  const { selectedCharacter } = State;
  const storage = require("electron-json-storage");

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

  onMount(() => {
    interactable(layoutItemWrapper);
    // if (!initialized) {
    storage.has(id, function (error, hasKey) {
      if (error) throw error;

      if (hasKey) {
        storage.get(id, function (error, data) {
          if (error) throw error;

          localX = data.x;
          layoutItemWrapper.style.left = `${data.x}px`;
          localY = data.y;
          layoutItemWrapper.style.top = `${data.y}px`;
          localHeight = data.height;
          localWidth = data.width;
          localIsLocked = data.locked || false;
        });
      } else {
        localX = x;
        layoutItemWrapper.style.left = `${x}px`;
        localY = y;
        layoutItemWrapper.style.top = `${y}px`;
        localHeight = height;
        localWidth = width;
        localIsLocked = locked || false;
      }
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
      id,
      {
        width: layoutItemWrapper.clientWidth,
        height: layoutItemWrapper.clientHeight,
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
  style="height:{localHeight}px;width:{localWidth}px;touch-action:none">
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
