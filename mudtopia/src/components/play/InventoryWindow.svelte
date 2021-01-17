<script>
  import InventoryItem from "./InventoryItem.svelte";
  import InventoryItemRightClickMenu from "./InventoryItemRightClickMenu.svelte";
  import { getContext } from "svelte";
  import { key } from "./state";

  const state = getContext(key);
  const {
    wornItems,
    itemInLeftHand,
    itemInRightHand,
    leftHandHasItem,
    rightHandHasItem,
    selectedCharacter,
  } = state;

  let menuItem;
  let showMenu = false;
  let pos = { x: 0, y: 0 };

  let windowDiv;

  async function showRightClickMenu(customEvent) {
    if (showMenu) {
      showMenu = false;
      await new Promise((res) => setTimeout(res, 100));
    }

    pos = {
      x: customEvent.detail.event.layerX,
      y: customEvent.detail.event.layerY,
    };

    menuItem = customEvent.detail.item;
    showMenu = true;
  }

  let showHeldItems = true;
  function toggleHeldItems() {
    showHeldItems = !showHeldItems;
  }

  let showWornItems = true;
  function toggleWornItems() {
    showWornItems = !showWornItems;
  }
</script>

<div class="h-full w-full p-2 flex flex-col relative" bind:this={windowDiv}>
  <div class="cursor-pointer select-none" on:click={toggleHeldItems}>
    <i class="fas fa-minus" />
    <pre
      class="inline"
      style="color:{$selectedCharacter.settings.colors[
        'toi_label'
      ]}">Held Items</pre>
  </div>
  {#if showHeldItems}
    <div class="ml-2">
      {#if $selectedCharacter.handedness == "right"}
        <div class="flex">
          <i class="fas fa-hand-paper text-xl text-white" />
          &nbsp;
          {#if $rightHandHasItem}
            <InventoryItem
              item={$itemInRightHand}
              on:showContextMenu={showRightClickMenu}
            />
          {:else}
            <pre>nothing</pre>
          {/if}
        </div>
        <div class="flex">
          <i class="fas fa-hand-paper fa-flip-horizontal text-xl text-white" />
          &nbsp;
          {#if $leftHandHasItem}
            <InventoryItem
              item={$itemInLeftHand}
              on:showContextMenu={showRightClickMenu}
            />
          {:else}
            <pre>nothing</pre>
          {/if}
        </div>
      {:else}
        <div class="flex">
          <i class="fas fa-hand-paper fa-flip-horizontal text-xl text-white" />
          &nbsp;
          {#if $leftHandHasItem}
            <InventoryItem
              item={$itemInLeftHand}
              on:showContextMenu={showRightClickMenu}
            />
          {:else}
            <pre>nothing</pre>
          {/if}
        </div>
        <div class="flex">
          <i class="fas fa-hand-paper text-xl text-white" />
          &nbsp;
          {#if $rightHandHasItem}
            <InventoryItem
              item={$itemInRightHand}
              on:showContextMenu={showRightClickMenu}
            />
          {:else}
            <pre>nothing</pre>
          {/if}
        </div>
      {/if}
    </div>
  {/if}
  <div class="cursor-pointer select-none" on:click={toggleWornItems}>
    <i class="fas fa-minus" />
    <pre
      class="inline"
      style="color:{$selectedCharacter.settings.colors[
        'toi_label'
      ]}">Worn Items</pre>
  </div>
  {#if showWornItems}
    <div class="ml-2">
      {#each $wornItems as wornItem}
        <InventoryItem
          item={wornItem}
          on:showContextMenu={showRightClickMenu}
        />
      {/each}
    </div>
  {/if}
  <InventoryItemRightClickMenu {pos} item={menuItem} bind:showMenu />
</div>
