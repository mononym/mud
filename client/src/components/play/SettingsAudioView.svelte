<script>
  import { getContext } from "svelte";
  import { key } from "./state";
  import tippy from "tippy.js";
  import "tippy.js/dist/tippy.css";
  import { onMount } from "svelte";

  const state = getContext(key);
  const {
    AudioStore,
    characterSettings,
    resetCharacterSettings,
    saveCharacterSettings,
  } = state;

  let settingsChanged = true;

  onMount(() => {
    tippy("[data-tippy-content]");
  });

  async function saveAudioSettings() {
    if (await saveCharacterSettings()) {
      AudioStore.updateStoreWithCharacterSettings($characterSettings.audio)
      // AudioStore.updateMusicVolume(
      //   parseFloat($characterSettings.audio.music_volume / 100).toFixed(2)
      // );
    }
  }
</script>

{#if $characterSettings != undefined}
  <form
    class="container grid grid-cols-8 gap-4"
    on:submit|preventDefault={saveAudioSettings}
  >
    <div class="col-span-4 grid grid-cols-8 gap-4">
      <div class="col-span-4 grid grid-cols-12 gap-4">
        <h2
          class="text-center text-gray-300 border-b-2 border-primary col-span-12"
        >
          General Audio Configuration
        </h2>
        <div
          class="col-span-4"
          data-tippy-content="Whether to play background music at all. This includes general 'atmosphere/thematic' music including battle music."
        >
          <label for="playMusic" class="block text-sm font-medium text-gray-300"
            >Play Music</label
          >
          <input
            bind:checked={$characterSettings.audio.play_music}
            type="checkbox"
            name="playMusic"
            id="playMusic"
          />
        </div>
        <div
          class="col-span-8"
          data-tippy-content="Music volume is managed seperately from ambient sounds and sound effects."
        >
          <label
            for="musicVolume"
            class="block text-sm font-medium text-gray-300">Music Volume</label
          >
          <input
            bind:value={$characterSettings.audio.music_volume}
            type="range"
            id="musicVolume"
            name="musicVolume"
            min="0"
            max="100"
            step="5"
          />
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
    </div>
  </form>
{/if}
