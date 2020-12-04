<script>
  import { Circle2 } from "svelte-loading-spinners";
  import Svg from "../../../../../components/Svg.svelte";
  import { MapsStore } from "../../../../../stores/maps";
  const { maps } = MapsStore;
  import { WorldBuilderStore } from "./state";
  const {
    mapSelected,
    selectedMap,
    loadAllMapData,
    areas,
    links,
    loadingMapData,
  } = WorldBuilderStore;

  // Stuff to draw
  $: if ($mapSelected) {
    loadAllMapData($selectedMap.id);
  }

  // Zoom stuff
  let zoomMultipliers = [0.00775, 0.015, 0.03, 0.06, 0.125, 0.25, 0.5];
  let zoomMultierIndex = 3;
  $: zoomOutButtonDisabled = zoomMultierIndex == zoomMultipliers.length - 1;
  $: zoomInButtonDisabled = zoomMultierIndex == 0;

  // Aspect ratio
  let svgWrapperWidth = 16;
  let svgWrapperHeight = 9;

  // Viewbox sizing
  let xCenterPoint = 0;
  let yCenterPoint = 0;
  let viewBoxX = 0;
  let viewBoxY = 0;
  let viewBoxXSize = 0;
  let viewBoxYSize = 0;
  let viewBox = "";

  let chosenMap;

  selectedMap.subscribe((newMap) => {
    chosenMap = newMap;
    xCenterPoint = chosenMap.viewSize / 2;
    yCenterPoint = chosenMap.viewSize / 2;
    calculateViewBox();
  });

  function calculateViewBox() {
    viewBoxXSize = chosenMap.viewSize * zoomMultipliers[zoomMultierIndex];
    viewBoxYSize =
      chosenMap.viewSize *
      (svgWrapperWidth / svgWrapperHeight) *
      zoomMultipliers[zoomMultierIndex];
    viewBoxX = (xCenterPoint - viewBoxXSize / 2).toString();
    viewBoxY = (yCenterPoint - viewBoxYSize / 2).toString();
    viewBox =
      viewBoxX + " " + viewBoxY + " " + viewBoxXSize + " " + viewBoxYSize;
  }

  function zoomIn() {
    zoomMultierIndex = --zoomMultierIndex;
    calculateViewBox();
  }

  function zoomOut() {
    zoomMultierIndex = ++zoomMultierIndex;
    calculateViewBox();
  }
</script>

<div
  class="p-1 h-full w-full max-w-full max-h-full flex flex-col {$mapSelected ? '' : 'place-content-center'}">
  {#if $mapSelected}
    {#if $loadingMapData}
      <div class="flex-1 flex flex-col items-center justify-center">
        <Circle2 />
        <h2 class="mt-6 text-center text-3xl font-extrabold text-gray-500">
          Loading map data
        </h2>
      </div>
    {:else}
      <p class="flex-shrink text-gray-300 w-full text-center">
        {$selectedMap.name}
      </p>
      <div
        class="flex-1 overflow-hidden"
        bind:clientWidth={svgWrapperWidth}
        bind:clientHeight={svgWrapperHeight}>
        <Svg {viewBox} />
      </div>
      <div class="flex">
        <button
          on:click={zoomIn}
          disabled={zoomInButtonDisabled}
          type="button"
          class="flex-1 rounded-l-md {zoomInButtonDisabled ? 'text-gray-600 bg-gray-500' : 'bg-gray-300 text-black hover:text-gray-500 hover:bg-gray-400'} p-2 focus:outline-none {zoomInButtonDisabled ? 'cursor-not-allowed' : 'cursor-pointer'}"><i
            class="fas fa-plus" /></button>
        <button
          on:click={zoomOut}
          disabled={zoomOutButtonDisabled}
          type="button"
          class="flex-1 rounded-r-md {zoomOutButtonDisabled ? 'text-gray-600 bg-gray-500' : 'bg-gray-300 text-black hover:text-gray-500 hover:bg-gray-400'} p-2 focus:outline-none {zoomOutButtonDisabled ? 'cursor-not-allowed' : 'cursor-pointer'}"><i
            class="fas fa-minus" /></button>
      </div>
    {/if}
  {:else}
    <p class="text-gray-300 text-center">Select a map</p>
  {/if}
</div>
