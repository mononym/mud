<script>
  import { get } from "svelte/store";
  import { createEventDispatcher } from "svelte";
  const dispatch = createEventDispatcher();
  import { WorldBuilderStore } from "./state";
  const {
    linkUnderConstruction,
    selectedMap,
    selectedArea,
    linkPreviewAreaId,
    areasForLinkEditor,
    loadAreasForLinkEditor,
    linkEditorMapForOtherAreaId,
    cancelLinkArea,
  } = WorldBuilderStore;
  import { LinksStore } from "../../../../../stores/links";
  import { MapsStore } from "../../../../../stores/maps";
  import { AreasStore } from "../../../../../stores/areas";
  const { maps } = MapsStore;
  const { areas } = AreasStore;
  import { onMount } from "svelte";

  let direction;

  let otherAreaId = "";

  function save() {
    const fromId = direction == "incoming" ? otherAreaId : $selectedArea.id;
    const toId = direction == "outgoing" ? otherAreaId : $selectedArea.id;
    const icon =
      $linkUnderConstruction.type == "direction"
        ? "fas fa-compass"
        : this.workingLink.icon;

    $linkUnderConstruction.toId = toId;
    $linkUnderConstruction.fromId = fromId;
    $linkUnderConstruction.icon = icon;

    LinksStore.saveLink($linkUnderConstruction).then((updatedLink) =>
      dispatch("save", updatedLink)
    );
  }

  function cancel() {
    cancelLinkArea();
  }

  async function handleMapForOtherAreaChange() {
    if (direction == "incoming") {
      $linkUnderConstruction.fromId = "";
    } else {
      $linkUnderConstruction.toId = "";
    }

    WorldBuilderStore.loadAreasForLinkEditor($linkEditorMapForOtherAreaId);
  }

  function handleTypeChange() {
    // Do whatever is needed
  }

  function setIncoming() {
    $linkUnderConstruction.fromId = $linkUnderConstruction.toId;
    $linkUnderConstruction.toId = $selectedArea.id;
    direction = "incoming";
  }

  function setOutgoing() {
    $linkUnderConstruction.toId = $linkUnderConstruction.fromId;
    $linkUnderConstruction.fromId = $selectedArea.id;
    direction = "outgoing";
  }

  onMount(async () => {
    $linkEditorMapForOtherAreaId = $selectedMap.id;

    setOutgoing();
    loadAreasForLinkEditor($linkEditorMapForOtherAreaId);
  });
</script>

