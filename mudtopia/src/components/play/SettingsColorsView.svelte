<script>
  import { State } from "./state";
  const {
    characterSettings,
    selectedCharacter,
    resetCharacterSettings,
    saveCharacterSettings,
  } = State;

  $: $characterSettings.textColors, checkIfChanged();

  let settingsChanged = false;

  function checkIfChanged() {
    settingsChanged =
      $selectedCharacter.id != "" &&
      $characterSettings.id != "" &&
      ($characterSettings.textColors.system_warning !=
        $selectedCharacter.settings.textColors.system_warning ||
        $characterSettings.textColors.system_alert !=
          $selectedCharacter.settings.textColors.system_alert ||
        $characterSettings.textColors.area_name !=
          $selectedCharacter.settings.textColors.area_name ||
        $characterSettings.textColors.area_description !=
          $selectedCharacter.settings.textColors.area_description ||
        $characterSettings.textColors.character !=
          $selectedCharacter.settings.textColors.character ||
        $characterSettings.textColors.furniture !=
          $selectedCharacter.settings.textColors.furniture ||
        $characterSettings.textColors.exit !=
          $selectedCharacter.settings.textColors.exit ||
        $characterSettings.textColors.denizen !=
          $selectedCharacter.settings.textColors.denizen);
  }
</script>

{#if $characterSettings != undefined}
  <form
    class="container grid grid-cols-8 gap-4"
    on:submit|preventDefault={saveCharacterSettings}>
    <div class="col-span-2">
      <label
        for="color"
        style="color:{$characterSettings.textColors.area_name}"
        class="block text-sm font-medium">[Area Name Text Color]</label>
      <input
        bind:value={$characterSettings.textColors.area_name}
        type="color"
        name="color"
        id="color"
        class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
    </div>
    <div class="col-span-2">
      <label
        for="color"
        style="color:{$characterSettings.textColors.area_description}"
        class="block text-sm font-medium">Area Description Text Color</label>
      <input
        bind:value={$characterSettings.textColors.area_description}
        type="color"
        name="color"
        id="color"
        class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
    </div>
    <div class="col-span-2">
      <label
        for="color"
        style="color:{$characterSettings.textColors.system_warning}"
        class="block text-sm font-medium">***** System Warning Text Color *****</label>
      <input
        bind:value={$characterSettings.textColors.system_warning}
        type="color"
        name="color"
        id="color"
        class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
    </div>
    <div class="col-span-2">
      <label
        for="color"
        style="color:{$characterSettings.textColors.system_alert}"
        class="block text-sm font-medium">***** System Alert Text Color *****</label>
      <input
        bind:value={$characterSettings.textColors.system_alert}
        type="color"
        name="color"
        id="color"
        class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
    </div>
    <div class="col-span-2">
      <label
        for="color"
        style="color:{$characterSettings.textColors.character}"
        class="block text-sm font-medium">Character Text Color</label>
      <input
        bind:value={$characterSettings.textColors.character}
        type="color"
        name="color"
        id="color"
        class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
    </div>
    <div class="col-span-2">
      <label
        for="color"
        style="color:{$characterSettings.textColors.furniture}"
        class="block text-sm font-medium">Furniture Text Color</label>
      <input
        bind:value={$characterSettings.textColors.furniture}
        type="color"
        name="color"
        id="color"
        class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
    </div>
    <div class="col-span-2">
      <label
        for="color"
        style="color:{$characterSettings.textColors.exit}"
        class="block text-sm font-medium">Exit Text Color</label>
      <input
        bind:value={$characterSettings.textColors.exit}
        type="color"
        name="color"
        id="color"
        class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
    </div>
    <div class="col-span-2">
      <label
        for="color"
        style="color:{$characterSettings.textColors.denizen}"
        class="block text-sm font-medium">Denizen Text Color</label>
      <input
        bind:value={$characterSettings.textColors.denizen}
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
{/if}
