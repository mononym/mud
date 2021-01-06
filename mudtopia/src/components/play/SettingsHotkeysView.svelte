<script>
  import { buildPresetHotkeyStringFromEvent } from "../../utils/utils";
  import { State } from "./state";
  const {
    selectedCharacter,
    characterSettings,
    resetCharacterSettings,
    saveCharacterSettings,
  } = State;

  function buildPresetHotkeyString(event, target) {
    $characterSettings.presetHotkeys[target] = buildPresetHotkeyStringFromEvent(
      event
    );
  }

  $: $characterSettings.presetHotkeys,
    $characterSettings.customHotkeys,
    checkIfChanged();

  let settingsChanged = false;

  function checkIfChanged() {
    settingsChanged =
      $selectedCharacter.id != "" &&
      $characterSettings.id != "" &&
      ($characterSettings.presetHotkeys.open_settings !=
        $selectedCharacter.settings.presetHotkeys.open_settings ||
        $characterSettings.presetHotkeys.open_play !=
          $selectedCharacter.settings.presetHotkeys.open_play);
  }
</script>

<div
  class="bg-gray-800 text-white border-l-2 rounded-r border-black flex flex-col">
  <h2 class="text-center border-b-2 border-black flex-shrink">
    Application Hotkeys
  </h2>
  <form
    class="flex-1 container grid grid-cols-8 gap-4"
    on:submit|preventDefault={saveCharacterSettings}>
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
</div>
