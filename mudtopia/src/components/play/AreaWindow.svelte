<script>
  import { getContext } from "svelte";
  import { key } from "./state";
  import InventoryItem from "./InventoryItem.svelte";
  import InventoryItemRightClickMenu from "./InventoryItemRightClickMenu.svelte";
  import FilterButton from "./FilterButton.svelte";

  const state = getContext(key);
  const {
    currentArea,
    selectedCharacter,
    onGroundInArea,
    otherCharactersInArea,
    toiInArea,
    characterSettings,
    saveCharacterSettings,
  } = state;

  $: otherCharactersAreInArea = $otherCharactersInArea.length > 0;
  $: hasToiInArea = $toiInArea.length > 0;
  $: hasThingsInArea = $onGroundInArea.length > 0;

  let menuItem;
  let showDescription = true;
  let showOnGround = true;
  let showOtherCharacters = true;
  let showToi = true;

  let windowDiv;

  function toggleDescription() {
    showDescription = !showDescription;
  }

  function toggleOnGround() {
    showOnGround = !showOnGround;
  }

  function toggleAlsoPresent() {
    if (otherCharactersAreInArea) {
      showOtherCharacters = !showOtherCharacters;
    }
  }

  function saveSettings(event) {
    console.log();
    saveCharacterSettings();
  }

  function toggleToi() {
    if (hasToiInArea) {
      showToi = !showToi;
    }
  }

  let showMenu = false;
  let pos = { x: 0, y: 0 };

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
</script>

<div
  class="h-full w-full p-2 flex flex-col"
  bind:this={windowDiv}
  style="background-color:{$selectedCharacter.settings.areaWindow[
    'background'
  ]}"
>
  <pre
    class="cursor-pointer select-none"
    on:click={toggleDescription}
    style="color:{$selectedCharacter.settings.colors[
      'area_name'
    ]}">
    [{$currentArea.name}]
  </pre>
  {#if $selectedCharacter.settings.areaWindow["show_description"]}
    {#if showDescription}
      <pre
        class="whitespace-pre-wrap"
        style="color:{$selectedCharacter.settings.colors[
          'area_description'
        ]}">
      {$currentArea.description}
    </pre>
    {/if}
  {/if}
  {#if $selectedCharacter.settings.areaWindow["show_toi"]}
    <div
      class="cursor-pointer select-none"
      on:click={toggleToi}
      style="color:{$selectedCharacter.settings.colors['toi_label']}"
    >
      <i class="fas fa-{showToi ? 'minus' : 'plus'}" />
      &nbsp;
      <pre class="inline">Things of Interest ({$toiInArea.length})</pre>
    </div>
    {#if showToi}
      {#each $toiInArea as item}
        <div class="ml-4">
          <InventoryItem {item} on:showContextMenu={showRightClickMenu} />
        </div>
      {/each}
    {/if}
  {/if}
  {#if $selectedCharacter.settings.areaWindow["show_on_ground"]}
    <div
      class="cursor-pointer select-none"
      on:click={toggleOnGround}
      style="color:{$selectedCharacter.settings.colors['on_ground_label']}"
    >
      <i class="fas fa-{showOnGround ? 'minus' : 'plus'}" />
      &nbsp;
      <pre class="inline">On Ground ({$onGroundInArea.length})</pre>
    </div>
    {#if showOnGround}
      {#each $onGroundInArea as item}
        <div class="ml-4">
          <InventoryItem {item} on:showContextMenu={showRightClickMenu} />
        </div>
      {/each}
    {/if}
  {/if}
  {#if $selectedCharacter.settings.areaWindow["show_also_present"]}
    <div
      class="{otherCharactersAreInArea
        ? 'cursor-pointer'
        : 'cursor-not-allowed'} select-none"
      on:click={toggleAlsoPresent}
      style="color:{$selectedCharacter.settings.colors['character_label']}"
    >
      <i class="fas fa-{showOtherCharacters ? 'minus' : 'plus'}" />
      &nbsp;
      <pre class="inline">Also Present ({$otherCharactersInArea.length})</pre>
    </div>
    {#if showOtherCharacters}
      {#each $otherCharactersInArea as character}
        <pre class="ml-4">
        {character.name}
      </pre>
      {/each}
    {/if}
  {/if}
  <div class="spacer flex-1" />
  <div
    class="w-full flex"
    style="border:1px solid {$selectedCharacter.settings.areaWindow[
      'filter_border_color'
    ]}"
  >
    <FilterButton
      icon="fas fa-align-left"
      bind:active={$characterSettings.areaWindow.show_description}
      on:toggle={saveSettings}
      activeTooltip="Hide Description"
      inactiveTooltip="Show Description"
      activeIconColor={$selectedCharacter.settings.areaWindow[
        "filter_active_icon_color"
      ]}
      inactiveIconColor={$selectedCharacter.settings.areaWindow[
        "filter_inactive_icon_color"
      ]}
    />
    <FilterButton
      icon="fas fa-map-marker-alt"
      bind:active={$characterSettings.areaWindow.show_toi}
      on:toggle={saveSettings}
      activeTooltip="Hide Things Of Interest"
      inactiveTooltip="Show Things Of Interest"
      activeIconColor={$selectedCharacter.settings.areaWindow[
        "filter_active_icon_color"
      ]}
      inactiveIconColor={$selectedCharacter.settings.areaWindow[
        "filter_inactive_icon_color"
      ]}
    />
    <FilterButton
      icon="fas fa-hand-holding-box fa-rotate-180"
      bind:active={$characterSettings.areaWindow.show_on_ground}
      on:toggle={saveSettings}
      activeTooltip="Hide On Ground"
      inactiveTooltip="Show On Ground"
      activeIconColor={$selectedCharacter.settings.areaWindow[
        "filter_active_icon_color"
      ]}
      inactiveIconColor={$selectedCharacter.settings.areaWindow[
        "filter_inactive_icon_color"
      ]}
    />
    <FilterButton
      icon="fas fa-users"
      bind:active={$characterSettings.areaWindow.show_also_present}
      on:toggle={saveSettings}
      activeTooltip="Hide Also Present"
      inactiveTooltip="Show Also Present"
      activeIconColor={$selectedCharacter.settings.areaWindow[
        "filter_active_icon_color"
      ]}
      inactiveIconColor={$selectedCharacter.settings.areaWindow[
        "filter_inactive_icon_color"
      ]}
    />
    <FilterButton
      icon="fas fa-sign-out"
      bind:active={$characterSettings.areaWindow.show_exits}
      on:toggle={saveSettings}
      activeTooltip="Hide Exits"
      inactiveTooltip="Show Exits"
      activeIconColor={$selectedCharacter.settings.areaWindow[
        "filter_active_icon_color"
      ]}
      inactiveIconColor={$selectedCharacter.settings.areaWindow[
        "filter_inactive_icon_color"
      ]}
    />
  </div>
  <InventoryItemRightClickMenu {pos} item={menuItem} bind:showMenu />
</div>
