<script language="typescript">
  import ConfirmWithInput from "../../../../components/ConfirmWithInput.svelte";
  import MapEditor from "./_components/MapEditor.svelte";
  import MapDetails from "./_components/MapDetails.svelte";
  import MapList from "./_components/MapList.svelte";
  import SvgMap from "./_components/SvgMap.svelte";
  import { onMount } from "svelte";
  import { MapsStore } from "../../../../stores/maps.ts";
  import { Circle2 } from "svelte-loading-spinners";
  const { deleteMap, loadingMaps } = MapsStore;
  import { WorldBuilderStore } from "./_components/state";
  const { mapSelected, selectedMap } = WorldBuilderStore;
  import mapState from "../../../../models/map.ts";

  let view = "map";
  let mapView = "details";
  let areaView = "details";
  let mapUnderConstruction = { ...mapState };
  let showDeletePrompt = false;
  let deleteCallback;
  let deleteMatchString = "";
  let mapReadOnly = true;

  onMount(async () => {
    MapsStore.load();
  });

  function mapSaved(event) {
    // mapUnderConstruction = { ...mapState };
    $selectedMap = event.detail;
    mapView = "details";
  }

  function buildMap(map) {
    view = "area";
  }

  function editMap(event) {
    mapUnderConstruction = { ...event.detail };
    mapView = "editor";
  }

  function del(map) {
    deleteMap(map).then(function () {
      $selectedMap = { ...mapState };
      mapView = "details";
    });
  }

  function handleDeleteMap(event) {
    deleteCallback = function () {
      del(event.detail);
    };
    deleteMatchString = event.detail.name;
    showDeletePrompt = false;
    showDeletePrompt = true;
  }

  function cancelEditMap(map) {
    mapUnderConstruction = { ...mapState };
    mapView = "details";
  }
</script>

<div class="inline-flex flex-grow overflow-hidden">
  <div class="h-full max-h-full w-1/2">
    <div class="h-1/2 max-h-1/2 w-full">
      <SvgMap readOnly={mapReadOnly} />
    </div>
    <div class="h-1/2 max-h-1/2 w-full">
      {#if view == 'map'}
        {#if $loadingMaps}
          <div class="fit flex flex-col items-center justify-center">
            <Circle2 />
            <h2 class="mt-6 text-center text-3xl font-extrabold text-gray-500">
              Loading maps
            </h2>
          </div>
        {:else}
          <MapList on:editMap={editMap} on:deleteMap={handleDeleteMap} />
        {/if}
      {:else}
        <p>area list</p>
      {/if}
    </div>
  </div>
  <div class="flex-1">
    {#if view == 'map'}
      {#if mapView == 'details'}
        <MapDetails />
      {:else}
        <MapEditor
          map={mapUnderConstruction}
          on:save={mapSaved}
          on:cancel={cancelEditMap} />
      {/if}
    {:else if view == 'area'}
      {#if areaView == 'details'}
        <p>details</p>
      {:else}
        <p>editor</p>
      {/if}
    {/if}
  </div>
  <ConfirmWithInput
    show={showDeletePrompt}
    callback={deleteCallback}
    matchString={deleteMatchString} />
</div>
