<script>
  import { MapsStore } from "../../../../../stores/maps";
  const { maps } = MapsStore;
  import { WorldBuilderStore } from "./state";
  const { mapSelected, selectedMap } = WorldBuilderStore;
</script>

{#if $mapSelected}
  <div class="h-full w-full flex flex-col p-1 place-content-center">
    <h2 class="text-center text-gray-300">{$selectedMap.name}</h2>
    <p class="text-center text-gray-300">{$selectedMap.description}</p>
    <p class="text-center text-gray-300">Grid Size: {$selectedMap.gridSize}</p>
    <p class="text-center text-gray-300">View Size: {$selectedMap.viewSize}</p>
  </div>
{:else}
  <div class="h-full w-full flex flex-col place-content-center p-1">
    <p class="text-gray-300 text-center">Select a map to view its details</p>
  </div>
{/if}
