<script language="typescript">
  import { push } from "svelte-spa-router";
  import { Circle2 } from "svelte-loading-spinners";
  import { CharactersStore } from "../stores/characters";
  const { characters } = CharactersStore;
  import { createState, key } from "../components/play/state";

  import { onMount, onDestroy, setContext } from "svelte";
  import StoryWindow from "../components/play/StoryWindow.svelte";
  import CommandLineWindow from "../components/play/CommandLineWindow.svelte";
  import LayoutItemWrapper from "../components/play/LayoutItemWrapper.svelte";
  import MapWindow from "../components/play/MapWindow.svelte";
  import InventoryWindow from "../components/play/InventoryWindow.svelte";
  import AreaWindow from "../components/play/AreaWindow.svelte";
  import CompassWindow from "../components/play/CompassWindow.svelte";
  import EnvironmentInfoWindow from "../components/play/EnvironmentInfoWindow.svelte";
  import CharacterStatusWindow from "../components/play/CharacterStatusWindow.svelte";
  import MainTabBar from "../components/play/MainTabBar.svelte";
  import Settings from "../components/play/Settings.svelte";
  import { buildHotkeyStringFromEvent } from "../utils/utils";
  import { prevent_default } from "svelte/internal";

  export let params = {};
  let presetHotkeyCallbacks = {};
  const windows = {};

  // Set up the store to be used by everyone
  const state = createState();
  setContext(key, state);

  const {
    characterInitialized,
    characterInitializing,
    selectedCharacter,
    view,
    currentArea,
    currentMap,
  } = state;

  $: $selectedCharacter.settings.presetHotkeys, generatePresetHotkeyCallbacks();

  onDestroy(() => {
    teardownHotkeyWatcher();
  });

  //
  // Hotkey stuff
  //

  $: $selectedCharacter.settings.presetHotkeys, generatePresetHotkeyCallbacks();

  const presetHotkeyCallbackIndex = {
    open_play: () => state.selectPlayView(),
    open_settings: () => state.selectSettingsView(),
    toggle_history_view: () => state.toggleHistoryWindow(),
    zoom_map_out: () => state.zoom_map_out(),
    zoom_map_in: () => state.zoom_map_in(),
    select_cli: () => document.getElementById("cli").focus(),
  };

  function handleWindowVisibilityToggleEvent(event) {
    console.log("handleWindowVisibilityToggleEvent");
    console.log(event);
    console.log(windows);

    console.log(windows[event.detail]);
    windows[event.detail].toggleVisibility();
  }

  function generatePresetHotkeyCallbacks() {
    const hotkeys = $selectedCharacter.settings.presetHotkeys;
    presetHotkeyCallbacks = {};

    for (const [hotkeyName, hotkeyString] of Object.entries(hotkeys)) {
      presetHotkeyCallbacks[hotkeyString] =
        presetHotkeyCallbackIndex[hotkeyName];
    }
  }

  function setupHotkeyWatcher() {
    window.addEventListener("keydown", maybeHandleApplicationHotkey);
  }

  function teardownHotkeyWatcher() {
    window.removeEventListener("keydown", maybeHandleApplicationHotkey);
  }

  function maybeHandleApplicationHotkey(event) {
    const potentialHotkeyString = buildHotkeyStringFromEvent(event);
    if (potentialHotkeyString in presetHotkeyCallbacks) {
      prevent_default(event);

      presetHotkeyCallbacks[potentialHotkeyString]();
    }
  }

  //
  // UI stuff
  //

  let canvas;
  let element;
  const mouse = {
    x: 0,
    y: 0,
    startX: 0,
    startY: 0,
  };

  function mouseDown(e) {
    if (e.target.id === "container") {
      const rects = [...canvas.querySelectorAll(".selection")];

      if (rects) {
        for (const rect of rects) {
          canvas.removeChild(rect);
        }
      }

      mouse.startX = mouse.x;
      mouse.startY = mouse.y;
      element = document.createElement("div");
      element.className = "selection";
      element.style.border = "1px dashed black";
      element.style.position = "absolute";
      element.style.left = mouse.x + "px";
      element.style.top = mouse.y + "px";
      canvas.appendChild(element);
    }
  }

  function setMousePosition(e) {
    const ev = e || window.event;

    if (ev.pageX) {
      mouse.x = ev.pageX + window.pageXOffset;
      mouse.y = ev.pageY + window.pageYOffset;
    } else if (ev.clientX) {
      mouse.x = ev.clientX + document.body.scrollLeft;
      mouse.y = ev.clientY + document.body.scrollTop;
    }
  }

  function mouseMove(e) {
    setMousePosition(e);
    if (element) {
      element.style.width = Math.abs(mouse.x - mouse.startX) + "px";
      element.style.height = Math.abs(mouse.y - mouse.startY) + "px";
      element.style.left =
        mouse.x - mouse.startX < 0 ? mouse.x + "px" : mouse.startX + "px";
      element.style.top =
        mouse.y - mouse.startY < 0 ? mouse.y + "px" : mouse.startY + "px";
    }
  }

  function mouseUp(e) {
    element = null;

    const rect = canvas.querySelector(".selection");
    const boxes = [...canvas.querySelectorAll(".item")];

    if (rect) {
      const inBounds = [];

      for (const box of boxes) {
        if (isInBounds(rect, box)) {
          inBounds.push(box);
        } else {
          box.style.boxShadow = "none";
          box.classList.remove("selected");
        }
      }

      if (inBounds.length >= 2) {
        for (const box of inBounds) {
          box.style.boxShadow = "0 0 3pt 3pt hsl(141, 53%, 53%)";
          box.classList.add("selected");
        }
      }

      if (rect) canvas.removeChild(canvas.querySelector(".selection"));
    }
  }

  function isInBounds(obj1, obj2) {
    const a = obj1.getBoundingClientRect();
    const b = obj2.getBoundingClientRect();

    return (
      a.x < b.x + b.width &&
      a.x + a.width > b.x &&
      a.y < b.y + b.height &&
      a.y + a.height > b.y
    );
  }

  let wrapper;

  let startingMapWidth;
  let startingMapHeight;
  let startingMapX;
  let startingMapY;

  let startingInventoryWidth;
  let startingInventoryHeight;
  let startingInventoryX;
  let startingInventoryY;

  let startingStoryWidth;
  let startingStoryHeight;
  let startingStoryX;
  let startingStoryY;

  let startingCliWidth;
  let startingCliHeight;
  let startingCliX;
  let startingCliY;

  let startingAreaWidth;
  let startingAreaHeight;
  let startingAreaX;
  let startingAreaY;

  let startingCompassWidth;
  let startingCompassHeight;
  let startingCompassX;
  let startingCompassY;

  let startingEnvironmentInfoWidth;
  let startingEnvironmentInfoHeight;
  let startingEnvironmentInfoX;
  let startingEnvironmentInfoY;

  let startingStatusWidth;
  let startingStatusHeight;
  let startingStatusX;
  let startingStatusY;

  onMount(async () => {
    console.log(wrapper.offsetHeight);
    console.log(wrapper.height);
    console.log(wrapper.clientY);
    console.log(wrapper.getBoundingClientRect());
    startingMapWidth = Math.floor(wrapper.offsetWidth * 0.3).toString();
    startingMapHeight = Math.floor(
      (wrapper.offsetHeight - 38) * 0.5
    ).toString();
    startingMapX = "0";
    startingMapY = "0";

    startingInventoryWidth = Math.floor(wrapper.offsetWidth * 0.3).toString();
    startingInventoryHeight = Math.floor(
      (wrapper.offsetHeight - 38) * 0.5
    ).toString();
    startingInventoryX = "0";
    startingInventoryY = Math.floor(
      (wrapper.offsetHeight - 38) * 0.5
    ).toString();

    startingStoryWidth = Math.floor(wrapper.offsetWidth * 0.4).toString();
    startingStoryHeight = Math.floor(wrapper.offsetHeight - 118).toString();
    startingStoryX = Math.floor(wrapper.offsetWidth * 0.3).toString();
    startingStoryY = "0";

    startingCliWidth = Math.floor(wrapper.offsetWidth * 0.4).toString();
    startingCliHeight = Math.floor(80).toString();
    startingCliX = Math.floor(wrapper.offsetWidth * 0.3).toString();
    startingCliY = Math.floor(wrapper.offsetHeight - 118).toString();

    startingAreaWidth = Math.floor(wrapper.offsetWidth * 0.3).toString();
    startingAreaHeight = wrapper.offsetHeight - 238;
    startingAreaX = Math.floor(wrapper.offsetWidth * 0.7).toString();
    startingAreaY = "0";

    startingCompassWidth = Math.floor(wrapper.offsetWidth * 0.1).toString();
    startingCompassHeight = "200";
    startingCompassX = Math.floor(wrapper.offsetWidth * 0.7).toString();
    startingCompassY = Math.floor(wrapper.offsetHeight - 238).toString();

    startingEnvironmentInfoWidth = Math.floor(
      wrapper.offsetWidth * 0.1
    ).toString();
    startingEnvironmentInfoHeight = "200";
    startingEnvironmentInfoX = Math.floor(
      wrapper.offsetWidth * 0.7 + wrapper.offsetWidth * 0.1
    ).toString();
    startingEnvironmentInfoY = Math.floor(
      wrapper.offsetHeight - 238
    ).toString();

    startingStatusWidth = Math.floor(wrapper.offsetWidth * 0.1).toString();
    startingStatusHeight = "200";
    startingStatusX = Math.floor(
      wrapper.offsetWidth * 0.7 + wrapper.offsetWidth * 0.2
    ).toString();
    startingStatusY = Math.floor(wrapper.offsetHeight - 238).toString();

    const character = $characters.filter(
      (character) => character.id == params.characterId
    )[0];

    // Happens if loaded up into this page rather than into dashboard first
    if (character == undefined) {
      push("#/dashboard");
      return;
    }

    await state.startGameSession(character.id);
    await state.initializeCharacter(character);
    generatePresetHotkeyCallbacks();
    setupHotkeyWatcher();
  });
