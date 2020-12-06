<script language="typescript">
  import ConfirmWithInput from "../../../../components/ConfirmWithInput.svelte";
  import MapEditor from "./_components/MapEditor.svelte";
  import MapDetails from "./_components/MapDetails.svelte";
  import AreaDetails from "./_components/AreaDetails.svelte";
  import MapList from "./_components/MapList.svelte";
  import AreaList from "./_components/AreaList.svelte";
  import SvgMap from "./_components/SvgMap.svelte";
  import { onMount } from "svelte";
  import { MapsStore } from "../../../../stores/maps.ts";
  import { Circle2 } from "svelte-loading-spinners";
  const { deleteMap, loadingMaps } = MapsStore;
  import { WorldBuilderStore } from "./_components/state";
  const { mapSelected, selectedMap, selectedArea } = WorldBuilderStore;
  import mapState from "../../../../models/map.ts";
  import areaState from "../../../../models/area.ts";

  let view = "map";
  let mapView = "details";
  let mapUnderConstruction = { ...mapState };
  let showDeletePrompt = false;
  let deleteCallback;
  let deleteMatchString = "";
  let mapReadOnly = true;

  onMount(async () => {
    MapsStore.load();
  });

  function mapSaved(event) {
    $selectedMap = event.detail;
    mapView = "details";
  }

  function handleBuildMap(event) {
    view = "area";
    mapReadOnly = false;
  }

  // Map stuff

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

  // Area stuff

  let areaView = "details";
  let areaUnderConstruction = { ...areaState };

  function handleEditArea(event) {
    areaUnderConstruction = { ...event.detail };
    areaView = "editor";
  }

  function handleDeleteArea(event) {
    deleteCallback = function () {
      delArea(event.detail);
    };
    deleteMatchString = event.detail.name;
    showDeletePrompt = false;
    showDeletePrompt = true;
  }

  function delArea(area) {
    deleteArea(area).then(function () {
      $selectedArea = { ...areaState };
      areaView = "details";
    });
  }
</script>

<div class="inline-flex flex-grow overflow-hidden">
  {#if $loadingMaps}
    <div class="flex-1 flex flex-col justify-center items-center">
      <Circle2 />
      <h2 class="mt-6 text-center text-3xl font-extrabold text-gray-500">
        Loading maps
      </h2>
    </div>
  {:else}
    <div class="h-full max-h-full w-1/2">
      <div class="h-1/2 max-h-1/2 w-full">
        <SvgMap readOnly={mapReadOnly} />
      </div>
      <div class="h-1/2 max-h-1/2 w-full overflow-y-auto">
        {#if view == 'map'}
          <MapList
            on:editMap={editMap}
            on:deleteMap={handleDeleteMap}
            on:buildMap={handleBuildMap} />
        {:else}
          <AreaList
            on:editArea={handleEditArea}
            on:deleteArea={handleDeleteArea} />
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
          <AreaDetails />
        {:else}
          <p>editor</p>
        {/if}
      {/if}
    </div>
    <ConfirmWithInput
      show={showDeletePrompt}
      callback={deleteCallback}
      matchString={deleteMatchString} />
  {/if}
</div>
