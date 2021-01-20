<script>
  import { getContext, tick, afterUpdate } from "svelte";
  import { key } from "./state";
  import InventoryItem from "./InventoryItem.svelte";
  import InventoryItemRightClickMenu from "./InventoryItemRightClickMenu.svelte";
  import FilterButton from "./FilterButton.svelte";
  import QuickAction from "./QuickAction.svelte";
  import tippy from "tippy.js";
  import "tippy.js/dist/tippy.css";
  import { getItemColor } from "../../utils/utils";

  const state = getContext(key);
  const {
    currentArea,
    selectedCharacter,
    onGroundInArea,
    otherCharactersInArea,
    toiInArea,
    characterSettings,
    saveCharacterSettings,
    exitsInArea,
    rightHandHasItem,
    leftHandHasItem,
  } = state;

  $: otherCharactersAreInArea = $otherCharactersInArea.length > 0;
  $: hasToiInArea = $toiInArea.length > 0;
  $: hasThingsOnGround = $onGroundInArea.length > 0;
  $: hasExitsInArea = $exitsInArea.length > 0;

  let menuItem;
  let showDescription = true;
  let showOnGround = true;
  let showOtherCharacters = true;
  let showToi = true;
  let showExits = true;

  let windowDiv;

  afterUpdate(() => {
    tippy("[data-tippy-content]");
  });

  let lastAreaId;
  $: $currentArea, maybeHandleToggles();
  async function maybeHandleToggles() {
    console.log("maybeHandleToggles");
    await tick();

    if (lastAreaId != $currentArea.id) {
      lastAreaId = $currentArea.id;

      runThroughToggles();
    }
  }

  function runThroughToggles() {
    let runningTotal = 0;

    switch ($selectedCharacter.settings.areaWindow.description_expansion_mode) {
      case "close":
        showDescription = false;
        break;
      case "open":
        showDescription = true;
        break;
      default:
        break;
    }

    switch ($selectedCharacter.settings.areaWindow.toi_expansion_mode) {
      case "close":
        showToi = false;
        break;
      case "open":
        runningTotal += $toiInArea.length;
        showToi = true;
        break;
      case "open-threshold":
      case "manual-threshold":
        if (
          $toiInArea.length >
          $selectedCharacter.settings.areaWindow.toi_collapse_threshold
        ) {
          showToi = false;
        } else {
          runningTotal += $toiInArea.length;
        }
        break;
      default:
        break;
    }

    switch ($selectedCharacter.settings.areaWindow.on_ground_expansion_mode) {
      case "close":
        showOnGround = false;
        break;
      case "open":
        runningTotal += $onGroundInArea.length;
        showOnGround = true;
        break;
      case "open-threshold":
      case "manual-threshold":
        if (
          $onGroundInArea.length >
          $selectedCharacter.settings.areaWindow.on_ground_collapse_threshold
        ) {
          showOnGround = false;
        } else {
          runningTotal += $onGroundInArea.length;
        }
        break;
      default:
        break;
    }

    switch (
      $selectedCharacter.settings.areaWindow.also_present_expansion_mode
    ) {
      case "close":
        showOtherCharacters = false;
        break;
      case "open":
        runningTotal += $otherCharactersInArea.length;
        showOtherCharacters = true;
        break;
      case "open-threshold":
      case "manual-threshold":
        if (
          $otherCharactersInArea.length >
          $selectedCharacter.settings.areaWindow.also_present_collapse_threshold
        ) {
          showOtherCharacters = false;
        } else {
          runningTotal += $otherCharactersInArea.length;
        }
        break;
      default:
        break;
    }

    switch ($selectedCharacter.settings.areaWindow.exits_expansion_mode) {
      case "close":
        showExits = false;
        break;
      case "open":
        runningTotal += $exitsInArea.length;
        showExits = true;
        break;
      case "open-threshold":
      case "manual-threshold":
        if (
          $exitsInArea.length >
          $selectedCharacter.settings.areaWindow.exits_collapse_threshold
        ) {
          showExits = false;
        } else {
          runningTotal += $exitsInArea.length;
        }
        break;
      default:
        break;
    }

    if (
      $selectedCharacter.settings.areaWindow.total_collapse_mode != "none" &&
      $selectedCharacter.settings.areaWindow.total_count_collapse_threshold <
        runningTotal
    ) {
      var l = [];
      l.push({
        count: $toiInArea.length,
        callback: () => {
          showToi = false;
        },
      });
      l.push({
        count: $onGroundInArea.length,
        callback: () => {
          showOnGround = false;
        },
      });
      l.push({
        count: $otherCharactersInArea.length,
        callback: () => {
          showOtherCharacters = false;
        },
      });
      l.push({
        count: $exitsInArea.length,
        callback: () => {
          showExits = false;
        },
      });

      switch ($selectedCharacter.settings.areaWindow.total_collapse_mode) {
        case "largest":
          l.sort(function (a, b) {
            return a.count - b.count;
          });

          closeUntilBelowThreshold(l, runningTotal);
          break;
        case "smallest":
          l.sort(function (a, b) {
            return b.count - a.count;
          });

          closeUntilBelowThreshold(l, runningTotal);
          break;
        case "all":
          showDescription = false;
          showOnGround = false;
          showOtherCharacters = false;
          showToi = false;
          showExits = false;
          break;
        default:
          break;
      }
    }
  }

  function closeUntilBelowThreshold(list, runningTotal) {
    if (
      runningTotal >
      $selectedCharacter.settings.areaWindow.total_count_collapse_threshold
    ) {
      const val = list.pop();
      val.callback();
      closeUntilBelowThreshold(list, runningTotal - val.count);
    }
  }

  function toggleDescription() {
    showDescription = !showDescription;
  }

  function toggleOnGround() {
    if (hasThingsOnGround) {
      showOnGround = !showOnGround;
    }
  }

  function toggleAlsoPresent() {
    if (otherCharactersAreInArea) {
      showOtherCharacters = !showOtherCharacters;
    }
  }

  function toggleExits() {
    if (hasExitsInArea) {
      showExits = !showExits;
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
      <i class="fas fa-{showToi ? 'minus' : 'plus'} fa-fw" />
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
      <i class="fas fa-{showOnGround ? 'minus' : 'plus'} fa-fw" />
      &nbsp;
      <pre class="inline">On Ground ({$onGroundInArea.length})</pre>
    </div>
    {#if showOnGround}
      {#each $onGroundInArea as item}
        <div
          class="flex space-x-1"
          style="color:{$selectedCharacter.settings.colors['exit']}"
        >
          &nbsp; &nbsp;
          {#if $selectedCharacter.settings.areaWindow["show_quick_actions"]}
            <QuickAction
              icon="fas fa-hand-rock"
              active={!$leftHandHasItem || !$rightHandHasItem}
              activeTooltip="get"
              inactiveTooltip="Hands are full"
              cliInput="get {item.id}"
              storyOutput="get {item.shortDescription}"
              activeIconColor={getItemColor(
                $selectedCharacter.settings.colors,
                item
              )}
              inactiveIconColor={$selectedCharacter.settings.areaWindow[
                "disabled_quick_action_color"
              ]}
            />
            &nbsp; &nbsp;
          {/if}
          <InventoryItem {item} on:showContextMenu={showRightClickMenu} />
        </div>
        <div class="ml-4" />
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
      <i class="fas fa-{showOtherCharacters ? 'minus' : 'plus'} fa-fw" />
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
  {#if $selectedCharacter.settings.areaWindow["show_exits"]}
    <div
      class="{hasExitsInArea
        ? 'cursor-pointer'
        : 'cursor-not-allowed'} select-none"
      on:click={toggleExits}
      style="color:{$selectedCharacter.settings.colors['exit_label']}"
    >
      <i class="fas fa-{showExits ? 'minus' : 'plus'} fa-fw" />
      &nbsp;
      <pre class="inline">Exits ({$exitsInArea.length})</pre>
    </div>
    {#if showExits}
      {#each $exitsInArea as link}
        <div
          class="flex"
          style="color:{$selectedCharacter.settings.colors['exit']}"
        >
          &nbsp; &nbsp;
          {#if $selectedCharacter.settings.areaWindow["show_quick_actions"]}
            <QuickAction
              icon="fas fa-sign-out"
              activeTooltip="go"
              cliInput="go {link.id}"
              storyOutput="go {link.shortDescription}"
              activeIconColor={$selectedCharacter.settings.colors["exit"]}
              inactiveIconColor={$selectedCharacter.settings.areaWindow[
                "disabled_quick_action_color"
              ]}
            />
            <i
              class="fas fa-eye fa-lg fa-fw ml-1 self-center"
              data-tippy-content="peer"
            />
            &nbsp; &nbsp;
          {/if}
          <pre>{link.shortDescription}</pre>
        </div>
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
    <FilterButton
      icon="fas fa-rabbit-fast"
      bind:active={$characterSettings.areaWindow.show_quick_actions}
      on:toggle={saveSettings}
      activeTooltip="Hide Quick Actions"
      inactiveTooltip="Show Quick Actions"
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
