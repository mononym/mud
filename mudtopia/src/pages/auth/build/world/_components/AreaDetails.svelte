<script>
  import { MapsStore } from "../../../../../stores/maps";
  import { AreasStore } from "../../../../../stores/areas";
  const { mapsMap } = MapsStore;
  const { areasMap } = AreasStore;
  import { WorldBuilderStore } from "./state";
  import LinkList from "./LinkList.svelte";
  const {
    areaSelected,
    selectedArea,
    incomingLinksForSelectedArea,
    outgoingLinksForSelectedArea,
    areasForLinkEditorMap,
  } = WorldBuilderStore;
</script>

{#if $areaSelected}
  <div class="h-full w-full flex flex-col p-1 place-content-center">
    <h2 class="text-center text-gray-300">{$selectedArea.name}</h2>
    <p class="text-center text-gray-300">{$selectedArea.description}</p>
    <p class="text-center text-gray-300">
      Map X Coordinate:
      {$selectedArea.mapX}
    </p>
    <p class="text-center text-gray-300">
      Map Y Coordinate:
      {$selectedArea.mapY}
    </p>
    <p class="text-center text-gray-300">Map Size: {$selectedArea.mapSize}</p>
    <div class="grid grid-cols-2">
      <div class="bg-gray-800 text-white rounded-l">
        <h2 class="text-center">Incoming Links</h2>
        <LinkList mapsMap={$mapsMap} links={$incomingLinksForSelectedArea} areasMap={$areasMap} />
        <!-- {#each $incomingLinksForSelectedArea as link, i}
          <p class="text-center {i % 2 == 0 ? 'bg-gray-500 hover:bg-gray-700' : 'bg-gray-600 hover:bg-gray-700'}">
            {#if $areasMap[link.fromId].mapId != $selectedArea.mapId}
              {$mapsMap[$areasMap[link.fromId].mapId].name}
              -
            {/if}
            {$areasMap[link.fromId].name}
            :
            {link.shortDescription}
            {'->'}
            {link.arrivalText}
          </p>
        {/each} -->
      </div>
      <div class="bg-gray-800 text-white border-l-2 rounded-r border-black">
        <h2 class="text-center">Outgoing Links</h2>
        {#each $outgoingLinksForSelectedArea as link, i}
          <p class="text-center {i % 2 == 0 ? 'bg-gray-500 hover:bg-gray-700' : 'bg-gray-600 hover:bg-gray-700'}">
            {link.shortDescription}
            {'->'}
            {link.arrivalText}
            :
            {$areasMap[link.toId].name}
          </p>
        {/each}
      </div>
    </div>
  </div>
{:else}
  <div class="h-full w-full flex flex-col place-content-center p-1">
    <p class="text-gray-300 text-center">Select an area to view its details</p>
  </div>
{/if}
