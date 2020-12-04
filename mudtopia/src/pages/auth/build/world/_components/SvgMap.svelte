<script>
  import { MapsStore } from "../../../../../stores/maps";
  const { maps } = MapsStore;
  import { WorldBuilderStore } from "./state";
  const { mapSelected, selectedMap } = WorldBuilderStore;

  // Zoom stuff
  let zoomMultipliers = [0.03, 0.06, 0.125, 0.25, 0.5, 1];
  let zoomMultierIndex = 2;
  $: zoomOutButtonDisabled = zoomMultierIndex == zoomMultipliers.length - 1;
  $: zoomInButtonDisabled = zoomMultierIndex == 0;

  // Aspect ratio
  let svgWidth = 16;
  let svgHeight = 9;
  $: aspectRatioMultiplier = svgWidth / svgHeight;

  // Viewbox sizing
  // $: xCenterPoint = chosenMap.viewSize / 2;
  // $: yCenterPoint = chosenMap.viewSize / 2;
  // $: viewBoxX = (xCenterPoint - viewBoxXSize / 2).toString();
  // $: viewBoxY = (yCenterPoint - viewBoxYSize / 2).toString();
  // $: viewBoxXSize = chosenMap.viewSize * zoomMultiplier;
  // $: viewBoxYSize = chosenMap.viewSize * aspectRatioMultiplier * zoomMultiplier;
  // $: viewBox =
  //   viewBoxX + " " + viewBoxY + " " + viewBoxXSize + " " + viewBoxYSize;
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
    viewBoxXSize = chosenMap.viewSize * zoomMultipliers[zoomMultierIndex];
    viewBoxYSize =
      chosenMap.viewSize *
      (svgWidth / svgHeight) *
      zoomMultipliers[zoomMultierIndex];
    viewBoxX = (xCenterPoint - viewBoxXSize / 2).toString();
    viewBoxY = (yCenterPoint - viewBoxYSize / 2).toString();
    viewBox =
      viewBoxX + " " + viewBoxY + " " + viewBoxXSize + " " + viewBoxYSize;
  });

  function zoomIn() {
    zoomMultierIndex = --zoomMultierIndex;
  }

  function zoomOut() {
    zoomMultierIndex = ++zoomMultierIndex;
  }
</script>

<div
  class="p-1 h-full w-full flex flex-col {$mapSelected ? '' : 'place-content-center'}">
  {#if $mapSelected}
    <p class="flex-shrink text-gray-300 w-full text-center">
      {$selectedMap.name}
    </p>
    <svg class="flex-1" {viewBox} preserveAspectRatio="xMidYMid meet" />
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
  {:else}
    <p class="text-gray-300 text-center">Select a map</p>
  {/if}
</div>
