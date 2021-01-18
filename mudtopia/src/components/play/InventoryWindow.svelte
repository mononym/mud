<script>
  import InventoryWindowFilterButton from "./InventoryWindowFilterButton.svelte";
  import InventoryItem from "./InventoryItem.svelte";
  import InventoryItemRightClickMenu from "./InventoryItemRightClickMenu.svelte";
  import { getContext } from "svelte";
  import { key } from "./state";
  import { getItemColor } from "../../utils/utils";

  const state = getContext(key);
  const {
    wornContainers,
    itemInLeftHand,
    itemInRightHand,
    leftHandHasItem,
    rightHandHasItem,
    selectedCharacter,
    characterSettings,
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

  let heldItemsExpanded = true;
  function toggleHeldItems() {
    heldItemsExpanded = !heldItemsExpanded;
  }

  let wornContainersExpanded = true;
  function toggleWornContainers() {
    wornContainersExpanded = !wornContainersExpanded;
  }

  let wornItemsExpanded = true;
  function toggleWornItems() {
    wornItemsExpanded = !wornItemsExpanded;
  }

  let wornItems = [];
  $: $characterSettings.inventoryWindow.show_held_items,
    $characterSettings.inventoryWindow.show_worn_containers,
    $characterSettings.inventoryWindow.show_worn_clothes,
    $characterSettings.inventoryWindow.show_worn_armor,
    $characterSettings.inventoryWindow.show_worn_weapons,
    $characterSettings.inventoryWindow.show_worn_jewelry,
    buildWornItems();

  function buildWornItems() {
    wornItems = [];

    if (!$characterSettings.inventoryWindow.show_held_items) {
      const item1 =
        $selectedCharacter.handedness == "right"
          ? $itemInRightHand
          : $itemInLeftHand;
      const item2 =
        $selectedCharacter.handedness == "right"
          ? $itemInLeftHand
          : $itemInRightHand;

      if (item1 != undefined && item1.id != "") {
        wornItems.push(item1);
      }
      if (item2 != undefined && item2.id != "") {
        wornItems.push(item2);
      }
    }

    if (!$characterSettings.inventoryWindow.show_worn_containers) {
      $wornContainers.forEach((container) => wornItems.push(container));
    }
  }
</script>

<div
  class="h-full w-full p-2 flex flex-col relative"
  bind:this={windowDiv}
  style="background-color:{$selectedCharacter.settings.inventoryWindow
    .background}"
