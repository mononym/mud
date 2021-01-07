<script language="typescript">
  import ConfirmWithInput from "../components/ConfirmWithInput.svelte";
  import AreaEditor from "../components/builder/AreaEditor.svelte";
  import MapEditor from "../components/builder/MapEditor.svelte";
  import MapLabelEditor from "../components/builder/MapLabelEditor.svelte";
  import LinkEditor from "../components/builder/LinkEditor.svelte";
  import MapDetails from "../components/builder/MapDetails.svelte";
  import AreaDetails from "../components/builder/AreaDetails.svelte";
  import MapList from "../components/builder/MapList.svelte";
  import AreaList from "../components/builder/AreaList.svelte";
  import BuilderSvgMap from "../components/builder/BuilderSvgMap.svelte";
  import { onMount } from "svelte";
  import { MapsStore } from "../stores/maps.ts";
  import { AreasStore } from "../stores/areas.ts";
  import { LinksStore } from "../stores/links.ts";
  import { Circle2 } from "svelte-loading-spinners";
  const { loadingMaps, mapsMap } = MapsStore;
  const { areas, areasMap } = AreasStore;
  const { links } = LinksStore;
  import { WorldBuilderStore } from "../components/builder/state";
  const {
    buildingArea,
    buildingLink,
    selectedMap,
    selectedArea,
    areaSelected,
    selectedLink,
    linkSelected,
    areaUnderConstruction,
    linkUnderConstruction,
    mode,
    view,
    svgMapAllowInterMapAreaSelection,
    svgMapAllowIntraMapAreaSelection,
    linkEditorMapForOtherAreaId,
    areasForLinkEditorMap,
    areasForLinkEditor,
    linksForLinkEditor,
    mapLabelUnderConstruction,
    createNewMap,
  } = WorldBuilderStore;
  import areaState from "../models/area.ts";
  import linkState from "../models/link.ts";

  let showDeletePrompt = false;
  let deleteCallback;
  let deleteMatchString = "";
  $: backToMapViewButtonDisabled = !($view == "details" && $mode == "area");
  $: createNewAreaButtonDisabled = !($view == "details" && $mode == "area");
  $: newMapButtonDisabled = !($view == "details" && $mode == "map");

  let primaryMap;

  onMount(async () => {
    MapsStore.load();
  });

  function getSlots() {
    return this;
  }

  // Map stuff

  function backToMapView() {
    if (!backToMapViewButtonDisabled) {
      $view = "details";
      $mode = "map";
      $selectedArea = { ...areaState };
      $selectedLink = { ...linkState };
    }
  }

  // Area stuff

  function createArea() {
    WorldBuilderStore.createArea();
  }

  // Map stuff
</script>

<div class="inline-flex flex-grow overflow-hidden">
  <slot />
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
          focusAreaId={$selectedArea.id}
          areaUnderConstruction={$areaUnderConstruction}
          buildingArea={$buildingArea}
          buildingLink={$buildingLink}
          areasMapForOtherMap={$areasForLinkEditorMap}
          mapLabelUnderConstruction={$mapLabelUnderConstruction} />
      </div>
      <div class="h-1/2 max-h-1/2 w-full overflow-hidden flex flex-col">
        {#if $mode == 'map'}
          <MapList />

          <div class="flex-shrink flex">
            <button
              on:click={createNewMap}
              disabled={newMapButtonDisabled}
              type="button"
              class="flex-1 rounded-l-md {newMapButtonDisabled ? 'text-gray-600 bg-gray-500' : 'bg-gray-300 text-black hover:text-gray-500 hover:bg-gray-400'} p-2 focus:outline-none {newMapButtonDisabled ? 'cursor-not-allowed' : 'cursor-pointer'}">New
              Map</button>
          </div>
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
        {:else if $view == 'edit'}
          <MapEditor />
        {:else if $view == 'label'}
          <MapLabelEditor />
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
              <BuilderSvgMap
                chosenMap={$mapsMap[$linkEditorMapForOtherAreaId]}
                mapsMap={$mapsMap}
                areasMap={$areasForLinkEditorMap}
                links={$linksForLinkEditor}
                areas={$areasForLinkEditor}
                linkUnderConstruction={$linkUnderConstruction}
                svgMapAllowInterMapAreaSelection={true}
                svgMapAllowIntraMapAreaSelection={true}
                highlightedAreaIds={$areaSelected ? [$selectedArea.id] : []}
                highlightedLinkIds={$linkSelected ? [$selectedLink.id] : []}
                focusAreaId={$linkUnderConstruction.toId == $selectedArea.id ? $linkUnderConstruction.fromId : $linkUnderConstruction.toId}
                areaUnderConstruction={$areaUnderConstruction}
                buildingArea={false}
                buildingLink={$buildingLink}
                areasMapForOtherMap={$areasMap} />
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
