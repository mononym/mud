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
  export let initialWidth = "400";
  export let initialHeight = "400";
  export let initialX = "0";
  export let initialY = "0";
  export let id;
  export let label = "";
  export let zIndex = 1;
  let visible = true;

  let localX = "0";
  let localY = "0";
  let localHeight = 400;
  let localWidth = 400;
  let localIsLocked = true;
  let localZIndex = 1;
  let localVisible = true;

  export function toggleVisibility() {
    localVisible = !localVisible;
    saveData();
  }

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
          localIsLocked = data.locked != undefined ? data.locked : locked;
          localZIndex = data.zIndex || zIndex;
          localVisible = data.visible != undefined ? data.visible : visible;
        });
      } else {
        localX = initialX;
        layoutItemWrapper.style.left = `${initialX}px`;
        localY = initialY;
        layoutItemWrapper.style.top = `${initialY}px`;
        localHeight = initialHeight;
        localWidth = initialWidth;
        localIsLocked = locked;
        localZIndex = zIndex;
        localVisible = visible;
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
    if (layoutItemWrapper == null) {
      return;
    }
    console.log("saveData");
    console.log(layoutItemWrapper.dataset);
    console.log(layoutItemWrapper.dataset || "0");

    const x = Math.max(
      parseInt(localX) + parseInt(layoutItemWrapper.dataset.x || "0"),
      0
    );
    const y = Math.max(
      parseInt(localY) + parseInt(layoutItemWrapper.dataset.y || "0"),
      0
    );

    const data = {
      x: x.toString(),
      y: y.toString(),
      locked: localIsLocked,
      zIndex: localZIndex,
      visible: localVisible,
    };

    if (
      layoutItemWrapper.clientWidth != 0 &&
      layoutItemWrapper.clientHeight != 0
    ) {
      data.width = layoutItemWrapper.offsetWidth;
      data.height = layoutItemWrapper.offsetHeight;
    } else {
      data.width = localWidth;
      data.height = localHeight;
    }

    console.log(x);
    console.log(y);

    // if (x != 0 && y != 0) {
    //   data.x = x.toString();
    //   data.y = y.toString();
    // } else {
    //   data.x = localX;
    //   data.y = localY;
    // }

    storage.set(`${$selectedCharacter.name}-${id}`, data, function (error) {
      if (error) throw error;
    });
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

  function incrementZIndex() {
    if (!localIsLocked) {
      localZIndex += 1;
      saveData();
    }
  }

  function decrementZIndex() {
    if (!localIsLocked) {
      localZIndex -= 1;
      saveData();
    }
  }
</script>

<div
  bind:this={layoutItemWrapper}
  class="layoutItemWrapper flex flex-col absolute bg-gray-700"
  style="height:{localHeight}px;width:{localWidth}px;touch-action:none;border-width:1px;z-index:{localZIndex};visibility:{localVisible
    ? 'visible'
    : 'hidden'}"
>
  <div
    style="background-color:{$selectedCharacter.settings.colors
      .window_toolbar_background}"
    class="flex-shrink h-8 grid grid-cols-3"
  >
    <div class="flex items-center">
      <i
        on:click={toggleLocked}
        style="color:{localIsLocked
          ? `${$selectedCharacter.settings.colors.window_lock_locked}`
          : `${$selectedCharacter.settings.colors.window_lock_unlocked}`}"
        class="pl-2 fas fa-{localIsLocked ? `lock` : `unlock`} cursor-pointer"
      />
      <i
        style="color:{localIsLocked
          ? `${$selectedCharacter.settings.colors.window_move_locked}`
          : `${$selectedCharacter.settings.colors.window_move_unlocked}`}"
        class="drag-handle {localIsLocked
          ? `cursor-not-allowed`
          : `cursor-move`} pl-2 fas fa-arrows-alt"
      />
      <span class="text-white place-self-center ml-2">z:</span>
      <i
        on:click={decrementZIndex}
        style="color:{localIsLocked
          ? `${$selectedCharacter.settings.colors.window_move_locked}`
          : `${$selectedCharacter.settings.colors.window_move_unlocked}`}"
        class="drag-handle {localIsLocked
          ? `cursor-not-allowed`
          : `cursor-move`} pl-2 fas fa-minus"
      />
      <span class="text-white place-self-center ml-2">{localZIndex}</span>
      <i
        on:click={incrementZIndex}
        style="color:{localIsLocked
          ? `${$selectedCharacter.settings.colors.window_move_locked}`
          : `${$selectedCharacter.settings.colors.window_move_unlocked}`}"
        class="drag-handle {localIsLocked
          ? `cursor-not-allowed`
          : `cursor-move`} pl-2 fas fa-plus"
      />
    </div>
    <span class="text-white place-self-center">{label}</span>
  </div>
  <div class="flex-1 overflow-hidden">
    <slot />
  </div>
</div>