<form
  class="h-full flex flex-col place-content-center"
  on:submit|preventDefault={save}>
  <div class="overflow-hidden sm:rounded-md">
    <div class="px-4 py-5 sm:p-6">
      <div class="grid grid-cols-6 gap-6">
        <div class="col-span-6 grid grid-cols-6">
          <button
            on:click={setOutgoing}
            class="col-span-3 {direction == 'outgoing' ? 'bg-gray-400 text-white' : 'hover:bg-gray-500 hover:text-gray-100'} text-gray-200 bg-transparent border border-solid border-gray-400 font-bold uppercase text-xs px-4 py-2 rounded outline-none focus:outline-none mr-1 mb-1"
            type="button"
            style="transition: all .15s ease">
            <i class="fas fa-link" />
            Outgoing
          </button>
          <button
            on:click={setIncoming}
            class="col-span-3 {direction == 'incoming' ? 'bg-gray-400 text-white' : ' hover:bg-gray-500 hover:text-gray-100'} text-gray-200 bg-transparent border border-solid border-gray-400 active:bg-gray-500 font-bold uppercase text-xs px-4 py-2 rounded outline-none focus:outline-none mr-1 mb-1"
            type="button"
            style="transition: all .15s ease">
            <i class="fas fa-edit" />
            Incoming
          </button>
        </div>
        <div class="col-span-6">
          <label
            for="mapForOtherArea"
            class="block text-sm font-medium text-gray-700" />
          <!-- svelte-ignore a11y-no-onchange -->
          <select
            id="mapForOtherArea"
            bind:value={$linkEditorMapForOtherAreaId}
            on:change={handleMapForOtherAreaChange}
            name="mapForOtherArea"
            class="mt-1 block w-full py-2 px-3 border border-gray-300 bg-white rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm">
            {#each $maps as map}
              <option value={map.id}>{map.name}</option>
            {/each}
          </select>
        </div>
        <div class="col-span-6">
          <label
            for="otherArea"
            class="block text-sm font-medium text-gray-700" />
          <!-- svelte-ignore a11y-no-onchange -->
          {#if direction == 'incoming'}
            <select
              id="otherArea"
              bind:value={$linkUnderConstruction.fromId}
              name="otherArea"
              class="mt-1 block w-full py-2 px-3 border border-gray-300 bg-white rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm">
              <option hidden disabled selected value>
                -- select an area --
              </option>
              {#each $areasForLinkEditor as area}
                <option value={area.id}>{area.name}</option>
              {/each}
            </select>
          {:else}
            <select
              id="otherArea"
              bind:value={$linkUnderConstruction.toId}
              name="otherArea"
              class="mt-1 block w-full py-2 px-3 border border-gray-300 bg-white rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm">
              <option hidden disabled selected value>
                -- select an area --
              </option>
              {#each $areasForLinkEditor as area}
                <option value={area.id}>{area.name}</option>
              {/each}
            </select>
          {/if}
        </div>

        {#if $linkEditorMapForOtherAreaId != $selectedMap.id && direction == 'outgoing'}
          <label for="mtxc" class="block text-sm font-medium text-gray-300">Map
            Local To X Coordinate</label>
          <input
            bind:value={$linkUnderConstruction.localToX}
            type="number"
            name="mtxc"
            id="mtxc"
            min="-5000"
            max="5000"
            class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />

          <label for="mtyc" class="block text-sm font-medium text-gray-300">Map
            Local To Y Coordinate</label>
          <input
            bind:value={$linkUnderConstruction.localToY}
            type="number"
            name="mtyc"
            id="mtyc"
            min="-5000"
            max="5000"
            class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />

          <label
            for="mtsize"
            class="block text-sm font-medium text-gray-300">Map Local Size</label>
          <input
            bind:value={$linkUnderConstruction.localToSize}
            type="number"
            name="mtsize"
            id="mtsize"
            min="1"
            max="99"
            step="2"
            class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />

          <div class="col-span-3">
            <label
              for="localToCorners"
              class="block text-sm font-medium text-gray-300">How rounded the
              corners are for the local link</label>
            <input
              bind:value={$linkUnderConstruction.localToCorners}
              type="number"
              min="0"
              max={Math.ceil($linkUnderConstruction.localToSize / 2).toString()}
              step="1"
              name="localToCorners"
              id="localToCorners"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
          </div>
        {:else if $linkEditorMapForOtherAreaId != $selectedMap.id && direction == 'incoming'}
          <div class="col-span-3">
            <label
              for="mfxc"
              class="block text-sm font-medium text-gray-300">Map Local From X
              Coordinate</label>
            <input
              bind:value={$linkUnderConstruction.localFromX}
              type="number"
              name="mfxc"
              id="mfxc"
              min="-5000"
              max="5000"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
          </div>
          <div class="col-span-3">
            <label
              for="mfyc"
              class="block text-sm font-medium text-gray-300">Map Local From Y
              Coordinate</label>
            <input
              bind:value={$linkUnderConstruction.localFromY}
              type="number"
              name="mfyc"
              id="mfyc"
              min="-5000"
              max="5000"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
          </div>
          <div class="col-span-3">
            <label
              for="mfsize"
              class="block text-sm font-medium text-gray-300">Map Local Size</label>
            <input
              bind:value={$linkUnderConstruction.localFromSize}
              type="number"
              name="mfsize"
              id="mfsize"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
          </div>
          <div class="col-span-3">
            <label
              for="localFromCorners"
              class="block text-sm font-medium text-gray-300">How rounded the
              corners are for the local link</label>
            <input
              bind:value={$linkUnderConstruction.localFromCorners}
              type="number"
              min="0"
              max={Math.ceil($linkUnderConstruction.localFromSize / 2).toString()}
              step="1"
              name="localFromCorners"
              id="localFromCorners"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
          </div>
          <div class="col-span-3">
            <label
              for="localFromColors"
              class="block text-sm font-medium text-gray-300">The color of local
              area</label>
            <input
              bind:value={$linkUnderConstruction.localFromColor}
              type="color"
              name="localFromCorners"
              id="localFromCorners"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
          </div>
        {/if}
        <div class="col-span-6">
          <label for="type" class="block text-sm font-medium text-gray-700">Link
            Type</label>
          <select
            id="type"
            bind:value={$linkUnderConstruction.type}
            on:blur={handleTypeChange}
            name="type"
            class="mt-1 block w-full py-2 px-3 border border-gray-300 bg-white rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm">
            <option>Direction</option>
            <option>Object</option>
          </select>
        </div>
        {#if $linkUnderConstruction.type == 'Object'}
          <div class="col-span-1 flex flex-col place-content-center">
            <i
              class="{$linkUnderConstruction.icon} text-center text-4xl text-gray-200" />
          </div>
          <div class="col-span-5">
            <label
              for="icon"
              class="block text-sm font-medium text-gray-700">Icon</label>
            <select
              id="icon"
              bind:value={$linkUnderConstruction.icon}
              name="type"
              class="mt-1 block w-full py-2 px-3 border border-gray-300 bg-white rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm">
              <option hidden disabled selected value>
                -- select an icon --
              </option>
              <option>fas fa-door-closed</option>
              <option>fas fa-dungeon</option>
              <option>fas fa-archway</option>
              <option>fas fa-hiking</option>
              <option>fas fa-certificate</option>
            </select>
          </div>
          <div class="col-span-6">
            <label
              for="shortDescription"
              class="block text-sm font-medium text-gray-300">Short Description</label>
            <input
              bind:value={$linkUnderConstruction.shortDescription}
              type="text"
              name="shortDescription"
              id="shortDescription"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
          </div>
          <div class="col-span-6">
            <label
              for="longDescription"
              class="block text-sm font-medium text-gray-300">Long Description</label>
            <input
              bind:value={$linkUnderConstruction.longDescription}
              type="text"
              name="longDescription"
              id="longDescription"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
          </div>
          <div class="col-span-6">
            <label
              for="departureText"
              class="block text-sm font-medium text-gray-300">Departure Text</label>
            <input
              bind:value={$linkUnderConstruction.departureText}
              type="text"
              name="departureText"
              id="departureText"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
          </div>
        {:else}
          <div class="col-span-6">
            <label
              for="shortDescription"
              class="block text-sm font-medium text-gray-700">Short Description</label>
            <select
              id="shortDescription"
              bind:value={$linkUnderConstruction.shortDescription}
              name="type"
              class="mt-1 block w-full py-2 px-3 border border-gray-300 bg-white rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm">
              <option hidden disabled selected value>
                -- select a direction --
              </option>
              <option>north</option>
              <option>northeast</option>
              <option>northwest</option>
              <option>west</option>
              <option>east</option>
              <option>southwest</option>
              <option>southeast</option>
              <option>south</option>
              <option>up</option>
              <option>down</option>
              <option>in</option>
              <option>out</option>
            </select>
          </div>
        {/if}
        <div class="col-span-6">
          <label
            for="arrivalText"
            class="block text-sm font-medium text-gray-300">Arrival Text</label>
          <input
            bind:value={$linkUnderConstruction.arrivalText}
            type="text"
            name="arrivalText"
            id="arrivalText"
            class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
        </div>
      </div>
      <div class="px-4 py-3 text-right sm:px-6">
        <button
          type="submit"
          class="inline-flex justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500">
          Save
        </button>
        <button
          on:click={cancel}
          class="inline-flex justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500">
          Cancel
        </button>
      </div>
    </div>
  </div>
</form>
