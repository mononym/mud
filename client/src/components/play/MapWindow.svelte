<script>
  import ClientSvgMap from "./ClientSvgMap.svelte";
  import { getContext } from "svelte";
  import { key } from "./state";

  const state = getContext(key);

  function handleMouseWheelScrollOverMap(event) {
    if (event.deltaY < 0) {
      zoomMapIn();
    } else {
      zoomMapOut();
    }
  }

  const {
    selectedCharacter,
    knownMapsIndex,
    knownAreasForCharacterMap,
    knownAreasForCharacterMapIndex,
    knownLinksForCharacterMap,
    mapZoomMultipliers,
    mapZoomMultiplierIndex,
    zoomMapIn,
    zoomMapOut,
    mapAtMinZoom,
    mapAtMaxZoom,
    exploredAreas,
  } = state;

  let svgMap;
</script>

<div
  on:mousewheel={handleMouseWheelScrollOverMap}
  class="h-full w-full flex flex-col"
  style="background-color:{$selectedCharacter.settings.mapWindow[
    'background_color'
  ]}"
>
  <div style="height:calc(100% - 40px)" class="w-full">
    <ClientSvgMap
      bind:this={svgMap}
      chosenMap={$knownMapsIndex[
        $knownAreasForCharacterMapIndex[$selectedCharacter.areaId].mapId
      ]}
      mapsMap={$knownMapsIndex}
      areasMap={$knownAreasForCharacterMapIndex}
      links={$knownLinksForCharacterMap}
      areas={$knownAreasForCharacterMap}
      svgMapAllowInterMapAreaSelection={true}
      svgMapAllowIntraMapAreaSelection={true}
      highlightedAreaIds={[$selectedCharacter.areaId]}
      highlightedLinkIds={[]}
      focusAreaId={$selectedCharacter.areaId}
      zoomMultiplier={$mapZoomMultipliers[$mapZoomMultiplierIndex]}
      exploredAreas={$exploredAreas}
      mapSettings={$selectedCharacter.settings.mapWindow}
    />
  </div>
  <div class="flex" style="height:40px">
    <button
      on:click={zoomMapIn}
      disabled={$mapAtMinZoom}
      type="button"
      class="flex-1 {$mapAtMinZoom
        ? 'text-gray-600 bg-gray-500'
        : 'bg-gray-300 text-black hover:text-gray-500 hover:bg-gray-400'} p-2 focus:outline-none {$mapAtMinZoom
        ? 'cursor-not-allowed'
        : 'cursor-pointer'}"><i class="fas fa-plus" /></button
    >
    <button
      on:click={zoomMapOut}
      disabled={$mapAtMaxZoom}
      type="button"
      class="flex-1 {$mapAtMaxZoom
        ? 'text-gray-600 bg-gray-500'
        : 'bg-gray-300 text-black hover:text-gray-500 hover:bg-gray-400'} p-2 focus:outline-none {$mapAtMaxZoom
        ? 'cursor-not-allowed'
        : 'cursor-pointer'}"><i class="fas fa-minus" /></button
    >
  </div>
</div>
