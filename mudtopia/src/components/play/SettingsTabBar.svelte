<script>
  import { State } from "./state";
  const {
    settingsView,
    selectSettingsHotkeysView,
    selectSettingsColorsView,
  } = State;
</script>

<nav class="bg-gray-800 flex-shrink">
  <div class="flex items-baseline space-x-4">
    <button
      on:click={selectSettingsColorsView}
      class="px-3 py-2 rounded-md text-sm font-medium {$settingsView == 'colors' ? 'text-white bg-gray-900' : 'text-gray-300 hover:text-white hover:bg-gray-700'} ">Colors</button>

    <button
      on:click={selectSettingsHotkeysView}
      class="px-3 py-2 rounded-md text-sm font-medium {$settingsView == 'hotkeys' ? 'text-white bg-gray-900' : 'text-gray-300 hover:text-white hover:bg-gray-700'}">Hotkeys</button>
  </div>
</nav>
