<script>
  import FilterButton from "./FilterButton.svelte";
  import InventoryItem from "./InventoryItem.svelte";
  import InventoryItemRightClickMenu from "./InventoryItemRightClickMenu.svelte";
  import { getContext } from "svelte";
  import { key } from "./state";
  import { getItemColor } from "../../utils/utils";
  import QuickAction from "./QuickAction.svelte";

  const state = getContext(key);
  const {
    wornContainers,
    itemInLeftHand,
    itemInRightHand,
    leftHandHasItem,
    rightHandHasItem,
    selectedCharacter,
    characterSettings,
    saveCharacterSettings,
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

  function saveSettings() {
    saveCharacterSettings();
  }

  let wornItems = [];
  $: $characterSettings.inventoryWindow.show_worn_containers,
    $characterSettings.inventoryWindow.show_worn_clothes,
    $characterSettings.inventoryWindow.show_worn_armor,
    $characterSettings.inventoryWindow.show_worn_weapons,
    $characterSettings.inventoryWindow.show_worn_jewelry,
    buildWornItems();

  function buildWornItems() {
    wornItems = [];

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
              <i
                class="fas fa-hand-paper fa-lg fa-fw text-xl cursor-not-allowed"
              />
              &nbsp; &nbsp;
              {#if $selectedCharacter.settings.inventoryWindow["show_quick_actions"]}
                <QuickAction
                  icon="fas fa-backpack"
                  activeTooltip="stow"
                  cliInput="stow {$itemInRightHand.id}"
                  storyOutput="get {$itemInRightHand.shortDescription}"
                  activeIconColor={$selectedCharacter.settings.inventoryWindow[
                    "enabled_quick_action_color"
                  ]}
                  inactiveIconColor={$selectedCharacter.settings
                    .inventoryWindow["disabled_quick_action_color"]}
                />
                <QuickAction
                  icon="fas fa-hand-holding-box fa-rotate-180"
                  activeTooltip="drop"
                  cliInput="drop {$itemInRightHand.id}"
                  storyOutput="drop {$itemInRightHand.shortDescription}"
                  activeIconColor={$selectedCharacter.settings.inventoryWindow[
                    "enabled_quick_action_color"
                  ]}
                  inactiveIconColor={$selectedCharacter.settings
                    .inventoryWindow["disabled_quick_action_color"]}
                />
                &nbsp; &nbsp;
              {/if}
              <InventoryItem
                item={$itemInRightHand}
                on:showContextMenu={showRightClickMenu}
              />
            {:else}
              <i
                class="fas fa-hand-paper fa-lg fa-fw text-xl cursor-not-allowed"
              />
              &nbsp; &nbsp;
              <pre
                class="select-none cursor-not-allowed self-center"
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
              class="fas fa-hand-paper fa-lg fa-fw fa-flip-horizontal text-xl cursor-not-allowed"
            />
            &nbsp; &nbsp;
            {#if $leftHandHasItem}
              {#if $selectedCharacter.settings.inventoryWindow["show_quick_actions"]}
                <QuickAction
                  icon="fas fa-backpack"
                  activeTooltip="stow"
                  cliInput="stow {$itemInLeftHand.id}"
                  storyOutput="get {$itemInLeftHand.shortDescription}"
                  activeIconColor={$selectedCharacter.settings.inventoryWindow[
                    "enabled_quick_action_color"
                  ]}
                  inactiveIconColor={$selectedCharacter.settings
                    .inventoryWindow["disabled_quick_action_color"]}
                />
                <QuickAction
                  icon="fas fa-hand-holding-box fa-rotate-180"
                  activeTooltip="drop"
                  cliInput="drop {$itemInLeftHand.id}"
                  storyOutput="drop {$itemInLeftHand.shortDescription}"
                  activeIconColor={$selectedCharacter.settings.inventoryWindow[
                    "enabled_quick_action_color"
                  ]}
                  inactiveIconColor={$selectedCharacter.settings
                    .inventoryWindow["disabled_quick_action_color"]}
                />
                &nbsp; &nbsp;
              {/if}
              <InventoryItem
                item={$itemInLeftHand}
                on:showContextMenu={showRightClickMenu}
              />
            {:else}
              <pre
                class="select-none cursor-not-allowed self-center">EMPTY</pre>
            {/if}
          </div>
        {:else}
          <div class="flex">
            <i
              class="fas fa-hand-paper fa-lg fa-fw fa-flip-horizontal text-xl cursor-not-allowed"
            />
            &nbsp;
            {#if $leftHandHasItem}
              &nbsp; &nbsp;
              {#if $selectedCharacter.settings.inventoryWindow["show_quick_actions"]}
                <QuickAction
                  icon="fas fa-backpack"
                  activeTooltip="stow"
                  cliInput="stow {$itemInLeftHand.id}"
                  storyOutput="get {$itemInLeftHand.shortDescription}"
                  activeIconColor={$selectedCharacter.settings.inventoryWindow[
                    "enabled_quick_action_color"
                  ]}
                  inactiveIconColor={$selectedCharacter.settings
                    .inventoryWindow["disabled_quick_action_color"]}
                />
                <QuickAction
                  icon="fas fa-hand-holding-box fa-rotate-180"
                  activeTooltip="drop"
                  cliInput="drop {$itemInLeftHand.id}"
                  storyOutput="drop {$itemInLeftHand.shortDescription}"
                  activeIconColor={$selectedCharacter.settings.inventoryWindow[
                    "enabled_quick_action_color"
                  ]}
                  inactiveIconColor={$selectedCharacter.settings
                    .inventoryWindow["disabled_quick_action_color"]}
                />
                &nbsp; &nbsp;
              {/if}
              <InventoryItem
                item={$itemInLeftHand}
                on:showContextMenu={showRightClickMenu}
              />
            {:else}
              &nbsp;
              <pre
                class="select-none cursor-not-allowed self-center">EMPTY</pre>
            {/if}
          </div>
          <div class="flex">
            <i
              class="fas fa-hand-paper fa-lg fa-fw text-xl cursor-not-allowed"
            />
            &nbsp;
            {#if $rightHandHasItem}
              <i
                class="fas fa-hand-paper fa-lg fa-fw text-xl cursor-not-allowed"
              />
              &nbsp; &nbsp;
              {#if $selectedCharacter.settings.inventoryWindow["show_quick_actions"]}
                <QuickAction
                  icon="fas fa-backpack"
                  activeTooltip="stow"
                  cliInput="stow {$itemInRightHand.id}"
                  storyOutput="get {$itemInRightHand.shortDescription}"
                  activeIconColor={$selectedCharacter.settings.inventoryWindow[
                    "enabled_quick_action_color"
                  ]}
                  inactiveIconColor={$selectedCharacter.settings
                    .inventoryWindow["disabled_quick_action_color"]}
                />
                <QuickAction
                  icon="fas fa-hand-holding-box fa-rotate-180"
                  activeTooltip="drop"
                  cliInput="drop {$itemInRightHand.id}"
                  storyOutput="drop {$itemInRightHand.shortDescription}"
                  activeIconColor={$selectedCharacter.settings.inventoryWindow[
                    "enabled_quick_action_color"
                  ]}
                  inactiveIconColor={$selectedCharacter.settings
                    .inventoryWindow["disabled_quick_action_color"]}
                />
                &nbsp; &nbsp;
              {/if}
              <InventoryItem
                item={$itemInRightHand}
                on:showContextMenu={showRightClickMenu}
              />
            {:else}
              &nbsp;
              <pre
                class="select-none cursor-not-allowed self-center">EMPTY</pre>
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
  {#if $selectedCharacter.settings.inventoryWindow.show_worn_items}
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
  {/if}
  <div class="spacer flex-1" />
  <div
    class="w-full flex"
    style="border:1px solid {$selectedCharacter.settings.inventoryWindow[
      'filter_border_color'
    ]}"
  >
    <FilterButton
      icon="fas fa-hands"
      bind:active={$characterSettings.inventoryWindow.show_held_items}
      on:toggle={saveSettings}
      activeTooltip="Hide held items"
      inactiveTooltip="Show held items"
      activeIconColor={$selectedCharacter.settings.inventoryWindow[
        "filter_active_icon_color"
      ]}
      inactiveIconColor={$selectedCharacter.settings.inventoryWindow[
        "filter_inactive_icon_color"
      ]}
    />
    <FilterButton
      icon="fas fa-backpack"
      bind:active={$characterSettings.inventoryWindow.show_worn_containers}
      on:toggle={saveSettings}
      activeTooltip="Hide worn containers"
      inactiveTooltip="Show worn containers"
      activeIconColor={$selectedCharacter.settings.inventoryWindow[
        "filter_active_icon_color"
      ]}
      inactiveIconColor={$selectedCharacter.settings.inventoryWindow[
        "filter_inactive_icon_color"
      ]}
    />
    <FilterButton
      icon="fas fa-tshirt"
      bind:active={$characterSettings.inventoryWindow.show_worn_clothes}
      on:toggle={saveSettings}
      activeTooltip="Hide worn clothes"
      inactiveTooltip="Show worn clothes"
      activeIconColor={$selectedCharacter.settings.inventoryWindow[
        "filter_active_icon_color"
      ]}
      inactiveIconColor={$selectedCharacter.settings.inventoryWindow[
        "filter_inactive_icon_color"
      ]}
    />
    <FilterButton
      icon="fas fa-shield"
      bind:active={$characterSettings.inventoryWindow.show_worn_armor}
      on:toggle={saveSettings}
      activeTooltip="Hide worn armor"
      inactiveTooltip="Show worn armor"
      activeIconColor={$selectedCharacter.settings.inventoryWindow[
        "filter_active_icon_color"
      ]}
      inactiveIconColor={$selectedCharacter.settings.inventoryWindow[
        "filter_inactive_icon_color"
      ]}
    />
    <FilterButton
      icon="fas fa-sword"
      bind:active={$characterSettings.inventoryWindow.show_worn_weapons}
      on:toggle={saveSettings}
      activeTooltip="Hide worn weapons"
      inactiveTooltip="Show worn weapons"
      activeIconColor={$selectedCharacter.settings.inventoryWindow[
        "filter_active_icon_color"
      ]}
      inactiveIconColor={$selectedCharacter.settings.inventoryWindow[
        "filter_inactive_icon_color"
      ]}
    />
    <FilterButton
      icon="fas fa-ring"
      bind:active={$characterSettings.inventoryWindow.show_worn_jewelry}
      on:toggle={saveSettings}
      activeTooltip="Hide worn jewelry"
      inactiveTooltip="Show worn jewelry"
      activeIconColor={$selectedCharacter.settings.inventoryWindow[
        "filter_active_icon_color"
      ]}
      inactiveIconColor={$selectedCharacter.settings.inventoryWindow[
        "filter_inactive_icon_color"
      ]}
    />
    <FilterButton
      icon="fas fa-certificate"
      bind:active={$characterSettings.inventoryWindow.show_worn_items}
      on:toggle={saveSettings}
      activeTooltip="Hide other worn items"
      inactiveTooltip="Show other worn items"
      activeIconColor={$selectedCharacter.settings.inventoryWindow[
        "filter_active_icon_color"
      ]}
      inactiveIconColor={$selectedCharacter.settings.inventoryWindow[
        "filter_inactive_icon_color"
      ]}
    />
    <FilterButton
      icon="fas fa-rabbit-fast"
      bind:active={$characterSettings.inventoryWindow.show_quick_actions}
      on:toggle={saveSettings}
      activeTooltip="Hide Quick Actions"
      inactiveTooltip="Show Quick Actions"
      activeIconColor={$selectedCharacter.settings.inventoryWindow[
        "filter_active_icon_color"
      ]}
      inactiveIconColor={$selectedCharacter.settings.inventoryWindow[
        "filter_inactive_icon_color"
      ]}
    />
  </div>
  <InventoryItemRightClickMenu {pos} item={menuItem} bind:showMenu />
</div>
