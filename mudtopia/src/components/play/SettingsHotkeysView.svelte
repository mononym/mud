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
  import { State } from "./state";
  const {
    selectedCharacter,
    characterSettings,
    resetCharacterSettings,
    saveCharacterSettings,
  } = State;

  function buildPresetHotkeyString(event, target) {
    $characterSettings.presetHotkeys[target] = buildHotkeyStringFromEvent(
      event
    );
  }

  let customHotkeyIndex = {};
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
    console.log("addNewHotkey");
    const newHotkey = { ...HotkeyState };
    newHotkey.id = uuidv4();
    newHotkey.string = "";
    console.log(newHotkey);
    normalizedCustomHotkeys.push(newHotkey);
    console.log(normalizedCustomHotkeys);
    applyCustomHotkeyChanges();
    normalizeCustomHotkeys();
  }
</script>

<form
  class="flex-1 grid grid-cols-8 gap-4"
  on:submit|preventDefault={saveCharacterSettings}>
  <div class="col-span-2 grid grid-cols-8">
    <h2 class="text-center border-b-2 border-black col-span-8">
      Application Hotkeys
    </h2>
    <div class="col-span-2">
      <label for="openSettings" class="block text-sm font-medium">Open Settings
        Tab</label>
      <input
        on:keydown|preventDefault={(e) => buildPresetHotkeyString(e, 'open_settings')}
        bind:value={$characterSettings.presetHotkeys.open_settings}
        name="openSettings"
        id="openSettings"
        class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
    </div>
    <div class="col-span-2">
      <label for="openPlay" class="block text-sm font-medium">Open Play Tab</label>
      <input
        on:keydown|preventDefault={(e) => buildPresetHotkeyString(e, 'open_play')}
        bind:value={$characterSettings.presetHotkeys.open_play}
        name="openPlay"
        id="openPlay"
        class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
    </div>
  </div>
  <div class="col-span-6 grid grid-cols-8 gap-16">
    <h2 class="text-center border-b-2 border-black col-span-8">
      Custom Hotkeys
    </h2>
    {#each normalizedCustomHotkeys as customHotkey, i}
      <div class="col-span-2 grid grid-cols-9 gap-4">
        <h3 class="text-center border-b-2 border-black col-span-4">Hotkey</h3>
        <h3 class="text-center border-b-2 border-black col-span-4">Command</h3>
        <h3 class="text-center border-b-2 border-black col-span-1">
          <i class="fas fa-trash" />
        </h3>
        <input
          on:keydown|preventDefault={(e) => buildCustomHotkeyString(e, i)}
          bind:value={customHotkey.string}
          name={`${customHotkey.id}-${i}-key`}
          id={`${customHotkey.id}-${i}-key`}
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md col-span-4" />
        <input
          bind:value={customHotkey.command}
          name={`${customHotkey.id}-${i}-cmd`}
          id={`${customHotkey.id}-${i}-cmd`}
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md col-span-4" />
        <button
          on:click|preventDefault={deleteCustomHotkey(customHotkey.id)}
          class="col-span-1 cursor-pointer bg-indigo-600 hover:bg-indigo-700 text-white inline-flex justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-md focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500">
          <i class="fas fa-trash" />
        </button>
      </div>
    {/each}
    <button
      on:click|preventDefault={addNewHotkey}
      class="col-span-8 cursor-pointer bg-indigo-600 hover:bg-indigo-700 text-white inline-flex justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-md focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500">
      New Hotkey
    </button>
  </div>
  <div class="px-4 py-3 text-right sm:px-6">
    <button
      disabled={!settingsChanged}
      type="submit"
      class="{!settingsChanged ? 'bg-indigo-800 text-gray-500 cursor-not-allowed' : 'bg-indigo-600 hover:bg-indigo-700 text-white'} inline-flex justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-md focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500">
      Save
    </button>
    <button
      on:click|preventDefault={resetCharacterSettings}
      class="inline-flex justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500">
      Reset
    </button>
  </div>
</form>
