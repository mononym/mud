<script>
  import ClientSvgMap from "./ClientSvgMap.svelte";
  import { State } from "./state";

  const {
    selectedCharacter,
    knownMapsIndex,
    knownAreasForCharacterMap,
    knownAreasForCharacterMapIndex,
    knownLinksForCharacterMap,
  } = State;

  let svgMap;
</script>

<div class="h-full w-full">
  <ClientSvgMap
    bind:this={svgMap}
    chosenMap={$knownMapsIndex[$knownAreasForCharacterMapIndex[$selectedCharacter.areaId].mapId]}
    mapsMap={$knownMapsIndex}
    areasMap={$knownAreasForCharacterMapIndex}
    links={$knownLinksForCharacterMap}
    areas={$knownAreasForCharacterMap}
    svgMapAllowInterMapAreaSelection={true}
    svgMapAllowIntraMapAreaSelection={true}
    highlightedAreaIds={[$selectedCharacter.areaId]}
    highlightedLinkIds={[]}
    focusAreaId={$selectedCharacter.areaId} />
</div>
