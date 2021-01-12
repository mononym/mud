<script>
  import { getContext } from "svelte";
  import { key } from "./state";

  const state = getContext(key);
  const {
    characterSettings,
    resetCharacterSettings,
    saveCharacterSettings,
  } = state;

  let settingsChanged = true;
</script>

{#if $characterSettings != undefined}
  <form
    class="container grid grid-cols-8 gap-4"
    on:submit|preventDefault={saveCharacterSettings}>
    <div class="col-span-4 grid grid-cols-8 gap-4">
      <h2 class="text-center text-white border-b-2 border-black col-span-8">
        Command Input Colors
      </h2>
      <div class="col-span-4">
        <label
          for="inputBackgroundColor"
          style="color:{$characterSettings.colors.input_background}"
          class="block text-sm font-medium">Command Input Background Color</label>
        <input
          bind:value={$characterSettings.colors.input_background}
          type="color"
          name="inputBackgroundColor"
          id="inputBackgroundColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
      </div>
      <div class="col-span-4">
        <label
          for="inputTextColor"
          style="color:{$characterSettings.colors.input}"
          class="block text-sm font-medium">Input Text Color</label>
        <input
          bind:value={$characterSettings.colors.input}
          type="color"
          name="inputTextColor"
          id="inputTextColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
      </div>
      <div class="col-span-4">
        <label
          for="inputButtonBackgroundColor"
          style="color:{$characterSettings.colors.input_button_background}"
          class="block text-sm font-medium">Input Button Background Color</label>
        <input
          bind:value={$characterSettings.colors.input_button_background}
          type="color"
          name="inputButtonBackgroundColor"
          id="inputButtonBackgroundColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
      </div>
      <div class="col-span-4">
        <label
          for="inputButtonIconColor"
          style="color:{$characterSettings.colors.input_button_icon}"
          class="block text-sm font-medium">Input Button Icon Color</label>
        <input
          bind:value={$characterSettings.colors.input_button_icon}
          type="color"
          name="inputButtonIconColor"
          id="inputButtonIconColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
      </div>
    </div>
    <div class="col-span-4 grid grid-cols-6 gap-4">
      <h2 class="text-center text-white border-b-2 border-black col-span-6">
        Story Window Colors
      </h2>
      <div class="col-span-2">
        <label
          for="storyBackgroundColor"
          style="color:{$characterSettings.colors.story_background}"
          class="block text-sm font-medium">Story Window Background Color</label>
        <input
          bind:value={$characterSettings.colors.story_background}
          type="color"
          name="storyBackgroundColor"
          id="storyBackgroundColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
      </div>
      <div class="col-span-2">
        <label
          for="storyHistoryIconColor"
          style="color:{$characterSettings.colors.story_history_icon}"
          class="block text-sm font-medium">Story Window History Icon Color</label>
        <input
          bind:value={$characterSettings.colors.story_history_icon}
          type="color"
          name="storyHistoryIconColor"
          id="storyHistoryIconColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
      </div>
      <div class="col-span-2">
        <label
          for="storyHistoryBorderColor"
          style="color:{$characterSettings.colors.story_history_border}"
          class="block text-sm font-medium">Story Window History Window Border</label>
        <input
          bind:value={$characterSettings.colors.story_history_border}
          type="color"
          name="storyHistoryBorderColor"
          id="storyHistoryBorderColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
      </div>
    </div>

    <div class="col-span-4 grid grid-cols-6 gap-4">
      <h2 class="text-center text-white border-b-2 border-black col-span-6">
        UI Colors
      </h2>
      <div class="col-span-2">
        <label
          for="windowToolbarColor"
          style="color:{$characterSettings.colors.window_toolbar_background}"
          class="block text-sm font-medium">Window Toolbar Color</label>
        <input
          bind:value={$characterSettings.colors.window_toolbar_background}
          type="color"
          name="windowToolbarColor"
          id="windowToolbarColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
      </div>
      <div class="col-span-2">
        <label
          for="windowToolbarLabelColor"
          style="color:{$characterSettings.colors.window_toolbar_label}"
          class="block text-sm font-medium">Window Toolbar Label Color</label>
        <input
          bind:value={$characterSettings.colors.window_toolbar_label}
          type="color"
          name="windowToolbarLabelColor"
          id="windowToolbarLabelColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
      </div>
      <div class="col-span-2">
        <label
          for="windowUnlockedColor"
          style="color:{$characterSettings.colors.window_lock_unlocked}"
          class="block text-sm font-medium">Window Lock Icon Unlocked</label>
        <input
          bind:value={$characterSettings.colors.window_lock_unlocked}
          type="color"
          name="windowUnlockedColor"
          id="windowUnlockedColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
      </div>
      <div class="col-span-2">
        <label
          for="windowLockedColor"
          style="color:{$characterSettings.colors.window_lock_locked}"
          class="block text-sm font-medium">Window Lock Icon Unlocked</label>
        <input
          bind:value={$characterSettings.colors.window_lock_locked}
          type="color"
          name="windowLockedColor"
          id="windowLockedColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
      </div>
      <div class="col-span-2">
        <label
          for="windowMoveUnlockedColor"
          style="color:{$characterSettings.colors.window_move_unlocked}"
          class="block text-sm font-medium">Window Move Icon Unlocked</label>
        <input
          bind:value={$characterSettings.colors.window_move_unlocked}
          type="color"
          name="windowMoveUnlockedColor"
          id="windowMoveUnlockedColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
      </div>
      <div class="col-span-2">
        <label
          for="windowMoveLockedColor"
          style="color:{$characterSettings.colors.window_move_locked}"
          class="block text-sm font-medium">Window Move Icon locked</label>
        <input
          bind:value={$characterSettings.colors.window_move_locked}
          type="color"
          name="windowMoveLockedColor"
          id="windowMoveLockedColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
      </div>
    </div>

    <div class="col-span-4 grid grid-cols-4 gap-4">
      <h2 class="text-center text-white border-b-2 border-black col-span-4">
        Text Colors
      </h2>
      <div class="col-span-2">
        <label
          for="baseTextColor"
          style="color:{$characterSettings.colors.base}"
          class="block text-sm font-medium">Base Text Color</label>
        <input
          bind:value={$characterSettings.colors.base}
          type="color"
          name="baseTextColor"
          id="baseTextColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
      </div>
      <div class="col-span-2">
        <label
          for="toiLabelTextColor"
          style="color:{$characterSettings.colors.toi_label}"
          class="block text-sm font-medium">'Things of Interest' Label Text
          Color</label>
        <input
          bind:value={$characterSettings.colors.toi_label}
          type="color"
          name="toiLabelTextColor"
          id="toiLabelTextColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
      </div>
      <div class="col-span-2">
        <label
          for="areaNameTextColor"
          style="color:{$characterSettings.colors.area_name}"
          class="block text-sm font-medium">[Area Name Text Color]</label>
        <input
          bind:value={$characterSettings.colors.area_name}
          type="color"
          name="areaNameTextColor"
          id="areaNameTextColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
      </div>
      <div class="col-span-2">
        <label
          for="areaDescTextColor"
          style="color:{$characterSettings.colors.area_description}"
          class="block text-sm font-medium">Area Description Text Color</label>
        <input
          bind:value={$characterSettings.colors.area_description}
          type="color"
          name="areaDescTextColor"
          id="areaDescTextColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
      </div>
      <div class="col-span-2">
        <label
          for="characterLabelTextColor"
          style="color:{$characterSettings.colors.character_label}"
          class="block text-sm font-medium">'Character' Label Text Color</label>
        <input
          bind:value={$characterSettings.colors.character_label}
          type="color"
          name="characterLabelTextColor"
          id="characterLabelTextColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
      </div>
      <div class="col-span-2">
        <label
          for="charTextColor"
          style="color:{$characterSettings.colors.character}"
          class="block text-sm font-medium">Character Text Color</label>
        <input
          bind:value={$characterSettings.colors.character}
          type="color"
          name="charTextColor"
          id="charTextColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
      </div>
      <div class="col-span-2">
        <label
          for="exitLabelTextColor"
          style="color:{$characterSettings.colors.exit_label}"
          class="block text-sm font-medium">'Exit' Label Text Color</label>
        <input
          bind:value={$characterSettings.colors.exit_label}
          type="color"
          name="exitLabelTextColor"
          id="exitLabelTextColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
      </div>
      <div class="col-span-2">
        <label
          for="exitTextColor"
          style="color:{$characterSettings.colors.exit}"
          class="block text-sm font-medium">Exit Text Color</label>
        <input
          bind:value={$characterSettings.colors.exit}
          type="color"
          name="exitTextColor"
          id="exitTextColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
      </div>
      <div class="col-span-2">
        <label
          for="denizenLabelTextColor"
          style="color:{$characterSettings.colors.denizen_label}"
          class="block text-sm font-medium">Denizen Label Text Color</label>
        <input
          bind:value={$characterSettings.colors.denizen_label}
          type="color"
          name="denizenLabelTextColor"
          id="denizenLabelTextColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
      </div>
      <div class="col-span-2">
        <label
          for="denizenTextColor"
          style="color:{$characterSettings.colors.denizen}"
          class="block text-sm font-medium">Denizen Text Color</label>
        <input
          bind:value={$characterSettings.colors.denizen}
          type="color"
          name="denizenTextColor"
          id="denizenTextColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
      </div>
      <div class="col-span-2">
        <label
          for="furnTextColor"
          style="color:{$characterSettings.colors.furniture}"
          class="block text-sm font-medium">Furniture Text Color</label>
        <input
          bind:value={$characterSettings.colors.furniture}
          type="color"
          name="furnTextColor"
          id="furnTextColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
      </div>
      <div class="col-span-2">
        <label
          for="sysWarnTextColor"
          style="color:{$characterSettings.colors.system_warning}"
          class="block text-sm font-medium">***** System Warning Text Color
          *****</label>
        <input
          bind:value={$characterSettings.colors.system_warning}
          type="color"
          name="sysWarnTextColor"
          id="sysWarnTextColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
      </div>
      <div class="col-span-2">
        <label
          for="sysInfoTextColor"
          style="color:{$characterSettings.colors.system_info}"
          class="block text-sm font-medium">***** System Info Text Color *****</label>
        <input
          bind:value={$characterSettings.colors.system_info}
          type="color"
          name="sysInfoTextColor"
          id="sysInfoTextColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
      </div>
      <div class="col-span-2">
        <label
          for="sysAlertTextColor"
          style="color:{$characterSettings.colors.system_alert}"
          class="block text-sm font-medium">***** System Alert Text Color *****</label>
        <input
          bind:value={$characterSettings.colors.system_alert}
          type="color"
          name="sysAlertTextColor"
          id="sysAlertTextColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
      </div>
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