</script>

<div
  bind:this={wrapper}
  class="h-full w-full flex flex-col overflow-hidden bg-gray-900"
>
  {#if !$characterInitialized || $characterInitializing}
    <div class="flex-1 flex flex-col justify-center items-center">
      <Circle2 />
      <h2 class="mt-6 text-center text-3xl font-extrabold text-gray-500">
        Initializing
        {$selectedCharacter.name == "" ? "Character" : $selectedCharacter.name}
      </h2>
    </div>
  {:else if $characterInitialized}
    <MainTabBar on:toggleWindowVisibility={handleWindowVisibilityToggleEvent} />
    <div
      bind:this={canvas}
      hidden={$view != "play"}
      id="container"
      class="flex-1 bg-gray-900 relative"
      on:mouseup={mouseUp}
      on:mousedown={mouseDown}
      on:mousemove={mouseMove}
    >
      <LayoutItemWrapper
        id="commandLineWindow"
        label="Command Input"
        bind:initialHeight={startingCliHeight}
        bind:initialWidth={startingCliWidth}
        bind:initialX={startingCliX}
        bind:initialY={startingCliY}
        zIndex="1"
      >
        <CommandLineWindow />
      </LayoutItemWrapper>
      <LayoutItemWrapper
        id="storyWindowWrapper"
        label="Main Story"
        bind:initialHeight={startingStoryHeight}
        bind:initialWidth={startingStoryWidth}
        bind:initialX={startingStoryX}
        bind:initialY={startingStoryY}
        zIndex="2"
      >
        <StoryWindow />
      </LayoutItemWrapper>
      <LayoutItemWrapper
        id="clientMapWindow"
        label={$currentMap.name}
        bind:initialHeight={startingMapHeight}
        bind:initialWidth={startingMapWidth}
        bind:initialX={startingMapX}
        bind:initialY={startingMapY}
        zIndex="3"
        bind:this={windows["map"]}
      >
        <MapWindow />
      </LayoutItemWrapper>
      <LayoutItemWrapper
        id="inventoryWindow"
        label="Inventory"
        bind:initialHeight={startingInventoryHeight}
        bind:initialWidth={startingInventoryWidth}
        bind:initialX={startingInventoryX}
        bind:initialY={startingInventoryY}
        zIndex="4"
        bind:this={windows["inventory"]}
      >
        <InventoryWindow />
      </LayoutItemWrapper>
      <LayoutItemWrapper
        id="areaWindow"
        label={$currentArea.name}
        bind:initialHeight={startingAreaHeight}
        bind:initialWidth={startingAreaWidth}
        bind:initialX={startingAreaX}
        bind:initialY={startingAreaY}
        zIndex="8"
        bind:this={windows["area"]}
      >
        <AreaWindow />
      </LayoutItemWrapper>
      <LayoutItemWrapper
        id="compassWindow"
        label="Directions"
        bind:initialHeight={startingCompassHeight}
        bind:initialWidth={startingCompassWidth}
        bind:initialX={startingCompassX}
        bind:initialY={startingCompassY}
        zIndex="6"
        bind:this={windows["compass"]}
      >
        <CompassWindow />
      </LayoutItemWrapper>
      <LayoutItemWrapper
        id="environmentInfoWindow"
        label="Environment"
        bind:initialHeight={startingEnvironmentInfoHeight}
        bind:initialWidth={startingEnvironmentInfoWidth}
        bind:initialX={startingEnvironmentInfoX}
        bind:initialY={startingEnvironmentInfoY}
        zIndex="7"
        bind:this={windows["environment"]}
      >
        <EnvironmentInfoWindow />
      </LayoutItemWrapper>
      <LayoutItemWrapper
        id="characterStatusWindow"
        label="Status"
        bind:initialHeight={startingStatusHeight}
        bind:initialWidth={startingStatusWidth}
        bind:initialX={startingStatusX}
        bind:initialY={startingStatusY}
        zIndex="5"
        bind:this={windows["status"]}
      >
        <CharacterStatusWindow />
      </LayoutItemWrapper>
    </div>
    {#if $view == "settings"}
      <Settings />
    {/if}
  {/if}
</div>
