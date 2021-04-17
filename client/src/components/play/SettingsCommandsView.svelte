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
    class="container grid grid-cols-8 gap-4"
    on:submit|preventDefault={saveCharacterSettings}
  >
    <div class="col-span-4 grid grid-cols-8 gap-4">
      <div class="col-span-4 grid grid-cols-12 gap-4">
        <h2
          class="text-center text-gray-300 border-b-2 border-primary col-span-12"
        >
          Command Behavior Configuration
        </h2>
        <div
          class="col-span-6"
          data-tippy-content="In simple mode input is parsed with the expectation that there will be spaces between words. For example, `get a wooden sword`. In this mode `get awoodensword` would not return a result. Advanced mode, however, is far more powerful and flexible. In Advanced mode, each entered letter is checked only for its relation to other letters while ignoring any whitespace. That means that `get awoodensword` will work. As will `get woodensword` or `get awoswo`."
        >
          <label
            for="searchMode"
            style="color:{$characterSettings.commands.search_mode}"
            class="block text-sm font-medium text-gray-300"
            >Item Search Mode</label
          >
          <select
            id="searchMode"
            bind:value={$characterSettings.commands.search_mode}
            name="searchMode"
            class="mt-1 block w-full py-2 px-3 border border-gray-300 bg-gray-400 rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
          >
            <option>simple</option>
            <option>advanced</option>
          </select>
        </div>
        <div class="col-span-6">
          <label
            for="multipleMatchMode"
            style="color:{$characterSettings.commands.multiple_matches_mode}"
            class="block text-sm font-medium text-gray-300"
            >Multiple Item Match Mode</label
          >
          <select
            id="multipleMatchMode"
            bind:value={$characterSettings.commands.multiple_matches_mode}
            name="multipleMatchMode"
            class="mt-1 block w-full py-2 px-3 border border-gray-300 bg-gray-400 rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
          >
            <option>full path</option>
            <option>item only</option>
            <!-- <option>choose item</option> -->
            <option>silent</option>
          </select>
        </div>
        <div
          class="col-span-6"
          data-tippy-content="If selected the '/emotes' used in the SAY command must be full and exact. There will be no fuzzy/partial matching.."
        >
          <label
            for="sayRequiresExactEmote"
            class="block text-sm font-medium text-gray-300"
            >Say Requires Exact Emote</label
          >
          <input
            bind:checked={$characterSettings.commands.say_requires_exact_emote}
            type="checkbox"
            name="sayRequiresExactEmote"
            id="sayRequiresExactEmote"
          />
        </div>
      </div>
      <div class="col-span-4 text-right sm:px-6">
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
    </div>
  </form>
{/if}