>
  {#if $selectedCharacter.settings.inventoryWindow.show_held_items}
    <div
      class="cursor-pointer select-none"
      on:click={toggleHeldItems}
      style="color:{$selectedCharacter.settings.inventoryWindow[
        'held_items_label'
      ]}"
    >
      <i class="fas fa-{heldItemsExpanded ? 'minus' : 'plus'}" />
      &nbsp;
      <pre
        class="inline">Held Items ({($leftHandHasItem ? 1 : 0) + ($rightHandHasItem ? 1 : 0)})</pre>
    </div>
    {#if heldItemsExpanded}
      <div class="ml-2">
        {#if $selectedCharacter.handedness == "right"}
          <div
            class="flex"
            style="color:{$rightHandHasItem
              ? getItemColor(
                  $selectedCharacter.settings.colors,
                  $itemInRightHand
                )
              : $selectedCharacter.settings.inventoryWindow['empty_hand']}"
          >
            {#if $rightHandHasItem}
              <i class="fas fa-hand-paper text-xl cursor-not-allowed" />
              &nbsp; &nbsp;
              <InventoryItem
                item={$itemInRightHand}
                on:showContextMenu={showRightClickMenu}
              />
            {:else}
              <i class="fas fa-hand-paper text-xl cursor-not-allowed" />
              &nbsp; &nbsp;
              <pre
                class="select-none cursor-not-allowed"
                style="color:{$selectedCharacter.settings.inventoryWindow[
                  'empty_hand'
                ]}">EMPTY</pre>
            {/if}
          </div>
          <div
            class="flex"
            style="color:{$leftHandHasItem
              ? getItemColor(
                  $selectedCharacter.settings.colors,
                  $itemInLeftHand
                )
              : $selectedCharacter.settings.inventoryWindow['empty_hand']}"
          >
            <i
              class="fas fa-hand-paper fa-flip-horizontal text-xl cursor-not-allowed"
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
              class="fas fa-hand-paper fa-flip-horizontal text-xl cursor-not-allowed"
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
            <i class="fas fa-hand-paper text-xl cursor-not-allowed" />
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
  {/if}
  {#if $selectedCharacter.settings.inventoryWindow.show_worn_containers}
    <div
      class="cursor-pointer select-none"
      on:click={toggleWornContainers}
      style="color:{$selectedCharacter.settings.inventoryWindow[
        'worn_containers_label'
      ]}"
    >
      <i class="fas fa-{wornContainersExpanded ? 'minus' : 'plus'}" />
      &nbsp;
      <pre class="inline">Worn Containers ({$wornContainers.length})</pre>
    </div>
    {#if wornContainersExpanded}
      <div class="ml-2">
        {#each $wornContainers as wornContainer}
          <InventoryItem
            item={wornContainer}
            on:showContextMenu={showRightClickMenu}
          />
        {/each}
      </div>
    {/if}
  {/if}
  <div
    class="cursor-pointer select-none"
    on:click={toggleWornItems}
    style="color:{$selectedCharacter.settings.inventoryWindow[
      'worn_items_label'
    ]}"
  >
    <i class="fas fa-{wornItemsExpanded ? 'minus' : 'plus'}" />
    &nbsp;
    <pre class="inline">Other Worn Items ({wornItems.length})</pre>
  </div>
  {#if wornItemsExpanded}
    <div class="ml-2">
      {#each wornItems as wornItem}
        <InventoryItem
          item={wornItem}
          on:showContextMenu={showRightClickMenu}
        />
      {/each}
    </div>
  {/if}
  <div class="spacer flex-1" />
  <div
    class="w-full flex"
    style="border:1px solid {$selectedCharacter.settings.inventoryWindow[
      'filter_border_color'
    ]}"
  >
    <InventoryWindowFilterButton
      icon="fas fa-hands"
      bind:active={$characterSettings.inventoryWindow.show_held_items}
      activeTooltip="Hide held items"
      inactiveTooltip="Show held items"
    />
    <InventoryWindowFilterButton
      icon="fas fa-backpack"
      bind:active={$characterSettings.inventoryWindow.show_worn_containers}
      activeTooltip="Hide worn containers"
      inactiveTooltip="Show worn containers"
    />
    <InventoryWindowFilterButton
      icon="fas fa-tshirt"
      bind:active={$characterSettings.inventoryWindow.show_worn_clothes}
      activeTooltip="Hide worn clothes"
      inactiveTooltip="Show worn clothes"
    />
    <InventoryWindowFilterButton
      icon="fas fa-shield"
      bind:active={$characterSettings.inventoryWindow.show_worn_armor}
      activeTooltip="Hide worn armor"
      inactiveTooltip="Show worn armor"
    />
    <InventoryWindowFilterButton
      icon="fas fa-shield"
      bind:active={$characterSettings.inventoryWindow.show_worn_weapons}
      activeTooltip="Hide worn weapons"
      inactiveTooltip="Show worn weapons"
    />
    <InventoryWindowFilterButton
      icon="fas fa-ring"
      bind:active={$characterSettings.inventoryWindow.show_worn_jewelry}
      activeTooltip="Hide worn jewelry"
      inactiveTooltip="Show worn jewelry"
    />
  </div>
  <InventoryItemRightClickMenu {pos} item={menuItem} bind:showMenu />
</div>
