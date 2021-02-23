<script>
  import { WorldBuilderStore } from "../state";
  const {
    templateSelected,
    selectedTemplate,
  } = WorldBuilderStore;

</script>

{#if $templateSelected}
  <div class="h-full w-full flex flex-col p-1 place-content-center">
    <h2 class="text-center text-gray-300">{$selectedTemplate.name}</h2>
    <p class="text-center text-gray-300">{$selectedTemplate.description}</p>
  </div>
{:else}
  <div class="h-full w-full flex flex-col place-content-center p-1">
    <p class="text-gray-300 text-center">Select a Template to view its details</p>
  </div>
{/if}
