<script>
  import { createEventDispatcher } from "svelte";
  import { WorldBuilderStore } from "./state";
  const {
    linkUnderConstruction,
    selectedMap,
    selectedArea,
    areasForLinkEditorFiltered,
    loadDataForLinkEditor,
    linkEditorMapForOtherAreaId,
    cancelLinkArea,
  } = WorldBuilderStore;
  import { MapsStore } from "../../../../../stores/maps";
  const { maps } = MapsStore;
  import { onMount } from "svelte";

  let direction;

  $: saveButtonDisabled =
    $linkUnderConstruction.toId == "" ||
    $linkUnderConstruction.fromId == "" ||
    $linkUnderConstruction.longDescription == "" ||
    $linkUnderConstruction.departureText == "" ||
    $linkUnderConstruction.arrivalText == "" ||
    $linkUnderConstruction.shortDescription == "" ||
    $linkUnderConstruction.icon == "" ||
    $linkUnderConstruction.longDescription == "";

  function cancel() {
    cancelLinkArea();
  }
  function handleShortDescriptionChange() {
    if ($linkUnderConstruction.type == "Direction") {
      $linkUnderConstruction.departureText =
        $linkUnderConstruction.shortDescription;
      $linkUnderConstruction.longDescription =
        $linkUnderConstruction.shortDescription;
    }
  }

  async function handleMapForOtherAreaChange() {
    if (direction == "incoming") {
      $linkUnderConstruction.fromId = "";
    } else {
      $linkUnderConstruction.toId = "";
    }

    WorldBuilderStore.loadDataForLinkEditor($linkEditorMapForOtherAreaId);
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

    if ($linkUnderConstruction.id == "") {
      setOutgoing();
    } else if ($linkUnderConstruction.toId == $selectedArea.id) {
      direction = "incoming";
    } else {
      ("outgoing");
    }

    loadDataForLinkEditor($linkEditorMapForOtherAreaId);
  });
</script>

