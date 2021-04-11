<script>
  import { getContext } from "svelte";
  import { key } from "./state";

  const state = getContext(key);
  const {
    settingsView,
    selectSettingsHotkeysView,
    selectSettingsGeneralView,
    selectSettingsCommandsView,
    selectSettingsAudioView
  } = state;
</script>

<nav class="bg-gray-700 flex-shrink">
  <div class="flex items-baseline space-x-4">
    <button
      on:click={selectSettingsGeneralView}
      class="px-3 py-2 text-sm font-medium focus:outline-none {$settingsView ==
      'general'
        ? 'text-white border-primary border-b-2'
        : 'text-gray-300 hover:text-white hover:bg-gray-600'} ">General</button
    >

    <button
      on:click={selectSettingsHotkeysView}
      class="px-3 py-2 text-sm font-medium focus:outline-none {$settingsView ==
      'hotkeys'
        ? 'text-white border-primary border-b-2'
        : 'text-gray-300 hover:text-white hover:bg-gray-600'}">Hotkeys</button
    >

    <button
      on:click={selectSettingsCommandsView}
      class="px-3 py-2 text-sm font-medium focus:outline-none {$settingsView ==
      'commands'
        ? 'text-white border-primary border-b-2'
        : 'text-gray-300 hover:text-white hover:bg-gray-600'}">Commands</button
    >

    <button
      on:click={selectSettingsAudioView}
      class="px-3 py-2 text-sm font-medium focus:outline-none {$settingsView ==
      'audio'
        ? 'text-white border-primary border-b-2'
        : 'text-gray-300 hover:text-white hover:bg-gray-600'}">Audio</button
    >
  </div>
</nav>
