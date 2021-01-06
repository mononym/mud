<script language="typescript">
  import { push } from "svelte-spa-router";
  import { Circle2 } from "svelte-loading-spinners";
  import { CharactersStore } from "../stores/characters";
  const { characters } = CharactersStore;
  import { State } from "../components/play/state";
  const {
    characterInitialized,
    characterInitializing,
    selectedCharacter,
    view,
    selectSettingsView,
    selectPlayView,
  } = State;

  import { onMount, onDestroy } from "svelte";
  import StoryWindow from "../components/play/StoryWindow.svelte";
  import CommandLineWindow from "../components/play/CommandLineWindow.svelte";
  import LayoutItemWrapper from "../components/play/LayoutItemWrapper.svelte";
  import MainTabBar from "../components/play/MainTabBar.svelte";
  import Settings from "../components/play/Settings.svelte";
  import { buildPresetHotkeyStringFromEvent } from "../utils/utils";
  import { prevent_default } from "svelte/internal";

  export let params = {};

  let presetHotkeyCallbacks = {};

  onMount(async () => {
    const character = $characters.filter(
      (character) => character.id == params.characterId
    )[0];

    // Happens if loaded up into this page rather than into dashboard first
    if (character == undefined) {
      console.log("pushing dashboard");
      push("#/dashboard");
      return;
    }

    console.log("playing character");
    console.log(character);

    await State.startGameSession(character.id);
    await State.initializeCharacter(character);
    generatePresetHotkeyCallbacks();
    setupHotkeyWatcher();
  });

  onDestroy(() => {
    teardownHotkeyWatcher();
  });

  //
  // Hotkey stuff
  //

  $: $selectedCharacter.settings.presetHotkeys, generatePresetHotkeyCallbacks();

  const presetHotkeyCallbackIndex = {
    open_play: () => State.selectPlayView(),
    open_settings: () => State.selectSettingsView(),
  };

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
    const potentialHotkeyString = buildPresetHotkeyStringFromEvent(event);
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
</script>

<div class="h-full w-full flex flex-col overflow-hidden">
  {#if !$characterInitialized || $characterInitializing}
    <div class="flex-1 flex flex-col justify-center items-center">
      <Circle2 />
      <h2 class="mt-6 text-center text-3xl font-extrabold text-gray-500">
        Initializing
        {$selectedCharacter.name == '' ? 'Character' : $selectedCharacter.name}
      </h2>
    </div>
  {:else if $characterInitialized}
    <MainTabBar />
    <div
      bind:this={canvas}
      hidden={$view != 'play'}
      id="container"
      class="flex-1 bg-gray-200 relative"
      on:mouseup={mouseUp}
      on:mousedown={mouseDown}
      on:mousemove={mouseMove}>
      <LayoutItemWrapper id="commandLineWindow" label="Command Input">
        <CommandLineWindow />
      </LayoutItemWrapper>
      <LayoutItemWrapper id="storyWindowWrapper" label="Main Story">
        <StoryWindow />
      </LayoutItemWrapper>
    </div>
    <Settings />
  {/if}
</div>
