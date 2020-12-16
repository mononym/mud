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
  import BuilderSvgMap from "./_components/BuilderSvgMap.svelte";
  import { onMount } from "svelte";
  import { MapsStore } from "../../../../stores/maps.ts";
  import { AreasStore } from "../../../../stores/areas.ts";
  import { LinksStore } from "../../../../stores/links.ts";
  import { Circle2 } from "svelte-loading-spinners";
  const { deleteMap, loadingMaps, mapsMap } = MapsStore;
  const { areas, areasMap } = AreasStore;
  const { links } = LinksStore;
  import { WorldBuilderStore } from "./_components/state";
  const {
    buildingArea,
    loadingMapData,
    mapSelected,
    selectedMap,
    selectedArea,
    areaSelected,
    selectedLink,
    linkSelected,
    areaUnderConstruction,
    linkUnderConstruction,
    mode,
    view,
    linkPreviewAreaId,
    svgMapAllowInterMapAreaSelection,
    svgMapAllowIntraMapAreaSelection,
    linkEditorMapForOtherAreaId,
    areasForLinkEditorMap,
    areasForLinkEditor,
    linksForLinkEditor,
    loadingLinkEditorData,
  } = WorldBuilderStore;
  import mapState from "../../../../models/map.ts";
  import areaState from "../../../../models/area.ts";
  import linkState from "../../../../models/link.ts";
  import { get } from "svelte/store";

  let showDeletePrompt = false;
  let deleteCallback;
  let deleteMatchString = "";
  $: backToMapViewButtonDisabled = !($view == "details" && $mode == "area");
  $: createNewAreaButtonDisabled = !($view == "details" && $mode == "area");

  let primaryMap;

  onMount(async () => {
    MapsStore.load();
  });

  // Map stuff

  function backToMapView() {
    if (!backToMapViewButtonDisabled) {
      $view = "details";
      $mode = "map";
      $selectedArea = { ...areaState };
      $selectedLink = { ...linkState };
    }
  }

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

  function createArea() {
    WorldBuilderStore.createArea();
  }

  function delArea(event) {
    deleteArea(event.detail).then(function () {
      $selectedArea = { ...areaState };
      areaView = "details";
    });
  }

  // Link stuff

  function handlePrimaryMapSelectArea(event) {
    WorldBuilderStore.selectArea(event.detail);
  }

  function handleSecondaryMapSelectArea(event) {
    // if something is selected on the secondary map it is done while something is being linked
    // if the area being selected on the map is not the area being lined, set that as the other area
    // if the area belongs to another map, change the map for the link area
    // $linkUnderConstruction.toId == $selectedArea.id ? $areasForLinkEditorMap[$linkUnderConstruction.fromId] : $areasForLinkEditorMap[$linkUnderConstruction.toId]

    const area = event.detail;
    if (area.mapId == linkEditorMapForOtherAreaId) {
      if (get(linkUnderConstruction).toId == get(selectedArea).id) {
        linkUnderConstruction.update(function (link) {
          link.fromId = area.id;
          return link;
        });
      } else if (get(linkUnderConstruction).fromId == get(selectedArea).id) {
        linkUnderConstruction.update(function (link) {
          link.toId = area.id;
          return link;
        });
      }
    }
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
        <!-- <SvgMap
          on:selectArea={handlePrimaryMapSelectArea}
          chosenMap={$selectedMap}
          mapSelected={$mapSelected}
          loadingMapData={$loadingMapData}
          selectedArea={$selectedArea}
          selectedLink={$selectedLink}
          areas={$areas}
          areaUnderConstruction={$areaUnderConstruction}
          linkPreviewAreaId={$linkPreviewAreaId}
          linkUnderConstruction={$linkUnderConstruction}
          mapsMap={$mapsMap}
          svgMapAllowInterMapAreaSelection={$svgMapAllowInterMapAreaSelection}
          svgMapAllowIntraMapAreaSelection={$svgMapAllowIntraMapAreaSelection}
          areasMap={$areasMap}
          links={$links}
          focusAreaId={$selectedArea.id}
          buildingArea={$buildingArea} /> -->
        <BuilderSvgMap
          bind:this={primaryMap}
          chosenMap={$selectedMap}
          mapsMap={$mapsMap}
          areasMap={$areasMap}
          links={$links}
          areas={$areas}
          linkUnderConstruction={$linkUnderConstruction}
          svgMapAllowInterMapAreaSelection={$svgMapAllowInterMapAreaSelection}
          svgMapAllowIntraMapAreaSelection={$svgMapAllowIntraMapAreaSelection}
          highlightedAreaIds={$areaSelected ? [$selectedArea.id] : []}
          highlightedLinkIds={$linkSelected ? [$selectedLink.id] : []}
          focusAreaId={$selectedArea.id} />
      </div>
      <div class="h-1/2 max-h-1/2 w-full overflow-hidden flex flex-col">
        {#if $mode == 'map'}
          <MapList />
        {:else}
          <AreaList />

          <div class="flex-shrink flex">
            <button
              on:click={backToMapView}
              disabled={backToMapViewButtonDisabled}
              type="button"
              class="flex-1 rounded-l-md {backToMapViewButtonDisabled ? 'text-gray-600 bg-gray-500' : 'bg-gray-300 text-black hover:text-gray-500 hover:bg-gray-400'} p-2 focus:outline-none {backToMapViewButtonDisabled ? 'cursor-not-allowed' : 'cursor-pointer'}">Back
              to Map List</button>
            <button
              on:click={createArea}
              disabled={createNewAreaButtonDisabled}
              type="button"
              class="flex-1 rounded-r-md {createNewAreaButtonDisabled ? 'text-gray-600 bg-gray-500' : 'bg-gray-300 text-black hover:text-gray-500 hover:bg-gray-400'} p-2 focus:outline-none {createNewAreaButtonDisabled ? 'cursor-not-allowed' : 'cursor-pointer'}">Create
              New Area</button>
          </div>
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
          {#if $selectedMap.id != $linkEditorMapForOtherAreaId && $linkEditorMapForOtherAreaId != ''}
            <div class="flex-1 overflow-hidden">
              <SvgMap
                on:selectArea={handleSecondaryMapSelectArea}
                chosenMap={$mapsMap[$linkEditorMapForOtherAreaId]}
                mapSelected={true}
                loadingMapData={$loadingLinkEditorData}
                selectedArea={$selectedArea}
                areas={$areasForLinkEditor}
                areaUnderConstruction={$areaUnderConstruction}
                linkPreviewAreaId={$linkUnderConstruction.toId == $selectedArea.id ? $linkUnderConstruction.fromId : $linkUnderConstruction.toId}
                linkUnderConstruction={$linkUnderConstruction}
                mapsMap={$mapsMap}
                svgMapAllowInterMapAreaSelection={true}
                svgMapAllowIntraMapAreaSelection={true}
                areasMap={$areasForLinkEditorMap}
                links={$linksForLinkEditor}
                focusAreaId={$linkUnderConstruction.toId == $selectedArea.id ? $linkUnderConstruction.fromId : $linkUnderConstruction.toId}
                buildingArea={$buildingArea} />
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
