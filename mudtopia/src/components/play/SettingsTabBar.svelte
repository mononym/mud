<script>
  import { getContext } from "svelte";
  import { key } from "./state";

  const state = getContext(key);
  const {
    settingsView,
    selectSettingsHotkeysView,
    selectSettingsGeneralView,
  } = state;
</script>

<nav class="bg-gray-800 flex-shrink">
  <div class="flex items-baseline space-x-4">
    <button
      on:click={selectSettingsGeneralView}
      class="px-3 py-2 rounded-md text-sm font-medium {$settingsView ==
      'general'
        ? 'text-white bg-gray-900'
        : 'text-gray-300 hover:text-white hover:bg-gray-700'} ">General</button
    >

    <button
      on:click={selectSettingsHotkeysView}
      class="px-3 py-2 rounded-md text-sm font-medium {$settingsView ==
      'hotkeys'
        ? 'text-white bg-gray-900'
        : 'text-gray-300 hover:text-white hover:bg-gray-700'}">Hotkeys</button
    >
  </div>
</nav>
