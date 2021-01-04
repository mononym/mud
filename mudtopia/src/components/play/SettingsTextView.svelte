<script>
  import { State } from "./state";
  const {
    characterSettings,
    selectedCharacter,
    resetCharacterSettings,
    saveCharacterSettings,
  } = State;

  $: settingsChanged =
    $characterSettings.system_warning_text_color !=
      $selectedCharacter.settings.system_warning_text_color ||
    $characterSettings.system_alert_text_color !=
      $selectedCharacter.settings.system_alert_text_color ||
    $characterSettings.area_name_text_color !=
      $selectedCharacter.settings.area_name_text_color ||
    $characterSettings.area_description_text_color !=
      $selectedCharacter.settings.area_description_text_color ||
    $characterSettings.character_text_color !=
      $selectedCharacter.settings.character_text_color ||
    $characterSettings.furniture_text_color !=
      $selectedCharacter.settings.furniture_text_color ||
    $characterSettings.exit_text_color !=
      $selectedCharacter.settings.exit_text_color ||
    $characterSettings.denizen_text_color !=
      $selectedCharacter.settings.denizen_text_color;

  function save() {
    // saveArea($areaUnderConstruction);
  }
</script>

<form
  class="container grid grid-cols-8 gap-4"
  on:submit|preventDefault={saveCharacterSettings}>
  <div class="col-span-2">
    <label
      for="color"
      style="color:{$characterSettings.area_name_text_color}"
      class="block text-sm font-medium">[Area Name Text Color]</label>
    <input
      bind:value={$characterSettings.area_name_text_color}
      type="color"
      name="color"
      id="color"
      class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
  </div>
  <div class="col-span-2">
    <label
      for="color"
      style="color:{$characterSettings.area_description_text_color}"
      class="block text-sm font-medium">Area Description Text Color</label>
    <input
      bind:value={$characterSettings.area_description_text_color}
      type="color"
      name="color"
      id="color"
      class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
  </div>
  <div class="col-span-2">
    <label
      for="color"
      style="color:{$characterSettings.system_warning_text_color}"
      class="block text-sm font-medium">***** System Warning Text Color *****</label>
    <input
      bind:value={$characterSettings.system_warning_text_color}
      type="color"
      name="color"
      id="color"
      class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
  </div>
  <div class="col-span-2">
    <label
      for="color"
      style="color:{$characterSettings.system_alert_text_color}"
      class="block text-sm font-medium">***** System Alert Text Color *****</label>
    <input
      bind:value={$characterSettings.system_alert_text_color}
      type="color"
      name="color"
      id="color"
      class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
  </div>
  <div class="col-span-2">
    <label
      for="color"
      style="color:{$characterSettings.character_text_color}"
      class="block text-sm font-medium">Character Text Color</label>
    <input
      bind:value={$characterSettings.character_text_color}
      type="color"
      name="color"
      id="color"
      class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
  </div>
  <div class="col-span-2">
    <label
      for="color"
      style="color:{$characterSettings.furniture_text_color}"
      class="block text-sm font-medium">Furniture Text Color</label>
    <input
      bind:value={$characterSettings.furniture_text_color}
      type="color"
      name="color"
      id="color"
      class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
  </div>
  <div class="col-span-2">
    <label
      for="color"
      style="color:{$characterSettings.exit_text_color}"
      class="block text-sm font-medium">Exit Text Color</label>
    <input
      bind:value={$characterSettings.exit_text_color}
      type="color"
      name="color"
      id="color"
      class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
  </div>
  <div class="col-span-2">
    <label
      for="color"
      style="color:{$characterSettings.denizen_text_color}"
      class="block text-sm font-medium">Denizen Text Color</label>
    <input
      bind:value={$characterSettings.denizen_text_color}
      type="color"
      name="color"
      id="color"
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
