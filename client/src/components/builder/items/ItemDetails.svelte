<script>
  import { WorldBuilderStore } from "../state";
  const { itemSelected, selectedItem } = WorldBuilderStore;
</script>

{#if $itemSelected}
  <div class="h-full w-full flex flex-col p-1 place-content-center">
    <h2 class="text-center text-gray-300">{$selectedItem.description.short}</h2>
    <p class="text-center text-gray-300">{$selectedItem.description.long}</p>
  </div>
{:else}
  <div class="h-full w-full flex flex-col place-content-center p-1">
    <p class="text-gray-300 text-center">Select a Item to view its details</p>
  </div>
{/if}
