<script>
  import { getContext } from "svelte";
  import { key } from "./state";
  import InventoryItem from "./InventoryItem.svelte";
  import InventoryItemRightClickMenu from "./InventoryItemRightClickMenu.svelte";

  const state = getContext(key);
  const {
    currentArea,
    selectedCharacter,
    onGroundInArea,
    otherCharactersInArea,
    toiInArea,
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

<div class="h-full w-full p-2" bind:this={windowDiv}>
  <pre
    class="cursor-pointer select-none"
    on:click={toggleDescription}
    style="color:{$selectedCharacter.settings.colors[
      'area_name'
    ]}">
    [{$currentArea.name}]
  </pre>
  {#if showDescription}
    <pre
      class="whitespace-pre-wrap"
      style="color:{$selectedCharacter.settings.colors[
        'area_description'
      ]}">
      {$currentArea.description}
    </pre>
  {/if}
  <div class="cursor-pointer select-none" on:click={toggleToi}>
    <i class="fas fa-minus" />
    &nbsp;
    <pre
      class="inline"
      style="color:{$selectedCharacter.settings.colors[
        'toi_label'
      ]}">Things of Interest</pre>
  </div>
  {#if showToi}
    {#each $toiInArea as item}
      <div class="ml-4">
        <InventoryItem {item} on:showContextMenu={showRightClickMenu} />
      </div>
    {/each}
  {/if}
  <div class="cursor-pointer select-none" on:click={toggleOnGround}>
    <i class="fas fa-minus" />
    &nbsp;
    <pre
      class="inline"
      style="color:{$selectedCharacter.settings.colors[
        'area_description'
      ]}">On Ground</pre>
  </div>
  {#if showOnGround}
    {#each $onGroundInArea as item}
      <div class="ml-4">
        <InventoryItem {item} on:showContextMenu={showRightClickMenu} />
      </div>
    {/each}
  {/if}
  <div
    class="{otherCharactersAreInArea
      ? 'cursor-pointer'
      : 'cursor-not-allowed'} select-none"
    on:click={toggleAlsoPresent}
  >
    <i class="fas fa-minus" />
    &nbsp;
    <pre class="inline">Also Present</pre>
  </div>
  {#if showOtherCharacters}
    {#each $otherCharactersInArea as character}
      <pre class="ml-4">
        {character.name}
      </pre>
    {/each}
  {/if}
  <InventoryItemRightClickMenu {pos} item={menuItem} bind:showMenu />
</div>
