<script language="typescript">
  import ConfirmWithInput from "../../../../components/ConfirmWithInput.svelte";
  import AreaEditor from "./_components/AreaEditor.svelte";
  import MapEditor from "./_components/MapEditor.svelte";
  import LinkEditor from "./_components/LinkEditor.svelte";
  import MapDetails from "./_components/MapDetails.svelte";
  import AreaDetails from "./_components/AreaDetails.svelte";
  import MapList from "./_components/MapList.svelte";
  import AreaList from "./_components/AreaList.svelte";
  import SvgMap from "./_components/SvgMap.svelte";
  import { onMount } from "svelte";
  import { MapsStore } from "../../../../stores/maps.ts";
  import { Circle2 } from "svelte-loading-spinners";
  const { deleteMap, loadingMaps, mapsMap } = MapsStore;
  import { WorldBuilderStore } from "./_components/state";
  const {
    selectedMap,
    selectedArea,
    selectedLink,
    areaUnderConstruction,
    linkUnderConstruction,
    mode,
    view,
  } = WorldBuilderStore;
  import mapState from "../../../../models/map.ts";
  import areaState from "../../../../models/area.ts";
  import linkState from "../../../../models/link.ts";

  let showDeletePrompt = false;
  let deleteCallback;
  let deleteMatchString = "";

  onMount(async () => {
    MapsStore.load();
  });

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

  function mapSaved(event) {
    $selectedMap = event.detail;
    mapView = "details";
  }

  // Area stuff

  let areaView = "details";

  function handleEditArea(event) {
    $areaUnderConstruction = { ...event.detail };
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

  function delArea(event) {
    deleteArea(event.detail).then(function () {
      $selectedArea = { ...areaState };
      areaView = "details";
    });
  }

  function cancelEditArea(event) {
    $areaUnderConstruction = { ...areaState };
    areaView = "details";
  }

  function areaSaved(event) {
    $areaUnderConstruction = { ...areaState };
    $selectedArea = event.detail;
    areaView = "details";
  }

  selectedArea.subscribe((newArea) => {
    if (newArea.mapId != $selectedMap.id) {
      $selectedMap = $mapsMap[newArea.mapId];
      view = "map";
      mapView = "details";
      areaView = "details";
      linkView = "details";
      $areaUnderConstruction = { ...areaState };
      $linkUnderConstruction = { ...linkState };
      mapUnderConstruction = { ...mapState };
    }
  });

  function handleListSelectArea(event) {
    if (areaView == "details") {
      $selectedArea = event.detail;
    }
  }

  // Link stuff

  function handleLinkArea(event) {
    $linkUnderConstruction = { ...linkState };
    areaView = "link";
  }

  function handleDeleteLink(event) {
    deleteCallback = function () {
      delArea(event.detail);
    };
    deleteMatchString = event.detail.name;
    showDeletePrompt = false;
    showDeletePrompt = true;
  }

  function delLink(area) {
    deleteArea(area).then(function () {
      $selectedArea = { ...areaState };
      areaView = "details";
    });
  }

  function linkSaved(event) {
    $linkUnderConstruction = { ...linkState };
    $selectedLink = event.detail;
    areaView = "details";
  }

  function cancelEditLink(event) {
    $areaUnderConstruction = { ...areaState };
    areaView = "details";
  }

  // Map stuff
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
        <SvgMap />
      </div>
      <div class="h-1/2 max-h-1/2 w-full overflow-y-auto">
        {#if $mode == 'map'}
          <MapList />
        {:else}
          <AreaList />
        {/if}
      </div>
    </div>
    <div class="flex-1">
      {#if $mode == 'map'}
        {#if $view == 'details'}
          <MapDetails />
        {:else}
          <MapEditor />
        {/if}
      {:else if $mode == 'area'}
        {#if $view == 'details'}
          <AreaDetails />
        {:else}
          <AreaEditor />
        {/if}
      {:else}
        <LinkEditor />
      {/if}
    </div>
    <ConfirmWithInput
      show={showDeletePrompt}
      callback={deleteCallback}
      matchString={deleteMatchString} />
  {/if}
</div>
