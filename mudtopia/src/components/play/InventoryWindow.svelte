<script>
  import { onMount } from "svelte";
  import InventoryItem from "./InventoryItem.svelte";
  import InventoryRightClickMenu from "./InventoryRightClickMenu.svelte";
  import { State } from "./state";
  const {
    allInventoryItemsIndex,
    leftHandHasItem,
    rightHandHasItem,
    itemInLeftHand,
    itemInRightHand,
    inventoryItemsParentChildIndex,
    wornItems,
    selectedCharacter,
  } = State;

  let windowDiv;

  onMount(() => {
    console.log("allInventoryItemsIndex");
    console.log($allInventoryItemsIndex);
  });
</script>

<div class="h-full w-full p-2 flex flex-col relative" bind:this={windowDiv}>
  {#each $wornItems as wornItem}
    <InventoryItem item={wornItem} />
  {/each}
  <InventoryRightClickMenu target={windowDiv} />
</div>
