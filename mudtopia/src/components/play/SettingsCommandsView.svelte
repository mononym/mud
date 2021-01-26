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
      <div class="col-span-4 grid grid-cols-12 gap-4">
        <h2 class="text-center text-white border-b-2 border-black col-span-12">
          Command Behavior Configuration
        </h2>
        <div class="col-span-6">
          <label
            for="searchMode"
            style="color:{$characterSettings.commands.search_mode}"
            class="block text-sm font-medium">Item Search Mode</label
          >
          <select
            id="searchMode"
            bind:value={$characterSettings.commands.search_mode}
            name="searchMode"
            class="mt-1 block w-full py-2 px-3 border border-gray-300 bg-white rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm">
            <option>simple</option>
            <option>advanced</option>
          </select>
        </div>
        <div class="col-span-6">
          <label
            for="multipleMatchMode"
            style="color:{$characterSettings.commands.multiple_matches_mode}"
            class="block text-sm font-medium">Multiple Item Match Mode</label
          >
          <select
            id="multipleMatchMode"
            bind:value={$characterSettings.commands.multiple_matches_mode}
            name="multipleMatchMode"
            class="mt-1 block w-full py-2 px-3 border border-gray-300 bg-white rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm">
            <option>alert</option>
            <option>choose</option>
            <option>silent</option>
          </select>
        </div>
      </div>
    </div>
  </form>
{/if}
