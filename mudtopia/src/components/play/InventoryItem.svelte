<script language="ts">
  import { createEventDispatcher, beforeUpdate } from "svelte";
  const dispatch = createEventDispatcher();
  import { getContext } from "svelte";
  import { key } from "./state";
  import { getItemColor } from "../../utils/utils";
  import QuickAction from "./QuickAction.svelte";

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

  beforeUpdate(() => {
    console.log("onMount");
    console.log(item);
  });
</script>

<div class="flex flex-col select-none" bind:this={wrapperDiv}>
  <div
    class="cursor-pointer flex items-center"
    style="color:{getItemColor($selectedCharacter.settings.colors, item)}"
    bind:this={itemDiv}
    on:contextmenu={dispatchContextMenuEvent}
  >
    {#if showQuickActions}
      <div class="flex-shrink mr-2">
        <slot name="quickActions" />
      </div>
    {/if}
    <pre
      on:click|preventDefault={toggleItemExpanded}
      class="ml-2 flex-1">{item.description.short} {#if item.flags.container}({($inventoryItemsParentChildIndex[item.id] || []).length}){/if}</pre>
    {#if itemExpanded}
      <div
        on:click|preventDefault={toggleItemExpanded}
        class={showQuickActions && $$slots.quickActions
          ? "col-start-2 col-span-11 ml-4"
          : "col-span-12 ml-4"}
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
  {#if item.flags.container && item.container.open && $inventoryItemsParentChildIndex[item.id] != undefined}
    <div class="flex flex-col ml-2">
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
            <svelte:self item={childItem} on:showContextMenu>
              <div class="flex space-x-2 pl-2" slot="quickActions">
                {#if childItem.flags.container && childItem.container.open}
                  <QuickAction
                    icon="fas fa-box-open"
                    activeTooltip="close"
                    cliInput="close {childItem.id}"
                    storyOutput="close {childItem.description.short}"
                    activeIconColor={$selectedCharacter.settings
                      .inventoryWindow["enabled_quick_action_color"]}
                    inactiveIconColor={$selectedCharacter.settings
                      .inventoryWindow["disabled_quick_action_color"]}
                  />
                {:else}
                  <QuickAction
                    icon="fas fa-box"
                    activeTooltip="open"
                    cliInput="open {childItem.id}"
                    storyOutput="open {childItem.description.short}"
                    activeIconColor={$selectedCharacter.settings
                      .inventoryWindow["enabled_quick_action_color"]}
                    inactiveIconColor={$selectedCharacter.settings
                      .inventoryWindow["disabled_quick_action_color"]}
                  />
                {/if}
              </div>
            </svelte:self>
          </div>
        </div>
      {/each}
    </div>
  {/if}
</div>