<form
  class="h-full flex flex-col place-content-center"
  on:submit|preventDefault={WorldBuilderStore.saveLink}>
  <div class="overflow-hidden sm:rounded-md">
    <div class="px-4 py-5 sm:p-6">
      <div class="grid grid-cols-8 gap-6">
        <div class="col-span-8 grid grid-cols-6">
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
        <div class="col-span-4">
          <label
            for="mapForOtherArea"
            class="block text-sm font-medium text-gray-300">Map containing the
            area on the other side of the link</label>
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
        <div class="col-span-4">
          <label
            for="mapForOtherArea"
            class="block text-sm font-medium text-gray-300">Area on the other
            side of the link</label>
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
              {#each $areasForLinkEditorFiltered as area}
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
              {#each $areasForLinkEditorFiltered as area}
                <option value={area.id}>{area.name}</option>
              {/each}
            </select>
          {/if}
        </div>

        {#if $linkEditorMapForOtherAreaId != $selectedMap.id}
          <div class="col-span-2">
            <label
              for="mtxc"
              class="block text-sm font-medium text-gray-300">Map Local To X
              Coordinate</label>
            <input
              bind:value={$linkUnderConstruction.localToX}
              type="number"
              name="mtxc"
              id="mtxc"
              min="-5000"
              max="5000"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
          </div>

          <div class="col-span-2">
            <label
              for="mtyc"
              class="block text-sm font-medium text-gray-300">Map Local To Y
              Coordinate</label>
            <input
              bind:value={$linkUnderConstruction.localToY}
              type="number"
              name="mtyc"
              id="mtyc"
              min="-5000"
              max="5000"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
          </div>

          <div class="col-span-2">
            <label
              for="mtsize"
              class="block text-sm font-medium text-gray-300">Map Local Size</label>
            <input
              bind:value={$linkUnderConstruction.localToSize}
              type="number"
              name="mtsize"
              id="mtsize"
              min="1"
              max="999"
              step="2"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
          </div>

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
          <div class="col-span-3">
            <label
              for="localToColor"
              class="block text-sm font-medium text-gray-300">The color of local
              area</label>
            <input
              bind:value={$linkUnderConstruction.localToColor}
              type="color"
              name="localToColor"
              id="localToColor"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
          </div>
          <div class="col-span-2">
            <label
              for="localToLineWidth"
              class="block text-sm font-medium text-gray-300">Line Width</label>
            <input
              bind:value={$linkUnderConstruction.localToLineWidth}
              type="number"
              name="localToLineWidth"
              id="localToLineWidth"
              min="1"
              max="100"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
          </div>
          <div class="col-span-2">
            <label
              for="localToLineDash"
              class="block text-sm font-medium text-gray-300">Line Dash</label>
            <input
              bind:value={$linkUnderConstruction.localToLineDash}
              type="number"
              name="localToLineDash"
              id="localToLineDash"
              min="0"
              max="100"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
          </div>
          <div class="col-span-2">
            <label
              for="localToLineColor"
              class="block text-sm font-medium text-gray-300">Line Color</label>
            <input
              bind:value={$linkUnderConstruction.localToLineColor}
              type="color"
              name="localToLineColor"
              id="localToLineColor"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
          </div>
          <div class="col-span-4">
            <label
              for="label"
              class="block text-sm font-medium text-gray-300">Label</label>
            <textarea
              bind:value={$linkUnderConstruction.localToLabel}
              name="label"
              id="label"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
          </div>
          <div class="col-span-2">
            <label
              for="localColor"
              class="block text-sm font-medium text-gray-300">Label Color</label>
            <input
              bind:value={$linkUnderConstruction.localToLabelColor}
              type="color"
              name="localColor"
              id="localColor"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
          </div>

          {#if $linkUnderConstruction.localToLabel != ''}
            <div class="col-span-2">
              <label
                for="verticalOffset"
                class="block text-sm font-medium text-gray-300">Vertical offset</label>
              <input
                bind:value={$linkUnderConstruction.localToLabelVerticalOffset}
                type="number"
                name="verticalOffset"
                id="verticalOffset"
                min="-200"
                max="200"
                class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
            </div>
            <div class="col-span-2">
              <label
                for="horizontalOffset"
                class="block text-sm font-medium text-gray-300">Horizontal
                offset</label>
              <input
                bind:value={$linkUnderConstruction.localToLabelHorizontalOffset}
                type="number"
                name="horizontalOffset"
                id="horizontalOffset"
                min="-200"
                max="200"
                class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
            </div>
            <div class="col-span-2">
              <label
                for="fontSize"
                class="block text-sm font-medium text-gray-300">Font size</label>
              <input
                bind:value={$linkUnderConstruction.localToLabelFontSize}
                type="number"
                name="fontSize"
                id="fontSize"
                min="8"
                max="100"
                class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
            </div>

            <div class="col-span-2">
              <label
                for="labelRotation"
                class="block text-sm font-medium text-gray-300">Label Rotation</label>
              <input
                bind:value={$linkUnderConstruction.localToLabelRotation}
                type="number"
                name="labelRotation"
                id="labelRotation"
                min="-359"
                max="359"
                class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
            </div>
          {/if}
          <div class="col-span-2">
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
          <div class="col-span-2">
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
          <div class="col-span-2">
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
              for="localFromColor"
              class="block text-sm font-medium text-gray-300">The color of local
              area</label>
            <input
              bind:value={$linkUnderConstruction.localFromColor}
              type="color"
              name="localFromColor"
              id="localFromColor"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
          </div>
          <div class="col-span-2">
            <label
              for="localFromLineWidth"
              class="block text-sm font-medium text-gray-300">Line Width</label>
            <input
              bind:value={$linkUnderConstruction.localFromLineWidth}
              type="number"
              name="localFromLineWidth"
              id="localFromLineWidth"
              min="1"
              max="100"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
          </div>
          <div class="col-span-2">
            <label
              for="localFromLineDash"
              class="block text-sm font-medium text-gray-300">Line Dash</label>
            <input
              bind:value={$linkUnderConstruction.localFromLineDash}
              type="number"
              name="localFromLineDash"
              id="localFromLineDash"
              min="0"
              max="100"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
          </div>
          <div class="col-span-2">
            <label
              for="localFromLineColor"
              class="block text-sm font-medium text-gray-300">Line Color</label>
            <input
              bind:value={$linkUnderConstruction.localFromLineColor}
              type="color"
              name="localFromLineColor"
              id="localFromLineColor"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
          </div>
        {:else}
          <div class="col-span-2">
            <label
              for="lineWidth"
              class="block text-sm font-medium text-gray-300">Line Width</label>
            <input
              bind:value={$linkUnderConstruction.lineWidth}
              type="number"
              name="lineWidth"
              id="lineWidth"
              min="1"
              max="100"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
          </div>
          <div class="col-span-2">
            <label
              for="lineDash"
              class="block text-sm font-medium text-gray-300">Line Dash</label>
            <input
              bind:value={$linkUnderConstruction.lineDash}
              type="number"
              name="lineDash"
              id="lineDash"
              min="0"
              max="100"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
          </div>
          <div class="col-span-4">
            <label
              for="lineColor"
              class="block text-sm font-medium text-gray-300">Line Color</label>
            <input
              bind:value={$linkUnderConstruction.lineColor}
              type="color"
              name="lineColor"
              id="lineColor"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
          </div>
          <div class="col-span-4">
            <label
              for="label"
              class="block text-sm font-medium text-gray-300">Label</label>
            <textarea
              bind:value={$linkUnderConstruction.label}
              name="label"
              id="label"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
          </div>
          <div class="col-span-4">
            <label
              for="label"
              class="block text-sm font-medium text-gray-300">Label Color</label>
            <input
              bind:value={$linkUnderConstruction.labelColor}
              type="color"
              name="label"
              id="label"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
          </div>

          {#if $linkUnderConstruction.label != ''}
            <div class="col-span-2">
              <label
                for="verticalOffset"
                class="block text-sm font-medium text-gray-300">Vertical offset</label>
              <input
                bind:value={$linkUnderConstruction.labelVerticalOffset}
                type="number"
                name="verticalOffset"
                id="verticalOffset"
                min="-200"
                max="200"
                class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
            </div>
            <div class="col-span-2">
              <label
                for="horizontalOffset"
                class="block text-sm font-medium text-gray-300">Horizontal
                offset</label>
              <input
                bind:value={$linkUnderConstruction.labelHorizontalOffset}
                type="number"
                name="horizontalOffset"
                id="horizontalOffset"
                min="-200"
                max="200"
                class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
            </div>
            <div class="col-span-2">
              <label
                for="fontSize"
                class="block text-sm font-medium text-gray-300">Font size</label>
              <input
                bind:value={$linkUnderConstruction.labelFontSize}
                type="number"
                name="fontSize"
                id="fontSize"
                min="8"
                max="100"
                class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
            </div>

            <div class="col-span-2">
              <label
                for="labelRotation"
                class="block text-sm font-medium text-gray-300">Label Rotation</label>
              <input
                bind:value={$linkUnderConstruction.labelRotation}
                type="number"
                name="labelRotation"
                id="labelRotation"
                min="-359"
                max="359"
                class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
            </div>
          {/if}
        {/if}
        <div class="col-span-4">
          <label for="type" class="block text-sm font-medium text-gray-300">Link
            Type</label>
          <select
            id="type"
            bind:value={$linkUnderConstruction.type}
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
          <div class="col-span-3">
            <label
              for="icon"
              class="block text-sm font-medium text-gray-300">Icon</label>
            <select
              id="icon"
              bind:value={$linkUnderConstruction.icon}
              name="type"
              class="mt-1 block w-full py-2 px-3 border border-gray-300 bg-white rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm">
              <option>fas fa-compass</option>
              <option>fas fa-door-closed</option>
              <option>fas fa-dungeon</option>
              <option>fas fa-archway</option>
              <option>fas fa-hiking</option>
              <option>fas fa-certificate</option>
            </select>
          </div>
          <div class="col-span-3">
            <label
              for="shortDescription"
              class="block text-sm font-medium text-gray-300">Short Description</label>
            <textarea
              bind:value={$linkUnderConstruction.shortDescription}
              name="shortDescription"
              id="shortDescription"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
          </div>
          <div class="col-span-5">
            <label
              for="longDescription"
              class="block text-sm font-medium text-gray-300">Long Description</label>
            <textarea
              bind:value={$linkUnderConstruction.longDescription}
              name="longDescription"
              id="longDescription"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md" />
          </div>
        {:else}
          <div class="col-span-4">
            <label
              for="shortDescription"
              class="block text-sm font-medium text-gray-300">Short Description</label>
            <!-- svelte-ignore a11y-no-onchange -->
            <select
              id="shortDescription"
              bind:value={$linkUnderConstruction.shortDescription}
              on:change={handleShortDescriptionChange}
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
        <div class="col-span-4">
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
        <div class="col-span-4">
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
          disabled={saveButtonDisabled}
          type="submit"
          class="{saveButtonDisabled ? 'bg-indigo-800 text-gray-500 cursor-not-allowed' : 'bg-indigo-600 hover:bg-indigo-700 text-white'} inline-flex justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-md focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500">
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
