<script>
  import { WorldBuilderStore } from "./state";
  const {
    linkUnderConstruction,
    selectedMap,
    selectedArea,
    areasForLinkEditorFiltered,
    loadDataForLinkEditor,
    loadingLinkEditorData,
    linkEditorMapForOtherAreaId,
    cancelLinkArea,
  } = WorldBuilderStore;
  import { MapsStore } from "../../stores/maps";
  const { maps } = MapsStore;
  import { AreasStore } from "../../stores/areas";
  const { areasMap } = AreasStore;
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
    if ($linkUnderConstruction.flags.direction) {
      $linkUnderConstruction.departureText =
        $linkUnderConstruction.shortDescription;
      $linkUnderConstruction.longDescription =
        $linkUnderConstruction.shortDescription;
    }
  }

  async function handleMapForOtherAreaChange() {
    WorldBuilderStore.changeMapForLinkEditor($linkEditorMapForOtherAreaId);
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
    if ($linkUnderConstruction.id == "") {
      setOutgoing();
    } else if ($linkUnderConstruction.toId == $selectedArea.id) {
      direction = "incoming";
    } else {
      direction = "outgoing";
    }
  });
</script>

<form
  class="h-full flex flex-col place-content-center"
  on:submit|preventDefault={WorldBuilderStore.saveLink}
