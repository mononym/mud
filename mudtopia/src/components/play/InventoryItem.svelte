<script language="ts">
  import { createEventDispatcher } from "svelte";
  const dispatch = createEventDispatcher();
  import { getContext } from "svelte";
  import { key } from "./state";
  import { getItemColor } from "../../utils/utils";

  const state = getContext(key);
  const { selectedCharacter, inventoryItemsParentChildIndex } = state;

  export let item;
  let wrapperDiv;
  let itemDiv;

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
    style="color:{getItemColor($selectedCharacter.settings.colors, item)}"
    bind:this={itemDiv}
    on:contextmenu={dispatchContextMenuEvent}
  >
    {#if item.isContainer && item.containerOpen}
      <i
        class="fas fa-plus"
        on:click|preventDefault={toggleContainerExpanded}
      />
      &nbsp;
    {:else if item.isContainer && !item.containerOpen}
      <i
        class="fas fa-minus"
        on:click|preventDefault={toggleContainerExpanded}
      />
      &nbsp;
    {/if}
    <!-- &nbsp;&nbsp;
    <i class={item.icon} on:click|preventDefault={toggleItemExpanded} /> -->
    <pre
      on:click|preventDefault={toggleItemExpanded}
      class="inline">{item.shortDescription}</pre>
    {#if itemExpanded}
      <div class="pl-{item.isContainer ? '6' : '0'}">
        <pre
          class="whitespace-pre-wrap"
          style="color:{getItemColor(
            $selectedCharacter.settings.colors,
            item
          )}">{item.longDescription}</pre>
      </div>
    {/if}
  </div>
  {#if containerExpanded && $inventoryItemsParentChildIndex[item.id] != undefined}
    <div class="flex">
      {#each $inventoryItemsParentChildIndex[item.id] as childItem}
        &nbsp; &nbsp;
        <i
          class="fas fa-level-up fa-rotate-90"
          style="color:{getItemColor(
            $selectedCharacter.settings.colors,
            childItem
          )}"
        />
        &nbsp; &nbsp; &nbsp;
        <div class="flex-1">
          <svelte:self item={childItem} on:showContextMenu />
        </div>
      {/each}
    </div>
  {/if}
</div>
