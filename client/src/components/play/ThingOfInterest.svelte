<script language="ts">
  import { createEventDispatcher } from "svelte";
  const dispatch = createEventDispatcher();
  import { getContext } from "svelte";
  import { key } from "./state";
  import { getItemColor } from "../../utils/utils";
  import QuickAction from "./QuickAction.svelte";

  const state = getContext(key);
  const { selectedCharacter, areaItemsParentChildIndex } = state;

  export let item;
  export let itemsParentChildIndex = {};
  export let colors = {};
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
  // Things of Interest are handled differently from other items in the area
  // For something to appear as a ToI it has to be a piece of scenery, or in some way related to (on, in, whatever) a piece of scenery AND be visible VIA that scenery
  //
  //
  //
</script>

<div class="flex flex-col select-none" bind:this={wrapperDiv}>
  <div
    class="cursor-pointer flex"
    style="color:{getItemColor($selectedCharacter.settings.colors, item)}"
    bind:this={itemDiv}
    on:contextmenu={dispatchContextMenuEvent}
  >
    {#if showQuickActions && $$slots.quickActions}
      <div class="flex-shrink mr-2">
        <slot name="quickActions" />
      </div>
    {/if}
    <pre
      on:click|preventDefault={toggleItemExpanded}
      class="flex-1 whitespace-pre-wrap">
      {item.description.short} {#if item.flags.has_pocket || (item.flags.furniture && item.furniture.has_external_surface)}({($areaItemsParentChildIndex[item.id] || []).length}){/if}
    </pre>
  </div>
  {#if itemExpanded}
    <pre
      on:click|preventDefault={toggleItemExpanded}
      class="whitespace-pre-wrap"
      style="color:{getItemColor(
        $selectedCharacter.settings.colors,
        item
      )}">{item.description.long}</pre>
  {/if}
  {#if ((item.flags.has_pocket && item.pocket.open) || (item.flags.furniture && item.furniture.has_external_surface)) && $areaItemsParentChildIndex[item.id] != undefined}
    <div class="flex flex-col ml-4">
      {#each $areaItemsParentChildIndex[item.id] as childItem}
        <div class="flex">
          <div class="flex-shrink mr-2">
            <i
              class="fas fa-level-up fa-rotate-90 fa-fw"
              style="color:{getItemColor(
                $selectedCharacter.settings.colors,
                childItem
              )}"
            />
          </div>
          <div class="flex-1">
            {#if childItem.flags.has_pocket}
              <svelte:self item={childItem} on:showContextMenu>
                <div class="h-full flex space-x-2 pl-2" slot="quickActions">
                  {#if childItem.pocket.open}
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
                  {:else if !childItem.pocket.open}
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
            {:else}
              <svelte:self item={childItem} on:showContextMenu />
            {/if}
          </div>
        </div>
      {/each}
    </div>
  {/if}
</div>
