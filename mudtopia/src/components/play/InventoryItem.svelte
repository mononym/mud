<script language="ts">
  import { createEventDispatcher } from "svelte";
  const dispatch = createEventDispatcher();
  import { getContext } from "svelte";
  import { key } from "./state";

  const state = getContext(key);
  const { selectedCharacter, inventoryItemsParentChildIndex } = state;

  export let item;
  let wrapperDiv;
  let itemDiv;

  function getItemColor(item) {
    if (item.isWearable && item.isContainer) {
      return $selectedCharacter.settings.colors.worn_container;
    } else if (item.isContainer) {
      return $selectedCharacter.settings.colors.container;
    } else if (item.isFurniture) {
      return $selectedCharacter.settings.colors.furniture;
    } else if (item.isScenery) {
      return $selectedCharacter.settings.colors.scenery;
    } else {
      return $selectedCharacter.settings.colors.base;
    }
  }

  let containerExpanded = false;
  function toggleContainerExpanded() {
    containerExpanded = !containerExpanded;
  }

  let itemExpanded = false;
  function toggleItemExpanded() {
    itemExpanded = !itemExpanded;
  }

  function dispatchContextMenuEvent(event) {
    dispatch("showContextMenu", { event: event, item: item });
  }
</script>

<div class="flex flex-col select-none" bind:this={wrapperDiv}>
  <div
    class="cursor-pointer"
    style="color:{getItemColor(item)}"
    bind:this={itemDiv}
    on:contextmenu={dispatchContextMenuEvent}
  >
    {#if item.isContainer && item.containerOpen}
      <i
        class="fas fa-plus"
        on:click|preventDefault={toggleContainerExpanded}
      />
    {:else if item.isContainer && !item.containerOpen}
      <i
        class="fas fa-minus"
        on:click|preventDefault={toggleContainerExpanded}
      />
    {/if}
    &nbsp;&nbsp;
    <i class={item.icon} on:click|preventDefault={toggleItemExpanded} />
    &nbsp;&nbsp;
    <pre
      on:click|preventDefault={toggleItemExpanded}
      class="inline">{item.shortDescription}</pre>
    {#if itemExpanded}
      <div class="pl-{item.isContainer ? '14' : '10'}">
        <pre
          class="whitespace-pre-wrap"
          style="color:{$selectedCharacter.settings.colors
            .base}">{item.longDescription}</pre>
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
</div>
