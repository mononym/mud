<script language="typescript">
  import Confirm from "../Confirm.svelte";
  import AreaEditor from "./AreaEditor.svelte";
  import MapEditor from "./MapEditor.svelte";
  import ItemEditor from "./items/ItemEditor.svelte";
  import MapLabelEditor from "./MapLabelEditor.svelte";
  import LinkEditor from "./LinkEditor.svelte";
  import MapDetails from "./MapDetails.svelte";
  import AreaDetails from "./AreaDetails.svelte";
  import MapList from "./MapList.svelte";
  import AreaList from "./AreaList.svelte";
  import BuilderSvgMap from "./BuilderSvgMap.svelte";
  import { onMount } from "svelte";
  import { MapsStore } from "../../stores/maps.ts";
  import { AreasStore } from "../../stores/areas.ts";
  import AreaState from "../../models/area.ts";
  import { LinksStore } from "../../stores/links.ts";
  import { Circle2 } from "svelte-loading-spinners";
  import { WorldBuilderStore } from "./state";
  const { loadingMaps, mapsMap } = MapsStore;
  const { areas, areasMap } = AreasStore;
  const { links } = LinksStore;
  const {
    buildingArea,
    buildingLink,
    selectedMap,
    mapSelected,
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
    mapZoomMultiplierIndex,
    mapZoomMultipliers,
    zoomMapIn,
    zoomMapOut,
    mapAtMaxZoom,
    mapAtMinZoom,
    loadShops,
    saveItemUnderConstructionAsAreaItem,
    areaIsUnderConstruction,
    itemsForSelectedAreaMap,
    mapFocusPoints,
    viewingAreaDetails,
  } = WorldBuilderStore;
  import areaState from "../../models/area.ts";
  import linkState from "../../models/link.ts";

  let showDeletePrompt = false;
  let deleteCallback;
  $: backToMapViewButtonDisabled = !($view == "details" && $mode == "area");
  $: createNewAreaButtonDisabled = !($view == "details" && $mode == "area");
  $: newMapButtonDisabled = !($view == "details" && $mode == "map");

  let primaryMap;

  onMount(async () => {
    loadShops();
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

  function handleMouseWheelScrollOverMap(event) {
    if (event.deltaY < 0) {
      zoomMapIn();
    } else {
      zoomMapOut();
    }
  }

  // Area stuff

  function createArea() {
    WorldBuilderStore.createArea();
  }

  // Map stuff
</script>

<div class="h-full w-full overflow-hidden flex flex-col">
  {#if $loadingMaps}
    <div class="flex-1 flex flex-col justify-center items-center">
      <Circle2 />
      <h2 class="mt-6 text-center text-3xl font-extrabold text-gray-500">
        Loading maps
      </h2>
    </div>
  {:else}
    <div class="h-full flex flex-1">
      <div class="h-full max-h-full flex-1">
        <div
          on:mousewheel={handleMouseWheelScrollOverMap}
          class="h-1/2 max-h-1/2 w-full"
        >
          <div style="height:calc(100% - 40px)" class="w-full">
            <BuilderSvgMap
              bind:this={primaryMap}
              chosenMap={$selectedMap}
              mapsMap={$mapsMap}
              areasMap={$areasMap}
              links={$links}
              areas={$areas}
              allowDragArea={$viewingAreaDetails || $areaIsUnderConstruction}
              linkUnderConstruction={$linkUnderConstruction}
              svgMapAllowInterMapAreaSelection={$svgMapAllowInterMapAreaSelection}
              svgMapAllowIntraMapAreaSelection={$svgMapAllowIntraMapAreaSelection}
              highlightedAreaIds={$areaSelected ? [$selectedArea.id] : []}
              highlightedLinkIds={$linkSelected ? [$selectedLink.id] : []}
              mapFocusPoints={$mapFocusPoints}
              mapFocusPointsX={$mapFocusPoints.x}
              mapFocusPointsY={$mapFocusPoints.y}
              areaUnderConstruction={$areaUnderConstruction}
              buildingArea={$buildingArea}
              buildingLink={$buildingLink}
              areasMapForOtherMap={$areasForLinkEditorMap}
              mapLabelUnderConstruction={$mapLabelUnderConstruction}
              zoomMultiplier={$mapZoomMultipliers[$mapZoomMultiplierIndex]}
            />
          </div>
          <div class="flex" style="height:40px">
            {#if $mapSelected}
              <button
                on:click={zoomMapIn}
                disabled={$mapAtMinZoom}
                type="button"
                class="flex-1 {$mapAtMinZoom
                  ? 'text-gray-600 bg-gray-500'
                  : 'bg-gray-300 text-black hover:text-gray-500 hover:bg-gray-400'} p-2 focus:outline-none {$mapAtMinZoom
                  ? 'cursor-not-allowed'
                  : 'cursor-pointer'}"><i class="fas fa-plus" /></button
              >
              <button
                on:click={zoomMapOut}
                disabled={$mapAtMaxZoom}
                type="button"
                class="flex-1 {$mapAtMaxZoom
                  ? 'text-gray-600 bg-gray-500'
                  : 'bg-gray-300 text-black hover:text-gray-500 hover:bg-gray-400'} p-2 focus:outline-none {$mapAtMaxZoom
                  ? 'cursor-not-allowed'
                  : 'cursor-pointer'}"><i class="fas fa-minus" /></button
              >
            {/if}
          </div>
        </div>
        <div class="h-1/2 max-h-1/2 w-full overflow-hidden flex flex-col">
          {#if $mode == "map"}
            <MapList />

            <div class="flex-shrink flex">
              <button
                on:click={createNewMap}
                disabled={newMapButtonDisabled}
                type="button"
                class="flex-1 rounded-l-md {newMapButtonDisabled
                  ? 'text-gray-600 bg-gray-500'
                  : 'bg-gray-300 text-black hover:text-gray-500 hover:bg-gray-400'} p-2 focus:outline-none {newMapButtonDisabled
                  ? 'cursor-not-allowed'
                  : 'cursor-pointer'}">New Map</button
              >
            </div>
          {:else}
            <AreaList />

            <div class="flex-shrink flex">
              <button
                on:click={backToMapView}
                disabled={backToMapViewButtonDisabled}
                type="button"
                class="flex-1 rounded-l-md {backToMapViewButtonDisabled
                  ? 'text-gray-600 bg-gray-500'
                  : 'bg-gray-300 text-black hover:text-gray-500 hover:bg-gray-400'} p-2 focus:outline-none {backToMapViewButtonDisabled
                  ? 'cursor-not-allowed'
                  : 'cursor-pointer'}">Back to Map List</button
              >
              <button
                on:click={createArea}
                disabled={createNewAreaButtonDisabled}
                type="button"
                class="flex-1 rounded-r-md {createNewAreaButtonDisabled
                  ? 'text-gray-600 bg-gray-500'
                  : 'bg-gray-300 text-black hover:text-gray-500 hover:bg-gray-400'} p-2 focus:outline-none {createNewAreaButtonDisabled
                  ? 'cursor-not-allowed'
                  : 'cursor-pointer'}">Create New Area</button
              >
            </div>
          {/if}
        </div>
      </div>
      <div class="h-full max-h-full flex-1">
        {#if $mode == "map"}
          {#if $view == "details"}
            <MapDetails />
          {:else if $view == "edit"}
            <MapEditor />
          {:else if $view == "label"}
            <MapLabelEditor />
          {/if}
        {:else if $mode == "area"}
          {#if $view == "details"}
            <AreaDetails />
          {:else if $view == "edit"}
            <AreaEditor />
          {:else if $view == "edit_item"}
            <ItemEditor
              saveItemCallback={saveItemUnderConstructionAsAreaItem}
              allowRelativePlacement={true}
              otherItemsForRelativePlacement={$itemsForSelectedAreaMap}
            />
          {/if}
        {:else}
          <div class="h-full w-full flex flex-col">
            {#if $selectedMap.id != $linkEditorMapForOtherAreaId && $linkEditorMapForOtherAreaId != ""}
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
                  focusArea={$linkUnderConstruction.toId == $selectedArea.id
                    ? $areasMap[$linkUnderConstruction.fromId]
                    : $areasMap[$linkUnderConstruction.toId]}
                  focusOnArea={true}
                  zoomMultiplier={$mapZoomMultipliers[$mapZoomMultiplierIndex]}
                  areaUnderConstruction={$areaUnderConstruction}
                  buildingArea={false}
                  buildingLink={$buildingLink}
                  areasMapForOtherMap={$areasMap}
                />
              </div>
            {:else}
              <div class="flex-1" />
            {/if}
            <div class="flex-1">
              <LinkEditor />
            </div>
          </div>
        {/if}
      </div>
      <Confirm show={showDeletePrompt} callback={deleteCallback} />
    </div>
  {/if}
</div>
