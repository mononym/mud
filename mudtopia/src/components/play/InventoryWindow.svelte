<script>
  import InventoryItem from "./InventoryItem.svelte";
  import InventoryItemRightClickMenu from "./InventoryItemRightClickMenu.svelte";
  import { getContext } from "svelte";
  import { key } from "./state";

  const state = getContext(key);
  const {
    wornContainers,
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
  <div
    class="cursor-pointer select-none"
    on:click={toggleHeldItems}
    style="color:{$selectedCharacter.settings.colors['held_items_label']}"
  >
    <i class="fas fa-minus" />
    &nbsp;
    <pre
      class="inline">Held Items ({($leftHandHasItem ? 1 : 0) + ($rightHandHasItem ? 1 : 0)})</pre>
  </div>
  {#if showHeldItems}
    <div class="ml-2">
      {#if $selectedCharacter.handedness == "right"}
        <div class="flex">
          <i class="fas fa-hand-paper text-xl text-white cursor-not-allowed" />
          &nbsp;
          {#if $rightHandHasItem}
            &nbsp;
            <InventoryItem
              item={$itemInRightHand}
              on:showContextMenu={showRightClickMenu}
            />
          {:else}
            &nbsp;
            <pre class="select-none cursor-not-allowed">EMPTY</pre>
          {/if}
        </div>
        <div class="flex">
          <i
            class="fas fa-hand-paper fa-flip-horizontal text-xl text-white cursor-not-allowed"
          />
          &nbsp;
          {#if $leftHandHasItem}
            &nbsp;
            <InventoryItem
              item={$itemInLeftHand}
              on:showContextMenu={showRightClickMenu}
            />
          {:else}
            &nbsp;
            <pre class="select-none cursor-not-allowed">EMPTY</pre>
          {/if}
        </div>
      {:else}
        <div class="flex">
          <i
            class="fas fa-hand-paper fa-flip-horizontal text-xl text-white cursor-not-allowed"
          />
          &nbsp;
          {#if $leftHandHasItem}
            &nbsp;
            <InventoryItem
              item={$itemInLeftHand}
              on:showContextMenu={showRightClickMenu}
            />
          {:else}
            &nbsp;
            <pre class="select-none cursor-not-allowed">EMPTY</pre>
          {/if}
        </div>
        <div class="flex">
          <i class="fas fa-hand-paper text-xl text-white cursor-not-allowed" />
          &nbsp;
          {#if $rightHandHasItem}
            &nbsp;
            <InventoryItem
              item={$itemInRightHand}
              on:showContextMenu={showRightClickMenu}
            />
          {:else}
            &nbsp;
            <pre class="select-none cursor-not-allowed">EMPTY</pre>
          {/if}
        </div>
      {/if}
    </div>
  {/if}
  <div
    class="cursor-pointer select-none"
    on:click={toggleWornItems}
    style="color:{$selectedCharacter.settings.colors['worn_containers']}"
  >
    <i class="fas fa-minus" />
    &nbsp;
    <pre class="inline">Worn Containers ({$wornContainers.length})</pre>
  </div>
  {#if showWornItems}
    <div class="ml-2">
      {#each $wornContainers as wornItem}
        <InventoryItem
          item={wornItem}
          on:showContextMenu={showRightClickMenu}
        />
      {/each}
    </div>
  {/if}
  <InventoryItemRightClickMenu {pos} item={menuItem} bind:showMenu />
</div>
