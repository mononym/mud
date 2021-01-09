<script language="ts">
  import InventoryItemRightClickMenu from "./InventoryItemRightClickMenu.svelte";
  import { State } from "./state";
  const { selectedCharacter, inventoryItemsParentChildIndex } = State;

  export let item;
  let itemDiv;

  function getItemColor(item) {
    if (item.isWearable && item.isContainer) {
      return $selectedCharacter.settings.colors.worn_container;
    } else if (item.isContainer) {
      return $selectedCharacter.settings.colors.container;
    } else if (item.isFurniture) {
      return $selectedCharacter.settings.colors.furniture;
    } else {
      return "#000000";
    }
  }

  let containerExpanded = false;
  function toggleContainerExpanded() {
    console.log("toggleContainerExpanded");
    containerExpanded = !containerExpanded;
  }

  let itemExpanded = false;
  function toggleItemExpanded() {
    console.log("toggleItemExpanded");
    itemExpanded = !itemExpanded;
  }
</script>

<div class="flex-shrink flex flex-col" bind:this={itemDiv}>
  <div
    class="cursor-pointer"
    style="color:{getItemColor(item)}"
    on:click|preventDefault={toggleItemExpanded}>
    {#if item.isContainer}
      <i
        class="text-white fas fa-plus"
        on:click|preventDefault|stopPropagation={toggleContainerExpanded} />&nbsp;
    {/if}
    <i class={item.icon} />
    <pre class="inline">{` ${item.shortDescription}`}</pre>
  </div>
  {#if itemExpanded}
    <div class="pl-{item.isContainer ? '12' : '8'}">
      <pre
        class="whitespace-pre-wrap"
        style="color:{$selectedCharacter.settings.colors.base}">{item.longDescription}</pre>
    </div>
  {/if}
  {#if containerExpanded && $inventoryItemsParentChildIndex[item.id] != undefined}
    <div class="pl-12">
      {#each $inventoryItemsParentChildIndex[item.id] as childItem}
        <svelte:self item={childItem} />
      {/each}
    </div>
  {/if}
  <InventoryItemRightClickMenu target={itemDiv} />
</div>
