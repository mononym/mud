<script language="ts">
  import InventoryItemRightClickMenu from "./InventoryItemRightClickMenu.svelte";
  import { State } from "./state";
  const { selectedCharacter, inventoryItemsParentChildIndex } = State;

  import { createEventDispatcher } from "svelte";
  const dispatch = createEventDispatcher();

  export let item;
  let wrapperDiv;
  let itemDiv;
  let showMenu = false;
  let showChildMenu = false;

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

  function dispatchContextMenuEvent(event) {
    dispatch("showContextMenu", { event: event, item: item });
  }
</script>

<div class="flex-shrink flex flex-col" bind:this={wrapperDiv}>
  <div
    class="cursor-pointer"
    style="color:{getItemColor(item)}"
    bind:this={itemDiv}
    on:contextmenu={dispatchContextMenuEvent}>
    {#if item.isContainer}
      <i
        class="text-white fas fa-plus"
        on:click|preventDefault={toggleContainerExpanded} />&nbsp;
    {/if}
    <i class={item.icon} on:click|preventDefault={toggleItemExpanded} />
    <pre
      on:click|preventDefault={toggleItemExpanded}
      class="inline">{` ${item.shortDescription}`}</pre>
    {#if itemExpanded}
      <div class="pl-{item.isContainer ? '12' : '8'}">
        <pre
          class="whitespace-pre-wrap"
          style="color:{$selectedCharacter.settings.colors.base}">{item.longDescription}</pre>
      </div>
    {/if}
  </div>
  {#if containerExpanded && $inventoryItemsParentChildIndex[item.id] != undefined}
    <div class="pl-12">
      {#each $inventoryItemsParentChildIndex[item.id] as childItem}
        <svelte:self item={childItem} on:showContextMenu />
      {/each}
    </div>
  {/if}
  <!-- <InventoryItemRightClickMenu listenerTarget={itemDiv} {item} bind:showMenu /> -->
</div>
