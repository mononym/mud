<script>
  import MapList from "./_components/MapList.svelte";
  import SvgMap from "./_components/SvgMap.svelte";
  import { onMount } from "svelte";
  import { MapsStore } from "../../../../stores/maps";
  import { Circle2 } from "svelte-loading-spinners";
  const { isLoading } = MapsStore;
  import { WorldBuilderStore } from "./_components/state";
  const { mapSelected } = WorldBuilderStore;

  onMount(async () => {
    MapsStore.load();
  });
</script>

<div class="inline-flex flex-grow overflow-hidden">
  <div class="h-full max-h-full w-1/2">
    <div class="h-1/2 max-h-1/2 w-full">
      <SvgMap/>
    </div>
    <div class="h-1/2 max-h-1/2 w-full">
      {#if $isLoading}
        <div class="fit flex flex-col items-center justify-center">
          <Circle2 />
          <h2 class="mt-6 text-center text-3xl font-extrabold text-gray-500">
            Loading maps
          </h2>
        </div>
      {:else}
        <MapList/>
      {/if}
    </div>
  </div>
  <div class="flex-1">details</div>
</div>