>
  <div class="overflow-hidden sm:rounded-md">
    <div class="px-4 py-5 sm:p-6">
      <div class="grid grid-cols-12 gap-6">
        <div class="col-span-12 grid grid-cols-8">
          <button
            on:click={setOutgoing}
            class="col-span-4 {direction == 'outgoing'
              ? 'bg-gray-400 text-white'
              : 'hover:bg-gray-500 hover:text-gray-100'} text-gray-200 bg-transparent border border-solid border-gray-400 font-bold uppercase text-xs px-4 py-2 rounded outline-none focus:outline-none mr-1 mb-1"
            type="button"
            style="transition: all .15s ease"
          >
            <i class="fas fa-link" />
            Outgoing
          </button>
          <button
            on:click={setIncoming}
            class="col-span-4 {direction == 'incoming'
              ? 'bg-gray-400 text-white'
              : ' hover:bg-gray-500 hover:text-gray-100'} text-gray-200 bg-transparent border border-solid border-gray-400 active:bg-gray-500 font-bold uppercase text-xs px-4 py-2 rounded outline-none focus:outline-none mr-1 mb-1"
            type="button"
            style="transition: all .15s ease"
          >
            <i class="fas fa-edit" />
            Incoming
          </button>
        </div>
        <div class="col-span-6">
          <label
            for="mapForOtherArea"
            class="block text-sm font-medium text-gray-300"
            >Map containing the area on the other side of the link</label
          >
          <!-- svelte-ignore a11y-no-onchange -->
          <select
            id="mapForOtherArea"
            bind:value={$linkEditorMapForOtherAreaId}
            on:change={handleMapForOtherAreaChange}
            name="mapForOtherArea"
            class="mt-1 block w-full py-2 px-3 border border-gray-300 bg-white rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
          >
            {#each $maps as map}
              <option value={map.id}>{map.name}</option>
            {/each}
          </select>
        </div>
        <div class="col-span-6">
          <label
            for="mapForOtherArea"
            class="block text-sm font-medium text-gray-300"
            >Area on the other side of the link</label
          >
          <!-- svelte-ignore a11y-no-onchange -->
          {#if direction == "incoming"}
            <select
              id="otherArea"
              bind:value={$linkUnderConstruction.fromId}
              name="otherArea"
              class="mt-1 block w-full py-2 px-3 border border-gray-300 bg-white rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
            >
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
              class="mt-1 block w-full py-2 px-3 border border-gray-300 bg-white rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
            >
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
          <div class="col-span-1">
            <label for="mtxc" class="block text-sm font-medium text-gray-300"
              >To X</label
            >
            <input
              bind:value={$linkUnderConstruction.localToX}
              type="number"
              name="mtxc"
              id="mtxc"
              min="-5000"
              max="5000"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
            />
          </div>

          <div class="col-span-1">
            <label for="mtyc" class="block text-sm font-medium text-gray-300"
              >To Y</label
            >
            <input
              bind:value={$linkUnderConstruction.localToY}
              type="number"
              name="mtyc"
              id="mtyc"
              min="-5000"
              max="5000"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
            />
          </div>

          <div class="col-span-1">
            <label for="mtsize" class="block text-sm font-medium text-gray-300"
              >To Area Size</label
            >
            <input
              bind:value={$linkUnderConstruction.localToSize}
              type="number"
              name="mtsize"
              id="mtsize"
              min="1"
              max="999"
              step="2"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
            />
          </div>

          <div class="col-span-1">
            <label
              for="localToCorners"
              class="block text-sm font-medium text-gray-300">To Corners</label
            >
            <input
              bind:value={$linkUnderConstruction.localToCorners}
              type="number"
              min="0"
              max={Math.ceil($linkUnderConstruction.localToSize / 2)}
              step="1"
              name="localToCorners"
              id="localToCorners"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
            />
          </div>
          <div class="col-span-2">
            <label
              for="localToLineWidth"
              class="block text-sm font-medium text-gray-300"
              >To Line Width</label
            >
            <input
              bind:value={$linkUnderConstruction.localToLineWidth}
              type="number"
              name="localToLineWidth"
              id="localToLineWidth"
              min="1"
              max="100"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
            />
          </div>
          <div class="col-span-2">
            <label
              for="localToLineDash"
              class="block text-sm font-medium text-gray-300"
              >To Line Dash</label
            >
            <input
              bind:value={$linkUnderConstruction.localToLineDash}
              type="number"
              name="localToLineDash"
              id="localToLineDash"
              min="0"
              max="100"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
            />
          </div>
          <div class="col-span-2">
            <label
              for="localToLineColor"
              class="block text-sm font-medium text-gray-300"
              >To Line Color</label
            >
            <input
              bind:value={$linkUnderConstruction.localToLineColor}
              type="color"
              name="localToLineColor"
              id="localToLineColor"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
            />
          </div>
          <div class="col-span-2">
            <label
              for="localToColor"
              class="block text-sm font-medium text-gray-300"
              >To Area Color</label
            >
            <input
              bind:value={$linkUnderConstruction.localToColor}
              type="color"
              name="localToColor"
              id="localToColor"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
            />
          </div>
          <div class="col-span-6">
            <label
              for="localToLabel"
              class="block text-sm font-medium text-gray-300">To Label</label
            >
            <textarea
              bind:value={$linkUnderConstruction.localToLabel}
              name="localToLabel"
              id="localToLabel"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
            />
          </div>
          <div class="col-span-2">
            <label
              for="localToLabelColor"
              class="block text-sm font-medium text-gray-300"
              >To Label Color</label
            >
            <input
              bind:value={$linkUnderConstruction.localToLabelColor}
              type="color"
              name="localToLabelColor"
              id="localToLabelColor"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
            />
          </div>

          <div class="col-span-1">
            <label
              for="localToLabelVerticalOffset"
              class="block text-sm font-medium text-gray-300"
              >To Label VOffset</label
            >
            <input
              bind:value={$linkUnderConstruction.localToLabelVerticalOffset}
              type="number"
              name="localToLabelVerticalOffset"
              id="localToLabelVerticalOffset"
              min="-200"
              max="200"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
            />
          </div>
          <div class="col-span-1">
            <label
              for="localToLabelHorizontalOffset"
              class="block text-sm font-medium text-gray-300"
              >To Label HOffset</label
            >
            <input
              bind:value={$linkUnderConstruction.localToLabelHorizontalOffset}
              type="number"
              name="localToLabelHorizontalOffset"
              id="localToLabelHorizontalOffset"
              min="-200"
              max="200"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
            />
          </div>
          <div class="col-span-1">
            <label
              for="localToLabelFontSize"
              class="block text-sm font-medium text-gray-300"
              >To Label Font size</label
            >
            <input
              bind:value={$linkUnderConstruction.localToLabelFontSize}
              type="number"
              name="localToLabelFontSize"
              id="localToLabelfontSize"
              min="4"
              max="100"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
            />
          </div>

          <div class="col-span-1">
            <label
              for="localToLabelRotation"
              class="block text-sm font-medium text-gray-300"
              >To Label Rotation</label
            >
            <input
              bind:value={$linkUnderConstruction.localToLabelRotation}
              type="number"
              name="localToLabelRotation"
              id="localToLabelRotation"
              min="-359"
              max="359"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
            />
          </div>

          <div class="col-span-1">
            <label for="mfxc" class="block text-sm font-medium text-gray-300"
              >From X</label
            >
            <input
              bind:value={$linkUnderConstruction.localFromX}
              type="number"
              name="mfxc"
              id="mfxc"
              min="-5000"
              max="5000"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
            />
          </div>

          <div class="col-span-1">
            <label for="mtyc" class="block text-sm font-medium text-gray-300"
              >From Y</label
            >
            <input
              bind:value={$linkUnderConstruction.localFromY}
              type="number"
              name="mfyc"
              id="mfyc"
              min="-5000"
              max="5000"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
            />
          </div>

          <div class="col-span-1">
            <label for="mfsize" class="block text-sm font-medium text-gray-300"
              >From Area Size</label
            >
            <input
              bind:value={$linkUnderConstruction.localFromSize}
              type="number"
              name="mfsize"
              id="mfsize"
              min="1"
              max="999"
              step="2"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
            />
          </div>

          <div class="col-span-1">
            <label
              for="localFromCorners"
              class="block text-sm font-medium text-gray-300"
              >From Corners</label
            >
            <input
              bind:value={$linkUnderConstruction.localFromCorners}
              type="number"
              min="0"
              max={Math.ceil($linkUnderConstruction.localFromSize / 2)}
              step="1"
              name="localFromCorners"
              id="localFromCorners"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
            />
          </div>
          <div class="col-span-2">
            <label
              for="localFromLineWidth"
              class="block text-sm font-medium text-gray-300"
              >From Line Width</label
            >
            <input
              bind:value={$linkUnderConstruction.localFromLineWidth}
              type="number"
              name="localFromLineWidth"
              id="localFromLineWidth"
              min="1"
              max="100"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
            />
          </div>
          <div class="col-span-2">
            <label
              for="localFromLineDash"
              class="block text-sm font-medium text-gray-300"
              >From Line Dash</label
            >
            <input
              bind:value={$linkUnderConstruction.localFromLineDash}
              type="number"
              name="localFromLineDash"
              id="localFromLineDash"
              min="0"
              max="100"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
            />
          </div>
          <div class="col-span-2">
            <label
              for="localFromLineColor"
              class="block text-sm font-medium text-gray-300"
              >From Line Color</label
            >
            <input
              bind:value={$linkUnderConstruction.localFromLineColor}
              type="color"
              name="localFromLineColor"
              id="localFromLineColor"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
            />
          </div>
          <div class="col-span-2">
            <label
              for="localFromColor"
              class="block text-sm font-medium text-gray-300"
              >From Area Color</label
            >
            <input
              bind:value={$linkUnderConstruction.localFromColor}
              type="color"
              name="localFromColor"
              id="localFromColor"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
            />
          </div>
          <div class="col-span-6">
            <label
              for="localFromLabel"
              class="block text-sm font-medium text-gray-300">From Label</label
            >
            <textarea
              bind:value={$linkUnderConstruction.localFromLabel}
              name="localFromLabel"
              id="localFromLabel"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
            />
          </div>
          <div class="col-span-2">
            <label
              for="localFromLabelColor"
              class="block text-sm font-medium text-gray-300"
              >From Label Color</label
            >
            <input
              bind:value={$linkUnderConstruction.localFromLabelColor}
              type="color"
              name="localFromLabelColor"
              id="localFromLabelColor"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
            />
          </div>

          <div class="col-span-1">
            <label
              for="localFromLabelVerticalOffset"
              class="block text-sm font-medium text-gray-300"
              >From Label VOffset</label
            >
            <input
              bind:value={$linkUnderConstruction.localFromLabelVerticalOffset}
              type="number"
              name="localFromLabelVerticalOffset"
              id="localFromLabelVerticalOffset"
              min="-200"
              max="200"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
            />
          </div>
          <div class="col-span-1">
            <label
              for="localFromLabelHorizontalOffset"
              class="block text-sm font-medium text-gray-300"
              >From Label HOffset</label
            >
            <input
              bind:value={$linkUnderConstruction.localFromLabelHorizontalOffset}
              type="number"
              name="localFromLabelHorizontalOffset"
              id="localFromLabelHorizontalOffset"
              min="-200"
              max="200"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
            />
          </div>
          <div class="col-span-1">
            <label
              for="localFromLabelFontSize"
              class="block text-sm font-medium text-gray-300"
              >From Label Font size</label
            >
            <input
              bind:value={$linkUnderConstruction.localFromLabelFontSize}
              type="number"
              name="localFromLabelFontSize"
              id="localFromLabelfontSize"
              min="4"
              max="100"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
            />
          </div>

          <div class="col-span-1">
            <label
              for="localFromLabelRotation"
              class="block text-sm font-medium text-gray-300"
              >From Label Rotation</label
            >
            <input
              bind:value={$linkUnderConstruction.localFromLabelRotation}
              type="number"
              name="localFromLabelRotation"
              id="localFromLabelRotation"
              min="-359"
              max="359"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
            />
          </div>
        {:else}
          <div class="col-span-1">
            <label
              for="lineWidth"
              class="block text-sm font-medium text-gray-300">Line Width</label
            >
            <input
              bind:value={$linkUnderConstruction.lineWidth}
              type="number"
              name="lineWidth"
              id="lineWidth"
              min="1"
              max="100"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
            />
          </div>
          <div class="col-span-1">
            <label
              for="lineDash"
              class="block text-sm font-medium text-gray-300">Line Dash</label
            >
            <input
              bind:value={$linkUnderConstruction.lineDash}
              type="number"
              name="lineDash"
              id="lineDash"
              min="0"
              max="100"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
            />
          </div>
          <div class="col-span-1">
            <label
              for="lineColor"
              class="block text-sm font-medium text-gray-300">Line Color</label
            >
            <input
              bind:value={$linkUnderConstruction.lineColor}
              type="color"
              name="lineColor"
              id="lineColor"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
            />
          </div>
          <div class="col-span-1">
            <label
              for="hasMarker"
              class="block text-sm font-medium text-gray-300">Has Marker?</label
            >
            <input
              bind:checked={$linkUnderConstruction.hasMarker}
              type="checkbox"
              name="hasMarker"
              id="hasMarker"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
            />
          </div>
          <div class="col-span-1">
            <label
              for="markerOffset"
              class="block text-sm font-medium text-gray-300"
              >Marker Offset</label
            >
            <input
              bind:value={$linkUnderConstruction.markerOffset}
              type="number"
              name="markerOffset"
              min="0"
              max="100"
              id="markerOffset"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
            />
          </div>
          <div class="col-span-1">
            <label for="label" class="block text-sm font-medium text-gray-300"
              >Label</label
            >
            <textarea
              bind:value={$linkUnderConstruction.label}
              name="label"
              id="label"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
            />
          </div>
          <div class="col-span-1">
            <label for="label" class="block text-sm font-medium text-gray-300"
              >Label Color</label
            >
            <input
              bind:value={$linkUnderConstruction.labelColor}
              type="color"
              name="label"
              id="label"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
            />
          </div>

          {#if $linkUnderConstruction.label != ""}
            <div class="col-span-1">
              <label
                for="verticalOffset"
                class="block text-sm font-medium text-gray-300"
                >Vertical offset</label
              >
              <input
                bind:value={$linkUnderConstruction.labelVerticalOffset}
                type="number"
                name="verticalOffset"
                id="verticalOffset"
                min="-200"
                max="200"
                class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
              />
            </div>
            <div class="col-span-1">
              <label
                for="horizontalOffset"
                class="block text-sm font-medium text-gray-300"
                >Horizontal offset</label
              >
              <input
                bind:value={$linkUnderConstruction.labelHorizontalOffset}
                type="number"
                name="horizontalOffset"
                id="horizontalOffset"
                min="-200"
                max="200"
                class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
              />
            </div>
            <div class="col-span-1">
              <label
                for="fontSize"
                class="block text-sm font-medium text-gray-300">Font size</label
              >
              <input
                bind:value={$linkUnderConstruction.labelFontSize}
                type="number"
                name="fontSize"
                id="fontSize"
                min="4"
                max="100"
                class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
              />
            </div>

            <div class="col-span-1">
              <label
                for="labelRotation"
                class="block text-sm font-medium text-gray-300"
                >Label Rotation</label
              >
              <input
                bind:value={$linkUnderConstruction.labelRotation}
                type="number"
                name="labelRotation"
                id="labelRotation"
                min="-359"
                max="359"
                class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
              />
            </div>
          {/if}
        {/if}

        <div class="col-span-1">
          <label
            for="isDirection"
            class="block text-sm font-medium text-gray-300">Is Direction</label
          >
          <input
            bind={$linkUnderConstruction.flags.direction}
            type="radio"
            group="linkType"
            name="isDirection"
            id="isDirection"
            class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
          />
        </div>

        <div class="col-span-1">
          <label
            for="isClosable"
            class="block text-sm font-medium text-gray-300">Is Closable</label
          >
          <input
            bind={$linkUnderConstruction.flags.closable}
            type="radio"
            group="linkType"
            name="isClosable"
            id="isClosable"
            class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
          />
        </div>

        <div class="col-span-1">
          <label for="isPortal" class="block text-sm font-medium text-gray-300"
            >Is Portal</label
          >
          <input
            bind={$linkUnderConstruction.flags.portal}
            type="radio"
            group="linkType"
            name="isPortal"
            id="isPortal"
            class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
          />
        </div>

        <div class="col-span-1">
          <label for="isObject" class="block text-sm font-medium text-gray-300"
            >Is Object</label
          >
          <input
            bind={$linkUnderConstruction.flags.object}
            type="radio"
            group="linkType"
            name="isObject"
            id="isObject"
            class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
          />
        </div>

        {#if !$linkUnderConstruction.flags.direction}
          <div class="col-span-1 flex flex-col place-content-center">
            <i
              class="{$linkUnderConstruction.icon} text-center text-4xl text-gray-200"
            />
          </div>
          <!-- <div class="col-span-1">
            <label for="icon" class="block text-sm font-medium text-gray-300"
              >Icon</label
            >
            <select
              id="icon"
              bind:value={$linkUnderConstruction.icon}
              name="type"
              class="mt-1 block w-full py-2 px-3 border border-gray-300 bg-white rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
            >
              <option>fas fa-compass</option>
              <option>fas fa-door-closed</option>
              <option>fas fa-dungeon</option>
              <option>fas fa-archway</option>
              <option>fas fa-hiking</option>
              <option>fas fa-certificate</option>
            </select>
          </div> -->
          <div class="col-span-2">
            <label
              for="shortDescription"
              class="block text-sm font-medium text-gray-300"
              >Short Description</label
            >
            <textarea
              bind:value={$linkUnderConstruction.shortDescription}
              name="shortDescription"
              id="shortDescription"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
            />
          </div>
          <div class="col-span-2">
            <label
              for="longDescription"
              class="block text-sm font-medium text-gray-300"
              >Long Description</label
            >
            <textarea
              bind:value={$linkUnderConstruction.longDescription}
              name="longDescription"
              id="longDescription"
              class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
            />
          </div>
        {:else}
          <div class="col-span-3">
            <label
              for="shortDescription"
              class="block text-sm font-medium text-gray-300"
              >Short Description</label
            >
            <!-- svelte-ignore a11y-no-onchange -->
            <select
              id="shortDescription"
              bind:value={$linkUnderConstruction.shortDescription}
              on:change={handleShortDescriptionChange}
              name="type"
              class="mt-1 block w-full py-2 px-3 border border-gray-300 bg-white rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
            >
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
        <div class="col-span-2">
          <label
            for="departureText"
            class="block text-sm font-medium text-gray-300"
            >Departure Text</label
          >
          <input
            bind:value={$linkUnderConstruction.departureText}
            type="text"
            name="departureText"
            id="departureText"
            class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
          />
        </div>
        <div class="col-span-2">
          <label
            for="arrivalText"
            class="block text-sm font-medium text-gray-300">Arrival Text</label
          >
          <input
            bind:value={$linkUnderConstruction.arrivalText}
            type="text"
            name="arrivalText"
            id="arrivalText"
            class="mt-1 bg-gray-400 text-black focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
          />
        </div>
      </div>

      <div class="px-4 py-3 text-right sm:px-6">
        <button
          disabled={saveButtonDisabled}
          type="submit"
          class="{saveButtonDisabled
            ? 'bg-indigo-800 text-gray-500 cursor-not-allowed'
            : 'bg-indigo-600 hover:bg-indigo-700 text-white'} inline-flex justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-md focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
        >
          Save
        </button>
        <button
          on:click={cancel}
          class="inline-flex justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
        >
          Cancel
        </button>
      </div>
    </div>
  </div>
</form>
