<script>
  import { getContext } from "svelte";
  import { key } from "./state";
  import tippy from "tippy.js";
  import "tippy.js/dist/tippy.css";
  import { onMount } from "svelte";

  const state = getContext(key);
  const {
    characterSettings,
    resetCharacterSettings,
    saveCharacterSettings,
  } = state;

  let settingsChanged = true;

  onMount(() => {
    tippy("[data-tippy-content]");
  });
</script>

{#if $characterSettings != undefined}
  <form
    class="container grid grid-cols-12 gap-4"
    on:submit|preventDefault={saveCharacterSettings}
  >
    <!-- Command Input Window -->
    <div class="col-span-4 grid grid-cols-8 gap-4 bg-gray-900">
      <h2
        class="text-center text-gray-300 border-b-2 border-primary col-span-8"
      >
        Command Input Window Configuration
      </h2>
      <div class="col-span-4">
        <label
          for="inputBackgroundColor"
          class="block text-sm font-medium text-gray-300"
          >Command Input Background Color</label
        >
        <input
          bind:value={$characterSettings.colors.input_background}
          type="color"
          name="inputBackgroundColor"
          id="inputBackgroundColor"
          class="mt-1 bg-gray-400 focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <div class="col-span-4">
        <label
          for="inputTextColor"
          class="block text-sm font-medium text-gray-300"
          >Input Text Color</label
        >
        <input
          bind:value={$characterSettings.colors.input}
          type="color"
          name="inputTextColor"
          id="inputTextColor"
          class="mt-1 bg-gray-400 focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
    </div>
    <!-- Story Window -->
    <div class="col-span-4 grid grid-cols-6 gap-4">
      <h2
        class="text-center text-gray-300 border-b-2 border-primary col-span-6"
      >
        Story Window Configuration
      </h2>
      <div class="col-span-2">
        <label
          for="storyBackgroundColor"
          class="block text-sm font-medium text-gray-300"
          >Story Window Background Color</label
        >
        <input
          bind:value={$characterSettings.colors.story_background}
          type="color"
          name="storyBackgroundColor"
          id="storyBackgroundColor"
          class="mt-1 bg-gray-400 focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <div class="col-span-2">
        <label
          for="storyHistoryIconColor"
          class="block text-sm font-medium text-gray-300"
          >Story Window History Icon Color</label
        >
        <input
          bind:value={$characterSettings.colors.story_history_icon}
          type="color"
          name="storyHistoryIconColor"
          id="storyHistoryIconColor"
          class="mt-1 bg-gray-400 focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <div
        class="col-span-2"
        data-tippy-content="The horizontal border that splits the Story Window in half when the history view is opened."
      >
        <label
          for="storyHistoryBorderColor"
          class="block text-sm font-medium text-gray-300"
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
      <h2
        class="text-center text-gray-300 border-b-2 border-primary col-span-6"
      >
        UI Colors
      </h2>
      <div class="col-span-2">
        <label
          for="windowToolbarColor"
          class="block text-sm font-medium text-gray-300"
          >Window Toolbar Color</label
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
          class="block text-sm font-medium text-gray-300"
          >Window Toolbar Label Color</label
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
          class="block text-sm font-medium text-gray-300"
          >Window Lock Icon Unlocked</label
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
          class="block text-sm font-medium text-gray-300"
          >Window Lock Icon Unlocked</label
        >
        <input
          bind:value={$characterSettings.colors.window_lock_locked}
          type="color"
          name="windowLockedColor"
          id="windowLockedColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <div
        class="col-span-2"
        data-tippy-content="The color of the 'move' and 'increase/decrease zIndex' icons when the window is unlocked for editing."
      >
        <label
          for="windowMoveUnlockedColor"
          class="block text-sm font-medium text-gray-300"
          >Window Edit Icons Unlocked</label
        >
        <input
          bind:value={$characterSettings.colors.window_move_unlocked}
          type="color"
          name="windowMoveUnlockedColor"
          id="windowMoveUnlockedColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <div
        class="col-span-2"
        data-tippy-content="The color of the 'move' and 'increase/decrease zIndex' icons when the window is locked for editing."
      >
        >
        <label
          for="windowMoveLockedColor"
          class="block text-sm font-medium text-gray-300"
          >Window Edit Icons locked</label
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
      <h2
        class="text-center text-gray-300 border-b-2 border-primary col-span-4"
      >
        Text Colors
      </h2>
      <div
        class="col-span-2"
        data-tippy-content="The 'default' text color when no other colors apply to the specific span of text."
      >
        <label
          for="baseTextColor"
          class="block text-sm font-medium text-gray-300">Base Text Color</label
        >
        <input
          bind:value={$characterSettings.colors.base}
          type="color"
          name="baseTextColor"
          id="baseTextColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <div
        class="col-span-2"
        data-tippy-content="The color of the ToI label in both the Story Window and the Area Window."
      >
        <label
          for="toiLabelTextColor"
          class="block text-sm font-medium text-gray-300"
          >Things of Interest Label Text Color</label
        >
        <input
          bind:value={$characterSettings.colors.toi_label}
          type="color"
          name="toiLabelTextColor"
          id="toiLabelTextColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <div
        class="col-span-2"
        data-tippy-content="The color of the Area name in both the Story Window and the Area Window."
      >
        <label
          for="areaNameTextColor"
          class="block text-sm font-medium text-gray-300"
          >Area Name Text Color</label
        >
        <input
          bind:value={$characterSettings.colors.area_name}
          type="color"
          name="areaNameTextColor"
          id="areaNameTextColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <div
        class="col-span-2"
        data-tippy-content="The color of the Area description, with specific spans within the description able to be overridden, in both the Story Window and the Area Window."
      >
        <label
          for="areaDescTextColor"
          class="block text-sm font-medium text-gray-300"
          >Area Description Text Color</label
        >
        <input
          bind:value={$characterSettings.colors.area_description}
          type="color"
          name="areaDescTextColor"
          id="areaDescTextColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <div
        class="col-span-2"
        data-tippy-content="The color of the Character label in both the Story Window and the Area Window."
      >
        <label
          for="characterLabelTextColor"
          class="block text-sm font-medium text-gray-300"
          >Character Label Text Color</label
        >
        <input
          bind:value={$characterSettings.colors.character_label}
          type="color"
          name="characterLabelTextColor"
          id="characterLabelTextColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <div
        class="col-span-2"
        data-tippy-content="The color of the Character names in both the Story Window and the Area Window."
      >
        <label
          for="charTextColor"
          class="block text-sm font-medium text-gray-300"
          >Character Text Color</label
        >
        <input
          bind:value={$characterSettings.colors.character}
          type="color"
          name="charTextColor"
          id="charTextColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <div
        class="col-span-2"
        data-tippy-content="The color of the Exits label in both the Story Window and the Area Window."
      >
        <label
          for="exitLabelTextColor"
          class="block text-sm font-medium text-gray-300"
          >Obvious Exits Label Text Color</label
        >
        <input
          bind:value={$characterSettings.colors.exit_label}
          type="color"
          name="exitLabelTextColor"
          id="exitLabelTextColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <!-- <div class="col-span-2">
        <label
          for="exitTextColor"
          class="block text-sm font-medium text-gray-300">Exit Text Color</label
        >
        <input
          bind:value={$characterSettings.colors.exit}
          type="color"
          name="exitTextColor"
          id="exitTextColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div> -->
      <!-- <div
        class="col-span-2"
        data-tippy-content="The color of the Denizen's label in both the Story Window and the Area Window."
      >
        <label
          for="denizenLabelTextColor"
          class="block text-sm font-medium text-gray-300"
          >Denizen Label Text Color</label
        >
        <input
          bind:value={$characterSettings.colors.denizen_label}
          type="color"
          name="denizenLabelTextColor"
          id="denizenLabelTextColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <div
        class="col-span-2"
        data-tippy-content="The color of the Denizen's names in both the Story Window and the Area Window."
      >
        <label
          for="denizenTextColor"
          class="block text-sm font-medium text-gray-300"
          >Denizen Text Color</label
        >
        <input
          bind:value={$characterSettings.colors.denizen}
          type="color"
          name="denizenTextColor"
          id="denizenTextColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div> -->
      <div
        class="col-span-2"
        data-tippy-content="The color of Furniture names in both the Story Window and the Area Window."
      >
        <label
          for="furnTextColor"
          class="block text-sm font-medium text-gray-300"
          >Furniture Text Color</label
        >
        <input
          bind:value={$characterSettings.colors.furniture}
          type="color"
          name="furnTextColor"
          id="furnTextColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <!-- <div class="col-span-2">
        <label
          for="wornContainerTextColor"
          class="block text-sm font-medium text-gray-300"
          >Worn Container Text Color</label
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
          class="block text-sm font-medium text-gray-300"
          >Container Text Color</label
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
          class="block text-sm font-medium text-gray-300"
          >Weapon Text Color</label
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
          class="block text-sm font-medium text-gray-300"
          >Armor Text Color</label
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
          class="block text-sm font-medium text-gray-300"
          >Shield Text Color</label
        >
        <input
          bind:value={$characterSettings.colors.shield}
          type="color"
          name="shieldTextColor"
          id="shieldTextColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div> -->
      <div
        class="col-span-2"
        data-tippy-content="The color of Gem names in both the Story Window and the Area Window."
      >
        <label
          for="gemTextColor"
          class="block text-sm font-medium text-gray-300">Gem Text Color</label
        >
        <input
          bind:value={$characterSettings.colors.gem}
          type="color"
          name="gemTextColor"
          id="gemTextColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <!-- <div class="col-span-2">
        <label
          for="ammoTextColor"
          class="block text-sm font-medium text-gray-300"
          >Ammunition Text Color</label
        >
        <input
          bind:value={$characterSettings.colors.ammunition}
          type="color"
          name="ammoTextColor"
          id="ammoTextColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div> -->
      <div
        class="col-span-2"
        data-tippy-content="The color of Clothing names in both the Story Window and the Area Window."
      >
        <label
          for="clothingTextColor"
          class="block text-sm font-medium text-gray-300"
          >Clothing Text Color</label
        >
        <input
          bind:value={$characterSettings.colors.clothing}
          type="color"
          name="clothingTextColor"
          id="clothingTextColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <!-- <div class="col-span-2">
        <label
          for="sceneryTextColor"
          class="block text-sm font-medium text-gray-300"
          >Scenery Text Color</label
        >
        <input
          bind:value={$characterSettings.colors.scenery}
          type="color"
          name="sceneryTextColor"
          id="sceneryTextColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div> -->
      <div
        class="col-span-2"
        data-tippy-content="The color of Coin names in both the Story Window and the Area Window."
      >
        <label
          for="coinTextColor"
          class="block text-sm font-medium text-gray-300">Coin Text Color</label
        >
        <input
          bind:value={$characterSettings.colors.coin}
          type="color"
          name="coinTextColor"
          id="coinTextColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>

      <div
        class="col-span-2"
        data-tippy-content="The color of Portal exits in both the Story Window and the Area Window."
      >
        <label
          for="portalTextColor"
          class="block text-sm font-medium text-gray-300"
          >Portal Text Color</label
        >
        <input
          bind:value={$characterSettings.colors.portal}
          type="color"
          name="portalTextColor"
          id="portalTextColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <div
        class="col-span-2"
        data-tippy-content="The color of Closable exits, such as doors or gates, in both the Story Window and the Area Window."
      >
        <label
          for="closableTextColor"
          class="block text-sm font-medium text-gray-300"
          >Closable Text Color</label
        >
        <input
          bind:value={$characterSettings.colors.closable}
          type="color"
          name="closableTextColor"
          id="closableTextColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <div
        class="col-span-2"
        data-tippy-content="The color of Direction exits, such as north or east, in both the Story Window and the Area Window."
      >
        <label
          for="directionTextColor"
          class="block text-sm font-medium text-gray-300"
          >Direction Text Color</label
        >
        <input
          bind:value={$characterSettings.colors.direction}
          type="color"
          name="directionTextColor"
          id="directionTextColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <div
        class="col-span-2"
        data-tippy-content="The color of Object exits, such as a bridge or arch, in both the Story Window and the Area Window."
      >
        <label
          for="objectExitTextColor"
          class="block text-sm font-medium text-gray-300"
          >Object Exit Text Color</label
        >
        <input
          bind:value={$characterSettings.colors.object}
          type="color"
          name="objectExitTextColor"
          id="objectExitTextColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>

      <div
        class="col-span-2"
        data-tippy-content="The color of the On Ground label in both the Story Window and the Area Window."
      >
        <label
          for="onGroundLabelTextColor"
          class="block text-sm font-medium text-gray-300"
          >On Ground Label Text Color</label
        >
        <input
          bind:value={$characterSettings.colors.on_ground_label}
          type="color"
          name="onGroundLabelTextColor"
          id="onGroundLabelTextColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <div
        class="col-span-2"
        data-tippy-content="The color of commands echoed in the Story Window."
      >
        <label
          for="echoTextColor"
          class="block text-sm font-medium text-gray-300">Echo Text Color</label
        >
        <input
          bind:value={$characterSettings.colors.echo}
          type="color"
          name="echoTextColor"
          id="echoTextColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <div
        class="col-span-2"
        data-tippy-content="The color of the System Warning text in the Story Window."
      >
        <label
          for="sysWarnTextColor"
          class="block text-sm font-medium text-gray-300"
        >
          System Warning Text Color</label
        >
        <input
          bind:value={$characterSettings.colors.system_warning}
          type="color"
          name="sysWarnTextColor"
          id="sysWarnTextColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <div
        class="col-span-2"
        data-tippy-content="The color of the System Info text in the Story Window."
      >
        <label
          for="sysInfoTextColor"
          class="block text-sm font-medium text-gray-300"
          >System Info Text Color</label
        >
        <input
          bind:value={$characterSettings.colors.system_info}
          type="color"
          name="sysInfoTextColor"
          id="sysInfoTextColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <div
        class="col-span-2"
        data-tippy-content="The color of the System Alert text in the Story Window."
      >
        <label
          for="sysAlertTextColor"
          class="block text-sm font-medium text-gray-300"
          >System Alert Text Color</label
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

    <div class="col-span-4 grid grid-cols-12 gap-4">
      <h2
        class="text-center text-gray-300 border-b-2 border-primary col-span-12"
      >
        Area Window
      </h2>
      <div class="col-span-12">
        <label
          for="areaWindowBackgroundColor"
          class="block text-sm font-medium text-gray-300"
          >Background Color</label
        >
        <input
          bind:value={$characterSettings.areaWindow.background}
          type="color"
          name="areaWindowBackgroundColor"
          id="areaWindowBackgroundColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <div
        class="col-span-6"
        data-tippy-content="Whether to show the Area descripion at all. Can be toggled in the Area Window."
      >
        <label
          for="showDescription"
          class="block text-sm font-medium text-gray-300"
          >Show Description</label
        >
        <input
          bind:checked={$characterSettings.areaWindow.show_description}
          type="checkbox"
          name="showDescription"
          id="showDescription"
        />
      </div>
      <div
        class="col-span-6"
        data-tippy-content="This controls whether or not the Area Description is expanded when moving between areas. Open always opens it, Close always closes it, and Manual leaves it how you last left it."
      >
        <label
          for="descriptionExpansionMode"
          class="block text-sm font-medium text-gray-300"
          >Description Expansion Mode</label
        >
        <select
          id="descriptionExpansionMode"
          bind:value={$characterSettings.areaWindow.description_expansion_mode}
          name="descriptionExpansionMode"
          class="mt-1 block w-full py-2 px-3 border border-gray-300 bg-white rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
        >
          <option>manual</option>
          <option>open</option>
          <option>close</option>
        </select>
      </div>

      <div
        class="col-span-4"
        data-tippy-content="Whether to show the ToI at all. Can be toggled in the Area Window."
      >
        <label for="showToi" class="block text-sm font-medium text-gray-300"
          >Show Things Of Interest</label
        >
        <input
          bind:checked={$characterSettings.areaWindow.show_toi}
          type="checkbox"
          name="showToi"
          id="showToi"
        />
      </div>
      <div
        class="col-span-4"
        data-tippy-content="This controls whether or not the Area Description is expanded when moving between areas. Open always opens it, Close always closes it, and Manual leaves it how you last left it. The threshold variants automatically collapse when a threshold number of items has been met."
      >
        <label
          for="toiExpansionMode"
          class="block text-sm font-medium text-gray-300"
          >Things Of Interest Expansion Mode</label
        >
        <select
          id="toiExpansionMode"
          bind:value={$characterSettings.areaWindow.toi_expansion_mode}
          name="toiExpansionMode"
          class="mt-1 block w-full py-2 px-3 border border-gray-300 bg-white rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
        >
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
          class="block text-sm font-medium text-gray-300"
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

      <div
        class="col-span-4"
        data-tippy-content="Whether to show things On the Ground at all. Can be toggled in the Area Window."
      >
        <label
          for="showOnGround"
          class="block text-sm font-medium text-gray-300">Show On Ground</label
        >
        <input
          bind:checked={$characterSettings.areaWindow.show_on_ground}
          type="checkbox"
          name="showOnGround"
          id="showOnGround"
        />
      </div>
      <div
        class="col-span-4"
        data-tippy-content="This controls whether or not the Area Description is expanded when moving between areas. Open always opens it, Close always closes it, and Manual leaves it how you last left it. The threshold variants automatically collapse when a threshold number of items has been met."
      >
        <label
          for="onGroundExpansionMode"
          class="block text-sm font-medium text-gray-300"
          >On Ground Expansion Mode</label
        >
        <select
          id="onGroundExpansionMode"
          bind:value={$characterSettings.areaWindow.on_ground_expansion_mode}
          name="onGroundExpansionMode"
          class="mt-1 block w-full py-2 px-3 border border-gray-300 bg-white rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
        >
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
          class="block text-sm font-medium text-gray-300"
          >On Ground Collapse Threshold</label
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

      <div
        class="col-span-4"
        data-tippy-content="Whether to show other Characters at all. Can be toggled in the Area Window."
      >
        <label
          for="showAlsoPresent"
          class="block text-sm font-medium text-gray-300"
          >Show Also Present</label
        >
        <input
          bind:checked={$characterSettings.areaWindow.show_also_present}
          type="checkbox"
          name="showAlsoPresent"
          id="showAlsoPresent"
        />
      </div>
      <div
        class="col-span-4"
        data-tippy-content="This controls whether or not the Area Description is expanded when moving between areas. Open always opens it, Close always closes it, and Manual leaves it how you last left it. The threshold variants automatically collapse when a threshold number of items has been met."
      >
        <label
          for="alsoPresentExpansionMode"
          class="block text-sm font-medium text-gray-300"
          >Also Present Expansion Mode</label
        >
        <select
          id="alsoPresentExpansionMode"
          bind:value={$characterSettings.areaWindow.also_present_expansion_mode}
          name="alsoPresentExpansionMode"
          class="mt-1 block w-full py-2 px-3 border border-gray-300 bg-white rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
        >
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
          class="block text-sm font-medium text-gray-300"
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

      <div
        class="col-span-4"
        data-tippy-content="Whether to show the Exits at all. Can be toggled in the Area Window."
      >
        <label for="showExits" class="block text-sm font-medium text-gray-300"
          >Show Exits</label
        >
        <input
          bind:checked={$characterSettings.areaWindow.show_exits}
          type="checkbox"
          name="showExits"
          id="showExits"
        />
      </div>
      <div
        class="col-span-4"
        data-tippy-content="This controls whether or not the Area Description is expanded when moving between areas. Open always opens it, Close always closes it, and Manual leaves it how you last left it. The threshold variants automatically collapse when a threshold number of items has been met."
      >
        <label
          for="exitsExpansionMode"
          class="block text-sm font-medium text-gray-300"
          >Exits Expansion Mode</label
        >
        <select
          id="exitsExpansionMode"
          bind:value={$characterSettings.areaWindow.exits_expansion_mode}
          name="exitsExpansionMode"
          class="mt-1 block w-full py-2 px-3 border border-gray-300 bg-white rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
        >
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
          class="block text-sm font-medium text-gray-300"
          >Exits Collapse Threshold</label
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

      <div
        class="col-span-6"
        data-tippy-content="The overall expansion settings can be used with the individual ones to help ensure that there is flexibility in how many individual items can be displayed at any given time while still providing protection for limited space."
      >
        <label
          for="overallExpansionMode"
          class="block text-sm font-medium text-gray-300"
          >Overall Expansion Mode</label
        >
        <select
          id="overallExpansionMode"
          bind:value={$characterSettings.areaWindow.total_collapse_mode}
          name="overallExpansionMode"
          class="mt-1 block w-full py-2 px-3 border border-gray-300 bg-white rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
        >
          <option>largest</option>
          <option>smallest</option>
          <option>all</option>
          <option>none</option>
        </select>
      </div>
      <div class="col-span-6">
        <label
          for="overallThreshold"
          class="block text-sm font-medium text-gray-300"
          >Overall Collapse Threshold</label
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
          class="block text-sm font-medium text-gray-300"
          >Filter Border Color</label
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
          class="block text-sm font-medium text-gray-300"
          >Filter Active Icon Color</label
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
          class="block text-sm font-medium text-gray-300"
          >Filter Inactive Icon Color</label
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
          class="block text-sm font-medium text-gray-300"
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
          class="block text-sm font-medium text-gray-300"
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
      <!-- <div class="col-span-6">
        <label
          for="showQuickActions"
          class="block text-sm font-medium text-gray-300"
          >Show Quick Actions</label
        >
        <input
          bind:checked={$characterSettings.areaWindow.show_quick_actions}
          type="checkbox"
          name="showQuickActions"
          id="showQuickActions"
        />
      </div> -->
      <!-- <div class="col-span-4">
        <label
          for="areaWindowDisabledQuickActionColor"
          class="block text-sm font-medium text-gray-300"
          >Disabled Quick Action Color</label
        >
        <input
          bind:value={$characterSettings.areaWindow.disabled_quick_action_color}
          type="color"
          name="areaWindowDisabledQuickActionColor"
          id="areaWindowDisabledQuickActionColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div> -->
    </div>

    <div class="col-span-4 grid grid-cols-8 gap-4">
      <h2
        class="text-center text-gray-300 border-b-2 border-primary col-span-8"
      >
        Inventory Window
      </h2>
      <div class="col-span-4">
        <label
          for="inventoryWindowBackgroundColor"
          class="block text-sm font-medium text-gray-300"
          >Background Color</label
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
          class="block text-sm font-medium text-gray-300"
          >Empty Hand Text Color</label
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
          class="block text-sm font-medium text-gray-300"
          >Held Items Label Color</label
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
          class="block text-sm font-medium text-gray-300"
          >Worn Items With Pockets Label</label
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
          class="block text-sm font-medium text-gray-300"
          >Worn Clothes Label</label
        >
        <input
          bind:value={$characterSettings.inventoryWindow.worn_clothes_label}
          type="color"
          name="wornClothesLabel"
          id="wornClothesLabel"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <!-- <div class="col-span-4">
        <label
          for="wornArmorLabel"
          class="block text-sm font-medium text-gray-300"
          >Worn Armor Label</label
        >
        <input
          bind:value={$characterSettings.inventoryWindow.worn_armor_label}
          type="color"
          name="wornArmorLabel"
          id="wornArmorLabel"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div> -->
      <!-- <div class="col-span-4">
        <label
          for="wornWeaponsLabel"
          class="block text-sm font-medium text-gray-300"
          >Worn Weapons Label</label
        >
        <input
          bind:value={$characterSettings.inventoryWindow.worn_weapons_label}
          type="color"
          name="wornWeaponsLabel"
          id="wornWeaponsLabel"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div> -->
      <!-- <div class="col-span-4">
        <label
          for="wornJewelryLabel"
          class="block text-sm font-medium text-gray-300"
          >Worn Jewelry Label</label
        >
        <input
          bind:value={$characterSettings.inventoryWindow.worn_jewelry_label}
          type="color"
          name="wornJewelryLabel"
          id="wornJewelryLabel"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div> -->
      <div class="col-span-4">
        <label
          for="wornSlotsLabel"
          class="block text-sm font-medium text-gray-300">Slots Label</label
        >
        <input
          bind:value={$characterSettings.inventoryWindow.slots_label}
          type="color"
          name="wornSlotsLabel"
          id="wornSlotsLabel"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <div class="col-span-4">
        <label
          for="filterBorderColorColor"
          class="block text-sm font-medium text-gray-300"
          >Filter Border Color</label
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
          class="block text-sm font-medium text-gray-300"
          >Filter Active Icon Color</label
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
          class="block text-sm font-medium text-gray-300"
          >Filter Inactive Icon Color</label
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
          class="block text-sm font-medium text-gray-300"
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
          class="block text-sm font-medium text-gray-300"
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

    <div class="col-span-4 grid grid-cols-8 gap-4">
      <h2
        class="text-center text-gray-300 border-b-2 border-primary col-span-8"
      >
        Map Window
      </h2>
      <div class="col-span-4">
        <label
          for="unexploredLinkColor"
          class="block text-sm font-medium text-gray-300"
          >Unexplored Link Color</label
        >
        <input
          bind:value={$characterSettings.mapWindow.unexplored_link_color}
          type="color"
          name="unexploredLinkColor"
          id="unexploredLinkColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <div class="col-span-4">
        <label
          for="highlightedAreaColor"
          class="block text-sm font-medium text-gray-300"
          >Highlighted Area Color</label
        >
        <input
          bind:value={$characterSettings.mapWindow.highlighted_area_color}
          type="color"
          name="highlightedAreaColor"
          id="highlightedAreaColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
      </div>
      <div class="col-span-4">
        <label
          for="backgroundColor"
          class="block text-sm font-medium text-gray-300"
          >Background Color</label
        >
        <input
          bind:value={$characterSettings.mapWindow.background_color}
          type="color"
          name="backgroundColor"
          id="backgroundColor"
          class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
        />
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
{/if}
