<script>
  import { MapsStore } from "../../../../../stores/maps";
  const { maps } = MapsStore;
  import { WorldBuilderStore } from "./state";
  const { areaSelected, selectedArea } = WorldBuilderStore;
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
  </div>
{:else}
  <div class="h-full w-full flex flex-col place-content-center p-1">
    <p class="text-gray-300 text-center">Select an area to view its details</p>
  </div>
{/if}
