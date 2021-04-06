<script>
  import { v4 as uuidv4 } from "uuid";
  import * as _ from "lodash";
  import { onMount } from "svelte";
  import HotkeyState from "../../models/hotkey";
  import {
    buildHotkeyStringFromEvent,
    buildHotkeyStringFromRecord,
    buildRecordFromHotkeyString,
  } from "../../utils/utils";
  import { getContext } from "svelte";
  import { key } from "./state";

  const state = getContext(key);
  const {
    characterSettings,
    resetCharacterSettings,
    saveCharacterSettings,
  } = state;

  function buildPresetHotkeyString(event, target) {
    $characterSettings.presetHotkeys[target] = buildHotkeyStringFromEvent(
      event
    );
  }

  let normalizedCustomHotkeys = [];

  function normalizeCustomHotkeys() {
    let newHotkeys = [];
    $characterSettings.customHotkeys.forEach((hotkey) => {
      const hotkeyString = buildHotkeyStringFromRecord(hotkey);
      hotkey.string = hotkeyString;
      newHotkeys.push(hotkey);
    });

    normalizedCustomHotkeys = newHotkeys;
  }

  function buildCustomHotkeyString(event, index) {
    normalizedCustomHotkeys[index].string = buildHotkeyStringFromEvent(event);
  }

  $: normalizedCustomHotkeys, applyCustomHotkeyChanges();

  function applyCustomHotkeyChanges() {
    if (normalizedCustomHotkeys.length == 0) {
      return;
    }

    const newHotkeys = normalizedCustomHotkeys.map((customHotkey) => {
      const newHotkey = buildRecordFromHotkeyString(customHotkey.string);
      newHotkey.id = customHotkey.id;
      newHotkey.command = customHotkey.command;
      return newHotkey;
    });

    characterSettings.update(function (settings) {
      settings.customHotkeys = newHotkeys;
      return settings;
    });
  }

  // Just always allow saving for now, not worth effort initially
  let settingsChanged = true;

  onMount(() => {
    normalizeCustomHotkeys();
  });

  function deleteCustomHotkey(customHotkeyId) {
    let newHotkeys = [];
    $characterSettings.customHotkeys.forEach((hotkey) => {
      if (hotkey.id == customHotkeyId) {
        return;
      }

      const hotkeyString = buildHotkeyStringFromRecord(hotkey);
      hotkey.string = hotkeyString;
      newHotkeys.push(hotkey);
    });

    normalizedCustomHotkeys = newHotkeys;
  }

  function addNewHotkey() {
    const newHotkey = { ...HotkeyState };
    newHotkey.id = uuidv4();
    newHotkey.string = "";
    normalizedCustomHotkeys.push(newHotkey);
    applyCustomHotkeyChanges();
    normalizeCustomHotkeys();
  }
</script>

<form
  class="flex-1 grid grid-cols-8 gap-4"
  on:submit|preventDefault={saveCharacterSettings}
>
  <div class="col-span-2 grid grid-cols-8">
    <h2 class="text-center border-b-2 border-primary col-span-8 text-gray-300">
      Application Hotkeys
    </h2>
    <div class="col-span-2">
      <label for="openSettings" class="block text-sm font-medium text-gray-300"
        >Open Settings Tab</label
      >
      <input
        on:keydown|preventDefault={(e) =>
          buildPresetHotkeyString(e, "open_settings")}
        bind:value={$characterSettings.presetHotkeys.open_settings}
        name="openSettings"
        id="openSettings"
        class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
      />
    </div>
    <div class="col-span-2">
      <label for="openPlay" class="block text-sm font-medium text-gray-300"
        >Open Play Tab</label
      >
      <input
        on:keydown|preventDefault={(e) =>
          buildPresetHotkeyString(e, "open_play")}
        bind:value={$characterSettings.presetHotkeys.open_play}
        name="openPlay"
        id="openPlay"
        class="mt-1 bg-gray-400 text-black0 focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
      />
    </div>
    <div class="col-span-2">
      <label for="toggleHistory" class="block text-sm font-medium text-gray-300"
        >Toggle History View in Story Window</label
      >
      <input
        on:keydown|preventDefault={(e) =>
          buildPresetHotkeyString(e, "toggle_history_view")}
        bind:value={$characterSettings.presetHotkeys.toggle_history_view}
        name="toggleHistory"
        id="toggleHistory"
        class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
      />
    </div>
    <div class="col-span-2">
      <label for="selectCli" class="block text-sm font-medium text-gray-300"
        >Select Commandline</label
      >
      <input
        on:keydown|preventDefault={(e) =>
          buildPresetHotkeyString(e, "select_cli")}
        bind:value={$characterSettings.presetHotkeys.select_cli}
        name="selectCli"
        id="selectCli"
        class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
      />
    </div>
  </div>
  <div class="col-span-6 grid grid-cols-8 gap-16">
    <h2 class="text-center border-b-2 border-primary col-span-8 text-gray-300">
      Custom Hotkeys
    </h2>
    {#each normalizedCustomHotkeys as customHotkey, i}
      <div class="col-span-2 grid grid-cols-9 gap-4">
        <h3
          class="text-center border-b-2 border-primary col-span-4 text-gray-300"
        >
          Hotkey
        </h3>
        <h3
          class="text-center border-b-2 border-primary col-span-4 text-gray-300"
        >
          Command
        </h3>
        <h3
          class="text-center border-b-2 border-primary col-span-1 text-gray-300"
        >
          &nbsp;
        </h3>
        <input
          on:keydown|preventDefault={(e) => buildCustomHotkeyString(e, i)}
          bind:value={customHotkey.string}
          name={`${customHotkey.id}-${i}-key`}
          id={`${customHotkey.id}-${i}-key`}
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md col-span-4"
        />
        <input
          bind:value={customHotkey.command}
          name={`${customHotkey.id}-${i}-cmd`}
          id={`${customHotkey.id}-${i}-cmd`}
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md col-span-4"
        />
        <button
          on:click|preventDefault={deleteCustomHotkey(customHotkey.id)}
          class="col-span-1 cursor-pointer bg-red-500 hover:bg-red-400 hover:text-black text-gray-300 inline-flex justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-md focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
        >
          <i class="fas fa-trash" />
        </button>
      </div>
    {/each}
    <div class="col-span-8 flex justify-center">
      <button
        on:click|preventDefault={addNewHotkey}
        class="cursor-pointer bg-primary hover:bg-primary-light text-black inline-flex justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-md focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-dark"
      >
        New Hotkey
      </button>
    </div>
  </div>
  <div class="px-4 py-3 text-right sm:px-6">
    <button
      disabled={!settingsChanged}
      type="submit"
      class="{!settingsChanged
        ? 'bg-primary-dark text-black cursor-not-allowed'
        : 'bg-primary hover:bg-primary-light text-black'} inline-flex justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-md focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-dark"
    >
      Save
    </button>
    <button
      on:click|preventDefault={resetCharacterSettings}
      class="bg-primary hover:bg-primary-light text-black inline-flex justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-md focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-dark"
    >
      Reset
    </button>
  </div>
</form>
