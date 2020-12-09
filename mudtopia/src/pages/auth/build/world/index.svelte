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
  import { AreasStore } from "../../../../stores/areas.ts";
  import { Circle2 } from "svelte-loading-spinners";
  const { deleteMap, loadingMaps, mapsMap } = MapsStore;
  const { areas } = AreasStore;
  import { WorldBuilderStore } from "./_components/state";
  const {
    loadingMapData,
    mapSelected,
    selectedMap,
    selectedArea,
    selectedLink,
    areaUnderConstruction,
    linkUnderConstruction,
    mode,
    view,
    linkPreviewAreaId,
    svgMapAllowInterMapAreaSelection,
    svgMapAllowIntraMapAreaSelection,
    linkEditorMapForOtherAreaId,
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
    $view = "edit";
  }

  function del(map) {
    deleteMap(map).then(function () {
      $selectedMap = { ...mapState };
      $view = "details";
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
    $view = "details";
  }

  function mapSaved(event) {
    $selectedMap = event.detail;
    $view = "details";
  }

  // Area stuff

  let areaView = "details";

  function handleEditArea(event) {
    $areaUnderConstruction = { ...event.detail };
    $view = "edit";
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
        <SvgMap
          chosenMap={$selectedMap}
          mapSelected={$mapSelected}
          loadingMapData={$loadingMapData}
          selectedArea={$selectedArea}
          areas={$areas}
          areaUnderConstruction={$areaUnderConstruction}
          linkPreviewAreaId={$linkPreviewAreaId}
          linkUnderConstruction={$linkUnderConstruction}
          mapsMap={$mapsMap}
          svgMapAllowInterMapAreaSelection={$svgMapAllowInterMapAreaSelection}
          svgMapAllowIntraMapAreaSelection={$svgMapAllowIntraMapAreaSelection} />
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
        <div class="h-full w-full flex flex-col">
          {#if $selectedMap.id != $linkEditorMapForOtherAreaId}
            <div class="flex-1 overflow-hidden">
              <SvgMap
                chosenMap={$selectedMap}
                mapSelected={$mapSelected}
                loadingMapData={$loadingMapData}
                selectedArea={$selectedArea}
                areas={$areas}
                areaUnderConstruction={$areaUnderConstruction}
                linkPreviewAreaId={$linkPreviewAreaId}
                linkUnderConstruction={$linkUnderConstruction}
                mapsMap={$mapsMap}
                svgMapAllowInterMapAreaSelection={$svgMapAllowInterMapAreaSelection}
                svgMapAllowIntraMapAreaSelection={$svgMapAllowIntraMapAreaSelection} />
            </div>
          {:else}
            <div class="flex-1">foo</div>
          {/if}
          <div class="flex-1">
            <LinkEditor />
          </div>
        </div>
      {/if}
    </div>
    <ConfirmWithInput
      show={showDeletePrompt}
      callback={deleteCallback}
      matchString={deleteMatchString} />
  {/if}
</div>
