<script>
  import { MapsStore } from "../../stores/maps";
  import { AreasStore } from "../../stores/areas";
  const { mapsMap } = MapsStore;
  const { areasMap } = AreasStore;
  import { WorldBuilderStore } from "./state";
  import LinkList from "./LinkList.svelte";
  const {
    areaSelected,
    selectedArea,
    incomingLinksForSelectedArea,
    outgoingLinksForSelectedArea,
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
      <div class="bg-gray-800 text-white rounded-l flex flex-col">
        <h2 class="text-center border-b-2 border-black flex-shrink">
          Incoming Links
        </h2>
        <div class="flex-1">
          <LinkList
            mapsMap={$mapsMap}
            links={$incomingLinksForSelectedArea}
            areasMap={$areasMap}
            showExit={false} />
        </div>
      </div>
      <div
        class="bg-gray-800 text-white border-l-2 rounded-r border-black flex flex-col">
        <h2 class="text-center border-b-2 border-black flex-shrink">
          Outgoing Links
        </h2>
        <div class="flex-1">
          <LinkList
            mapsMap={$mapsMap}
            links={$outgoingLinksForSelectedArea}
            areasMap={$areasMap}
            showArrival={false} />
        </div>
      </div>
    </div>
  </div>
{:else}
  <div class="h-full w-full flex flex-col place-content-center p-1">
    <p class="text-gray-300 text-center">Select an area to view its details</p>
  </div>
{/if}
