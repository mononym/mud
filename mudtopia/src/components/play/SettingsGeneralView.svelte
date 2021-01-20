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
    on:submit|preventDefault={saveCharacterSettings}
  >
    <div class="col-span-4 grid grid-cols-8 gap-4">
      <h2 class="text-center text-white border-b-2 border-black col-span-8">
        Command Input Colors
      </h2>
      <div class="col-span-4">
        <label
          for="inputBackgroundColor"
          style="color:{$characterSettings.colors.input_background}"
          class="block text-sm font-medium"
          >Command Input Background Color</label
        >
        <input
          bind:value={$characterSettings.colors.input_background}
          type="color"
          name="inputBackgroundColor"
          id="inputBackgroundColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <div class="col-span-4">
        <label
          for="inputTextColor"
          style="color:{$characterSettings.colors.input}"
          class="block text-sm font-medium">Input Text Color</label
        >
        <input
          bind:value={$characterSettings.colors.input}
          type="color"
          name="inputTextColor"
          id="inputTextColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <div class="col-span-4">
        <label
          for="inputButtonBackgroundColor"
          style="color:{$characterSettings.colors.input_button_background}"
          class="block text-sm font-medium">Input Button Background Color</label
        >
        <input
          bind:value={$characterSettings.colors.input_button_background}
          type="color"
          name="inputButtonBackgroundColor"
          id="inputButtonBackgroundColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <div class="col-span-4">
        <label
          for="inputButtonIconColor"
          style="color:{$characterSettings.colors.input_button_icon}"
          class="block text-sm font-medium">Input Button Icon Color</label
        >
        <input
          bind:value={$characterSettings.colors.input_button_icon}
          type="color"
          name="inputButtonIconColor"
          id="inputButtonIconColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
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
          class="block text-sm font-medium">Story Window Background Color</label
        >
        <input
          bind:value={$characterSettings.colors.story_background}
          type="color"
          name="storyBackgroundColor"
          id="storyBackgroundColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <div class="col-span-2">
        <label
          for="storyHistoryIconColor"
          style="color:{$characterSettings.colors.story_history_icon}"
          class="block text-sm font-medium"
          >Story Window History Icon Color</label
        >
        <input
          bind:value={$characterSettings.colors.story_history_icon}
          type="color"
          name="storyHistoryIconColor"
          id="storyHistoryIconColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <div class="col-span-2">
        <label
          for="storyHistoryBorderColor"
          style="color:{$characterSettings.colors.story_history_border}"
          class="block text-sm font-medium"
          >Story Window History Window Border</label
        >
        <input
          bind:value={$characterSettings.colors.story_history_border}
          type="color"
          name="storyHistoryBorderColor"
          id="storyHistoryBorderColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
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
          class="block text-sm font-medium">Window Toolbar Color</label
        >
        <input
          bind:value={$characterSettings.colors.window_toolbar_background}
          type="color"
          name="windowToolbarColor"
          id="windowToolbarColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <div class="col-span-2">
        <label
          for="windowToolbarLabelColor"
          style="color:{$characterSettings.colors.window_toolbar_label}"
          class="block text-sm font-medium">Window Toolbar Label Color</label
        >
        <input
          bind:value={$characterSettings.colors.window_toolbar_label}
          type="color"
          name="windowToolbarLabelColor"
          id="windowToolbarLabelColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <div class="col-span-2">
        <label
          for="windowUnlockedColor"
          style="color:{$characterSettings.colors.window_lock_unlocked}"
          class="block text-sm font-medium">Window Lock Icon Unlocked</label
        >
        <input
          bind:value={$characterSettings.colors.window_lock_unlocked}
          type="color"
          name="windowUnlockedColor"
          id="windowUnlockedColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <div class="col-span-2">
        <label
          for="windowLockedColor"
          style="color:{$characterSettings.colors.window_lock_locked}"
          class="block text-sm font-medium">Window Lock Icon Unlocked</label
        >
        <input
          bind:value={$characterSettings.colors.window_lock_locked}
          type="color"
          name="windowLockedColor"
          id="windowLockedColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <div class="col-span-2">
        <label
          for="windowMoveUnlockedColor"
          style="color:{$characterSettings.colors.window_move_unlocked}"
          class="block text-sm font-medium">Window Move Icon Unlocked</label
        >
        <input
          bind:value={$characterSettings.colors.window_move_unlocked}
          type="color"
          name="windowMoveUnlockedColor"
          id="windowMoveUnlockedColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <div class="col-span-2">
        <label
          for="windowMoveLockedColor"
          style="color:{$characterSettings.colors.window_move_locked}"
          class="block text-sm font-medium">Window Move Icon locked</label
        >
        <input
          bind:value={$characterSettings.colors.window_move_locked}
          type="color"
          name="windowMoveLockedColor"
          id="windowMoveLockedColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
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
          class="block text-sm font-medium">Base Text Color</label
        >
        <input
          bind:value={$characterSettings.colors.base}
          type="color"
          name="baseTextColor"
          id="baseTextColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <div class="col-span-2">
        <label
          for="toiLabelTextColor"
          style="color:{$characterSettings.colors.toi_label}"
          class="block text-sm font-medium"
          >'Things of Interest' Label Text Color</label
        >
        <input
          bind:value={$characterSettings.colors.toi_label}
          type="color"
          name="toiLabelTextColor"
          id="toiLabelTextColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <div class="col-span-2">
        <label
          for="areaNameTextColor"
          style="color:{$characterSettings.colors.area_name}"
          class="block text-sm font-medium">[Area Name Text Color]</label
        >
        <input
          bind:value={$characterSettings.colors.area_name}
          type="color"
          name="areaNameTextColor"
          id="areaNameTextColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <div class="col-span-2">
        <label
          for="areaDescTextColor"
          style="color:{$characterSettings.colors.area_description}"
          class="block text-sm font-medium">Area Description Text Color</label
        >
        <input
          bind:value={$characterSettings.colors.area_description}
          type="color"
          name="areaDescTextColor"
          id="areaDescTextColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <div class="col-span-2">
        <label
          for="characterLabelTextColor"
          style="color:{$characterSettings.colors.character_label}"
          class="block text-sm font-medium">'Character' Label Text Color</label
        >
        <input
          bind:value={$characterSettings.colors.character_label}
          type="color"
          name="characterLabelTextColor"
          id="characterLabelTextColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <div class="col-span-2">
        <label
          for="charTextColor"
          style="color:{$characterSettings.colors.character}"
          class="block text-sm font-medium">Character Text Color</label
        >
        <input
          bind:value={$characterSettings.colors.character}
          type="color"
          name="charTextColor"
          id="charTextColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <div class="col-span-2">
        <label
          for="exitLabelTextColor"
          style="color:{$characterSettings.colors.exit_label}"
          class="block text-sm font-medium"
          >'Obvious Exits' Label Text Color</label
        >
        <input
          bind:value={$characterSettings.colors.exit_label}
          type="color"
          name="exitLabelTextColor"
          id="exitLabelTextColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <div class="col-span-2">
        <label
          for="exitTextColor"
          style="color:{$characterSettings.colors.exit}"
          class="block text-sm font-medium">Exit Text Color</label
        >
        <input
          bind:value={$characterSettings.colors.exit}
          type="color"
          name="exitTextColor"
          id="exitTextColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <div class="col-span-2">
        <label
          for="denizenLabelTextColor"
          style="color:{$characterSettings.colors.denizen_label}"
          class="block text-sm font-medium">Denizen Label Text Color</label
        >
        <input
          bind:value={$characterSettings.colors.denizen_label}
          type="color"
          name="denizenLabelTextColor"
          id="denizenLabelTextColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <div class="col-span-2">
        <label
          for="denizenTextColor"
          style="color:{$characterSettings.colors.denizen}"
          class="block text-sm font-medium">Denizen Text Color</label
        >
        <input
          bind:value={$characterSettings.colors.denizen}
          type="color"
          name="denizenTextColor"
          id="denizenTextColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <div class="col-span-2">
        <label
          for="furnTextColor"
          style="color:{$characterSettings.colors.furniture}"
          class="block text-sm font-medium">Furniture Text Color</label
        >
        <input
          bind:value={$characterSettings.colors.furniture}
          type="color"
          name="furnTextColor"
          id="furnTextColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <div class="col-span-2">
        <label
          for="wornContainerTextColor"
          style="color:{$characterSettings.colors.worn_container}"
          class="block text-sm font-medium">Worn Container Text Color</label
        >
        <input
          bind:value={$characterSettings.colors.worn_container}
          type="color"
          name="wornContainerTextColor"
          id="wornContainerTextColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <div class="col-span-2">
        <label
          for="containerTextColor"
          style="color:{$characterSettings.colors.container}"
          class="block text-sm font-medium">Container Text Color</label
        >
        <input
          bind:value={$characterSettings.colors.container}
          type="color"
          name="containerTextColor"
          id="containerTextColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <div class="col-span-2">
        <label
          for="weaponTextColor"
          style="color:{$characterSettings.colors.weapon}"
          class="block text-sm font-medium">Weapon Text Color</label
        >
        <input
          bind:value={$characterSettings.colors.weapon}
          type="color"
          name="weaponTextColor"
          id="weaponTextColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <div class="col-span-2">
        <label
          for="armorTextColor"
          style="color:{$characterSettings.colors.armor}"
          class="block text-sm font-medium">Armor Text Color</label
        >
        <input
          bind:value={$characterSettings.colors.armor}
          type="color"
          name="armorTextColor"
          id="armorTextColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <div class="col-span-2">
        <label
          for="shieldTextColor"
          style="color:{$characterSettings.colors.shield}"
          class="block text-sm font-medium">Shield Text Color</label
        >
        <input
          bind:value={$characterSettings.colors.shield}
          type="color"
          name="shieldTextColor"
          id="shieldTextColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <div class="col-span-2">
        <label
          for="gemTextColor"
          style="color:{$characterSettings.colors.gem}"
          class="block text-sm font-medium">Gem Text Color</label
        >
        <input
          bind:value={$characterSettings.colors.gem}
          type="color"
          name="gemTextColor"
          id="gemTextColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <div class="col-span-2">
        <label
          for="ammoTextColor"
          style="color:{$characterSettings.colors.ammunition}"
          class="block text-sm font-medium">Ammunition Text Color</label
        >
        <input
          bind:value={$characterSettings.colors.ammunition}
          type="color"
          name="ammoTextColor"
          id="ammoTextColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <div class="col-span-2">
        <label
          for="clothingTextColor"
          style="color:{$characterSettings.colors.clothing}"
          class="block text-sm font-medium">Clothing Text Color</label
        >
        <input
          bind:value={$characterSettings.colors.clothing}
          type="color"
          name="clothingTextColor"
          id="clothingTextColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <div class="col-span-2">
        <label
          for="sceneryTextColor"
          style="color:{$characterSettings.colors.scenery}"
          class="block text-sm font-medium">Scenery Text Color</label
        >
        <input
          bind:value={$characterSettings.colors.scenery}
          type="color"
          name="sceneryTextColor"
          id="sceneryTextColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <div class="col-span-2">
        <label
          for="onGroundLabelTextColor"
          style="color:{$characterSettings.colors.on_ground_label}"
          class="block text-sm font-medium">'On Ground' Label Text Color</label
        >
        <input
          bind:value={$characterSettings.colors.on_ground_label}
          type="color"
          name="onGroundLabelTextColor"
          id="onGroundLabelTextColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <div class="col-span-2">
        <label
          for="echoTextColor"
          style="color:{$characterSettings.colors.echo}"
          class="block text-sm font-medium">Echo Text Color</label
        >
        <input
          bind:value={$characterSettings.colors.echo}
          type="color"
          name="echoTextColor"
          id="echoTextColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <div class="col-span-2">
        <label
          for="sysWarnTextColor"
          style="color:{$characterSettings.colors.system_warning}"
          class="block text-sm font-medium"
          >***** System Warning Text Color *****</label
        >
        <input
          bind:value={$characterSettings.colors.system_warning}
          type="color"
          name="sysWarnTextColor"
          id="sysWarnTextColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <div class="col-span-2">
        <label
          for="sysInfoTextColor"
          style="color:{$characterSettings.colors.system_info}"
          class="block text-sm font-medium"
          >***** System Info Text Color *****</label
        >
        <input
          bind:value={$characterSettings.colors.system_info}
          type="color"
          name="sysInfoTextColor"
          id="sysInfoTextColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <div class="col-span-2">
        <label
          for="sysAlertTextColor"
          style="color:{$characterSettings.colors.system_alert}"
          class="block text-sm font-medium"
          >***** System Alert Text Color *****</label
        >
        <input
          bind:value={$characterSettings.colors.system_alert}
          type="color"
          name="sysAlertTextColor"
          id="sysAlertTextColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
    </div>

    <div
      class="col-span-4 grid grid-cols-12 gap-4"
      style="background-color:{$characterSettings.areaWindow.background}"
    >
      <h2
        class="text-center text-white border-b-2 border-black col-span-12"
        style="background-color:{$characterSettings.colors
          .window_toolbar_background};color:{$characterSettings.colors
          .window_toolbar_label}"
      >Area Window</h2>
      <div class="col-span-12">
        <label
          for="areaWindowBackgroundColor"
          style="color:{$characterSettings.colors.window_toolbar_label}"
          class="block text-sm font-medium">Background Color</label
        >
        <input
          bind:value={$characterSettings.areaWindow.background}
          type="color"
          name="areaWindowBackgroundColor"
          id="areaWindowBackgroundColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <div class="col-span-6">
        <label
          for="showDescription"
          style="color:{$characterSettings.colors.window_toolbar_label}"
          class="block text-sm font-medium">Show Description</label
        >
        <input
          bind:checked={$characterSettings.areaWindow.show_description}
          type="checkbox"
          name="showDescription"
          id="showDescription"
        />
      </div>
      <div class="col-span-6">
        <label
          for="descriptionExpansionMode"
          style="color:{$characterSettings.colors.window_toolbar_label}"
          class="block text-sm font-medium">Description Expansion Mode</label
        >
        <select
          id="descriptionExpansionMode"
          bind:value={$characterSettings.areaWindow.description_expansion_mode}
          name="descriptionExpansionMode"
          class="mt-1 block w-full py-2 px-3 border border-gray-300 bg-white rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm">
          <option>manual</option>
          <option>open</option>
          <option>close</option>
        </select>
      </div>

      <div class="col-span-4">
        <label
          for="showToi"
          style="color:{$characterSettings.colors.window_toolbar_label}"
          class="block text-sm font-medium">Show Things Of Interest</label
        >
        <input
          bind:checked={$characterSettings.areaWindow.show_toi}
          type="checkbox"
          name="showToi"
          id="showToi"
        />
      </div>
      <div class="col-span-4">
        <label
          for="toiExpansionMode"
          style="color:{$characterSettings.colors.window_toolbar_label}"
          class="block text-sm font-medium"
          >Things Of Interest Expansion Mode</label
        >
        <select
          id="toiExpansionMode"
          bind:value={$characterSettings.areaWindow.toi_expansion_mode}
          name="toiExpansionMode"
          class="mt-1 block w-full py-2 px-3 border border-gray-300 bg-white rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm">
          <option>manual</option>
          <option>manual-threshold</option>
          <option>open</option>
          <option>open-threshold</option>
          <option>close</option>
        </select>
      </div>
      <div class="col-span-4">
        <label
          for="toiThreshold"
          style="color:{$characterSettings.colors.window_toolbar_label}"
          class="block text-sm font-medium"
          >Things Of Interest Collapse Threshold</label
        >
        <input
          bind:value={$characterSettings.areaWindow.toi_collapse_threshold}
          type="number"
          name="toiThreshold"
          id="toiThreshold"
          max="1000"
          min="5"
        />
      </div>

      <div class="col-span-4">
        <label
          for="showOnGround"
          style="color:{$characterSettings.colors.window_toolbar_label}"
          class="block text-sm font-medium">Show On Ground</label
        >
        <input
          bind:checked={$characterSettings.areaWindow.show_on_ground}
          type="checkbox"
          name="showOnGround"
          id="showOnGround"
        />
      </div>
      <div class="col-span-4">
        <label
          for="onGroundExpansionMode"
          style="color:{$characterSettings.colors.window_toolbar_label}"
          class="block text-sm font-medium">On Ground Expansion Mode</label
        >
        <select
          id="onGroundExpansionMode"
          bind:value={$characterSettings.areaWindow.on_ground_expansion_mode}
          name="onGroundExpansionMode"
          class="mt-1 block w-full py-2 px-3 border border-gray-300 bg-white rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm">
          <option>manual</option>
          <option>manual-threshold</option>
          <option>open</option>
          <option>open-threshold</option>
          <option>close</option>
        </select>
      </div>
      <div class="col-span-4">
        <label
          for="onGroundThreshold"
          style="color:{$characterSettings.colors.window_toolbar_label}"
          class="block text-sm font-medium">On Ground Collapse Threshold</label
        >
        <input
          bind:value={$characterSettings.areaWindow
            .on_ground_collapse_threshold}
          type="number"
          name="onGroundThreshold"
          id="onGroundThreshold"
          max="1000"
          min="5"
        />
      </div>

      <div class="col-span-4">
        <label
          for="showAlsoPresent"
          style="color:{$characterSettings.colors.window_toolbar_label}"
          class="block text-sm font-medium">Show Also Present</label
        >
        <input
          bind:checked={$characterSettings.areaWindow.show_also_present}
          type="checkbox"
          name="showAlsoPresent"
          id="showAlsoPresent"
        />
      </div>
      <div class="col-span-4">
        <label
          for="alsoPresentExpansionMode"
          style="color:{$characterSettings.colors.window_toolbar_label}"
          class="block text-sm font-medium">Also Present Expansion Mode</label
        >
        <select
          id="alsoPresentExpansionMode"
          bind:value={$characterSettings.areaWindow.also_present_expansion_mode}
          name="alsoPresentExpansionMode"
          class="mt-1 block w-full py-2 px-3 border border-gray-300 bg-white rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm">
          <option>manual</option>
          <option>manual-threshold</option>
          <option>open</option>
          <option>open-threshold</option>
          <option>close</option>
        </select>
      </div>
      <div class="col-span-4">
        <label
          for="alsoPresentThreshold"
          style="color:{$characterSettings.colors.window_toolbar_label}"
          class="block text-sm font-medium"
          >Also Present Collapse Threshold</label
        >
        <input
          bind:value={$characterSettings.areaWindow
            .also_present_collapse_threshold}
          type="number"
          name="alsoPresentThreshold"
          id="alsoPresentThreshold"
          max="1000"
          min="5"
        />
      </div>

      <div class="col-span-4">
        <label
          for="showExits"
          style="color:{$characterSettings.colors.window_toolbar_label}"
          class="block text-sm font-medium">Show Exits</label
        >
        <input
          bind:checked={$characterSettings.areaWindow.show_exits}
          type="checkbox"
          name="showExits"
          id="showExits"
        />
      </div>
      <div class="col-span-4">
        <label
          for="exitsExpansionMode"
          style="color:{$characterSettings.colors.window_toolbar_label}"
          class="block text-sm font-medium">Exits Expansion Mode</label
        >
        <select
          id="exitsExpansionMode"
          bind:value={$characterSettings.areaWindow.exits_expansion_mode}
          name="exitsExpansionMode"
          class="mt-1 block w-full py-2 px-3 border border-gray-300 bg-white rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm">
          <option>manual</option>
          <option>manual-threshold</option>
          <option>open</option>
          <option>open-threshold</option>
          <option>close</option>
        </select>
      </div>
      <div class="col-span-4">
        <label
          for="exitsThreshold"
          style="color:{$characterSettings.colors.window_toolbar_label}"
          class="block text-sm font-medium">Exits Collapse Threshold</label
        >
        <input
          bind:value={$characterSettings.areaWindow.exits_collapse_threshold}
          type="number"
          name="exitsThreshold"
          id="exitsThreshold"
          max="1000"
          min="5"
        />
      </div>

      <div class="col-span-6">
        <label
          for="overallExpansionMode"
          style="color:{$characterSettings.colors.window_toolbar_label}"
          class="block text-sm font-medium">Overall Expansion Mode</label
        >
        <select
          id="overallExpansionMode"
          bind:value={$characterSettings.areaWindow.total_collapse_mode}
          name="overallExpansionMode"
          class="mt-1 block w-full py-2 px-3 border border-gray-300 bg-white rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm">
          <option>largest</option>
          <option>smallest</option>
          <option>all</option>
          <option>none</option>
        </select>
      </div>
      <div class="col-span-6">
        <label
          for="overallThreshold"
          style="color:{$characterSettings.colors.window_toolbar_label}"
          class="block text-sm font-medium">Overall Collapse Threshold</label
        >
        <input
          bind:value={$characterSettings.areaWindow
            .total_count_collapse_threshold}
          type="number"
          name="overallThreshold"
          id="overallThreshold"
          max="1000"
          min="5"
        />
      </div>
      <div class="col-span-4">
        <label
          for="areaWindowfilterBorderColorColor"
          style="color:{$characterSettings.areaWindow.filter_border_color}"
          class="block text-sm font-medium">Filter Border Color</label
        >
        <input
          bind:value={$characterSettings.areaWindow.filter_border_color}
          type="color"
          name="areaWindowfilterBorderColorColor"
          id="areaWindowfilterBorderColorColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <div class="col-span-4">
        <label
          for="areaWindowfilterActiveIconColor"
          style="color:{$characterSettings.areaWindow.filter_active_icon_color}"
          class="block text-sm font-medium">Filter Active Icon Color</label
        >
        <input
          bind:value={$characterSettings.areaWindow.filter_active_icon_color}
          type="color"
          name="areaWindowfilterActiveIconColor"
          id="areaWindowfilterActiveIconColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <div class="col-span-4">
        <label
          for="areaWindowfilterInactiveIconColor"
          style="color:{$characterSettings.areaWindow
            .filter_inactive_icon_color}"
          class="block text-sm font-medium">Filter Inactive Icon Color</label
        >
        <input
          bind:value={$characterSettings.areaWindow.filter_inactive_icon_color}
          type="color"
          name="areaWindowfilterInactiveIconColor"
          id="areaWindowfilterInactiveIconColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <div class="col-span-4">
        <label
          for="areaWindowfilterActiveBackgroundColor"
          style="color:{$characterSettings.areaWindow
            .filter_active_background_color}"
          class="block text-sm font-medium"
          >Filter Active Background Color</label
        >
        <input
          bind:value={$characterSettings.areaWindow
            .filter_active_background_color}
          type="color"
          name="areaWindowfilterActiveBackgroundColor"
          id="areaWindowfilterActiveBackgroundColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <div class="col-span-4">
        <label
          for="areaWindowfilterInactiveBackgroundColor"
          style="color:{$characterSettings.areaWindow
            .filter_inactive_background_color}"
          class="block text-sm font-medium"
          >Filter Inactive Background Color</label
        >
        <input
          bind:value={$characterSettings.areaWindow
            .filter_inactive_background_color}
          type="color"
          name="areaWindowfilterInactiveBackgroundColor"
          id="areaWindowfilterInactiveBackgroundColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <div class="col-span-6">
        <label
          for="showQuickActions"
          style="color:{$characterSettings.colors.window_toolbar_label}"
          class="block text-sm font-medium">Show Quick Actions</label
        >
        <input
          bind:checked={$characterSettings.areaWindow.show_quick_actions}
          type="checkbox"
          name="showQuickActions"
          id="showQuickActions"
        />
      </div>
      <div class="col-span-4">
        <label
          for="areaWindowDisabledQuickActionColor"
          style="color:{$characterSettings.areaWindow
            .disabled_quick_action_color}"
          class="block text-sm font-medium">Disabled Quick Action Color</label
        >
        <input
          bind:value={$characterSettings.areaWindow.disabled_quick_action_color}
          type="color"
          name="areaWindowDisabledQuickActionColor"
          id="areaWindowDisabledQuickActionColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
    </div>

    <div
      class="col-span-4 grid grid-cols-8 gap-4"
      style="background-color:{$characterSettings.inventoryWindow.background}"
    >
      <h2
        class="text-center text-white border-b-2 border-black col-span-8"
        style="background-color:{$characterSettings.colors
          .window_toolbar_background};color:{$characterSettings.colors
          .window_toolbar_label}"
      >Inventory Window</h2>
      <div class="col-span-4">
        <label
          for="inventoryWindowBackgroundColor"
          style="color:{$characterSettings.colors.window_toolbar_label}"
          class="block text-sm font-medium">Background Color</label
        >
        <input
          bind:value={$characterSettings.inventoryWindow.background}
          type="color"
          name="inventoryWindowBackgroundColor"
          id="inventoryWindowBackgroundColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <div class="col-span-4">
        <label
          for="emptyHandTextColor"
          style="color:{$characterSettings.inventoryWindow.empty_hand}"
          class="block text-sm font-medium">Empty Hand Text Color</label
        >
        <input
          bind:value={$characterSettings.inventoryWindow.empty_hand}
          type="color"
          name="emptyHandTextColor"
          id="emptyHandTextColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <div class="col-span-4">
        <label
          for="heldItemsColor"
          style="color:{$characterSettings.inventoryWindow.held_items_label}"
          class="block text-sm font-medium">Held Items Label Color</label
        >
        <input
          bind:value={$characterSettings.inventoryWindow.held_items_label}
          type="color"
          name="heldItemsColor"
          id="heldItemsColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <div class="col-span-4">
        <label
          for="wornContainersLabel"
          style="color:{$characterSettings.inventoryWindow
            .worn_containers_label}"
          class="block text-sm font-medium">Worn Containers Label</label
        >
        <input
          bind:value={$characterSettings.inventoryWindow.worn_containers_label}
          type="color"
          name="wornContainersLabel"
          id="wornContainersLabel"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <div class="col-span-4">
        <label
          for="wornClothesLabel"
          style="color:{$characterSettings.inventoryWindow.worn_clothes_label}"
          class="block text-sm font-medium">Worn Clothes Label</label
        >
        <input
          bind:value={$characterSettings.inventoryWindow.worn_clothes_label}
          type="color"
          name="wornClothesLabel"
          id="wornClothesLabel"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <div class="col-span-4">
        <label
          for="wornArmorLabel"
          style="color:{$characterSettings.inventoryWindow.worn_armor_label}"
          class="block text-sm font-medium">Worn Armor Label</label
        >
        <input
          bind:value={$characterSettings.inventoryWindow.worn_armor_label}
          type="color"
          name="wornArmorLabel"
          id="wornArmorLabel"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <div class="col-span-4">
        <label
          for="wornWeaponsLabel"
          style="color:{$characterSettings.inventoryWindow.worn_weapons_label}"
          class="block text-sm font-medium">Worn Weapons Label</label
        >
        <input
          bind:value={$characterSettings.inventoryWindow.worn_weapons_label}
          type="color"
          name="wornWeaponsLabel"
          id="wornWeaponsLabel"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <div class="col-span-4">
        <label
          for="wornJewelryLabel"
          style="color:{$characterSettings.inventoryWindow.worn_jewelry_label}"
          class="block text-sm font-medium">Worn Jewelry Label</label
        >
        <input
          bind:value={$characterSettings.inventoryWindow.worn_jewelry_label}
          type="color"
          name="wornJewelryLabel"
          id="wornJewelryLabel"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <div class="col-span-4">
        <label
          for="filterBorderColorColor"
          style="color:{$characterSettings.inventoryWindow.filter_border_color}"
          class="block text-sm font-medium">Filter Border Color</label
        >
        <input
          bind:value={$characterSettings.inventoryWindow.filter_border_color}
          type="color"
          name="filterBorderColorColor"
          id="filterBorderColorColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <div class="col-span-4">
        <label
          for="filterActiveIconColor"
          style="color:{$characterSettings.inventoryWindow
            .filter_active_icon_color}"
          class="block text-sm font-medium">Filter Active Icon Color</label
        >
        <input
          bind:value={$characterSettings.inventoryWindow
            .filter_active_icon_color}
          type="color"
          name="filterActiveIconColor"
          id="filterActiveIconColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <div class="col-span-4">
        <label
          for="filterInactiveIconColor"
          style="color:{$characterSettings.inventoryWindow
            .filter_inactive_icon_color}"
          class="block text-sm font-medium">Filter Inactive Icon Color</label
        >
        <input
          bind:value={$characterSettings.inventoryWindow
            .filter_inactive_icon_color}
          type="color"
          name="filterInactiveIconColor"
          id="filterInactiveIconColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <div class="col-span-4">
        <label
          for="filterActiveBackgroundColor"
          style="color:{$characterSettings.inventoryWindow
            .filter_active_background_color}"
          class="block text-sm font-medium"
          >Filter Active Background Color</label
        >
        <input
          bind:value={$characterSettings.inventoryWindow
            .filter_active_background_color}
          type="color"
          name="filterActiveBackgroundColor"
          id="filterActiveBackgroundColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <div class="col-span-4">
        <label
          for="filterInactiveBackgroundColor"
          style="color:{$characterSettings.inventoryWindow
            .filter_inactive_background_color}"
          class="block text-sm font-medium"
          >Filter Inactive Background Color</label
        >
        <input
          bind:value={$characterSettings.inventoryWindow
            .filter_inactive_background_color}
          type="color"
          name="filterInactiveBackgroundColor"
          id="filterInactiveBackgroundColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
    </div>

    <div class="px-4 py-3 text-right sm:px-6">
      <button
        disabled={!settingsChanged}
        type="submit"
        class="{!settingsChanged
          ? 'bg-indigo-800 text-gray-500 cursor-not-allowed'
          : 'bg-indigo-600 hover:bg-indigo-700 text-white'} inline-flex justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-md focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500">
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
