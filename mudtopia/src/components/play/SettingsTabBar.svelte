<script>
  import { State } from "./state";
  const {
    settingsView,
    selectSettingsView,
    selectPlayView,
  } = State;


</script>

<nav class="bg-gray-800 flex-shrink">
  <div class="flex items-baseline space-x-4">
    <button
      on:click={selectPlayView}
      class="px-3 py-2 rounded-md text-sm font-medium {$settingsView == 'text' ? 'text-white bg-gray-900' : 'text-gray-300 hover:text-white hover:bg-gray-700'} ">Text</button>

    <button
      on:click={selectSettingsView}
      class="px-3 py-2 rounded-md text-sm font-medium {$settingsView == 'settings' ? 'text-white bg-gray-900' : 'text-gray-300 hover:text-white hover:bg-gray-700'}">Settings</button>
  </div>
</nav>
