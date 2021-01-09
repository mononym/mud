<script>
  import InventoryItem from "./InventoryItem.svelte";
  import InventoryItemRightClickMenu from "./InventoryItemRightClickMenu.svelte";
  import { State } from "./state";
  const { wornItems } = State;

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
</script>

<div class="h-full w-full p-2 flex flex-col relative" bind:this={windowDiv}>
  {#each $wornItems as wornItem}
    <InventoryItem item={wornItem} on:showContextMenu={showRightClickMenu} />
  {/each}
  <InventoryItemRightClickMenu {pos} item={menuItem} bind:showMenu />
</div>
