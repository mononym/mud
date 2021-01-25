<script language="ts">
  import { createEventDispatcher } from "svelte";
  const dispatch = createEventDispatcher();
  import { getContext } from "svelte";
  import { key } from "./state";
  import { getItemColor } from "../../utils/utils";

  const state = getContext(key);
  const { selectedCharacter, inventoryItemsParentChildIndex } = state;

  export let item;
  export let showQuickActions = true;
  let wrapperDiv;
  let itemDiv;

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
    class="cursor-pointer grid gap-1 grid-cols-12 items-center"
    style="color:{getItemColor($selectedCharacter.settings.colors, item)}"
    bind:this={itemDiv}
    on:contextmenu={dispatchContextMenuEvent}
  >
    {#if showQuickActions}
      <div class="col-span-1 mr-2">
        <slot name="quickActions" />
      </div>
    {/if}
    <pre
      on:click|preventDefault={toggleItemExpanded}
      class="ml-2 col-span-{showQuickActions && $$slots.quickActions
        ? 11
        : 12}">{item.description.short}</pre>
    {#if itemExpanded}
      <div
        on:click|preventDefault={toggleItemExpanded}
        class={showQuickActions && $$slots.quickActions
          ? "col-start-2 col-span-11 ml-2"
          : "col-span-12 ml-2"}
      >
        <pre
          class="whitespace-pre-wrap"
          style="color:{getItemColor(
            $selectedCharacter.settings.colors,
            item
          )}">{item.description.long}</pre>
      </div>
    {/if}
  </div>
  {#if item.container.open && $inventoryItemsParentChildIndex[item.id] != undefined}
    <div class="flex flex-col ml-4">
      {#each $inventoryItemsParentChildIndex[item.id] as childItem}
        <div class="flex">
          <div class="flex-shrink mr-2 mt-1">
            <i
              class="fas fa-level-up fa-rotate-90 fa-fw"
              style="color:{getItemColor(
                $selectedCharacter.settings.colors,
                childItem
              )}"
            />
          </div>
          <div class="flex-1">
            <svelte:self item={childItem} on:showContextMenu />
          </div>
        </div>
      {/each}
    </div>
  {/if}
</div>
