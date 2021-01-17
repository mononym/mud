<script>
  import Menu from "../Menu.svelte";
  import MenuOption from "../MenuOption.svelte";
  import MenuDivider from "../MenuDivider.svelte";
  import { getContext } from "svelte";
  import { key } from "./state";

  const state = getContext(key);
  const {
    leftHandHasItem,
    rightHandHasItem,
    channel,
    inventoryItemsParentChildIndex,
  } = state;

  export let showMenu = false;
  export let item;
  export let pos = { x: 0, y: 0 };

  function closeMenu() {
    showMenu = false;
  }

  function submitPlayerInput(input) {
    $channel.push("cli", { text: input });
    // commandHistory.unshift(actualInput);

    // actualInput = "";
  }

  function lookAtItem(item) {
    console.log(item);
    submitPlayerInput(`look at ${item.shortDescription}`);
  }

  function getItem(item) {
    console.log(item);
    submitPlayerInput(`get ${item.shortDescription}`);
  }

  function dropItem(item) {
    console.log(item);
    submitPlayerInput(`drop ${item.shortDescription}`);
  }

  function copyShort(item) {
    console.log(item);
    navigator.clipboard.writeText(item.shortDescription);
  }

  function copyLong(item) {
    console.log(item);
    navigator.clipboard.writeText(item.longDescription);
  }

  function closeContainer(item) {
    console.log(item);
    submitPlayerInput(`close ${item.shortDescription}`);
  }

  function openContainer(item) {
    console.log(item);
    submitPlayerInput(`open ${item.shortDescription}`);
  }
</script>

{#if showMenu}
  <Menu {...pos} on:click={closeMenu} on:clickoutside={closeMenu}>
    {#if item.isScenery}
      <MenuOption
        on:click={lookAtItem(item)}
        enabledTooltip="Look at item"
        text="look at"
      />
    {:else if item.areaId != null && item.areaId != ""}
      <MenuOption
        isDisabled={$leftHandHasItem && $rightHandHasItem}
        on:click={getItem(item)}
        enabledTooltip="Pick item up"
        disabledTooltip="Cannot pick item up with full hands"
        text="get"
      />
    {:else if item.wearableIsWorn}
      <MenuOption
        isDisabled={$leftHandHasItem && $rightHandHasItem}
        on:click={console.log}
        enabledTooltip="Take off the worn item"
        disabledTooltip="Cannot remove with full hands"
        text="remove"
      />
    {:else if item.holdableIsHeld && item.isWearable}
      <MenuOption on:click={console.log} text="wear" />
    {:else if item.holdableIsHeld}
      <MenuOption
        on:click={dropItem(item)}
        text="drop"
        enabledTooltip="Drop item on ground"
      />
    {:else if item.containerId != null && item.containerId != undefined && item.containerId != "" && (!$leftHandHasItem || !$rightHandHasItem)}
      <MenuOption
        on:click={getItem(item)}
        enabledTooltip="Remove item from container and hold it"
        disabledTooltip="Cannot get with full hands"
        text="get"
      />
      <MenuOption
        on:click={console.log}
        enabledTooltip="Remove item from container and drop it on the ground"
        disabledTooltip="Cannot discard with full hands"
        text="discard"
      />
    {/if}
    {#if item.isContainer && item.containerOpen}
      <MenuDivider />
      <MenuOption
        on:click={closeContainer(item)}
        enabledTooltip="close"
        text="close the container"
      />
    {:else if item.isContainer && !item.containerOpen}
      <MenuDivider />
      <MenuOption
        on:click={openContainer(item)}
        enabledTooltip="close"
        text="open the container"
      />
    {/if}
    <MenuDivider />
    <MenuOption
      on:click={copyShort(item)}
      enabledTooltip="Copy the short description to the clipboard"
      text="copy short description"
    />
    <MenuOption
      on:click={copyLong(item)}
      enabledTooltip="Copy the long description to the clipboard"
      text="copy long description"
    />
  </Menu>
{/if}
