<script lang="ts">
  import { Circle2 } from "svelte-loading-spinners";
  import Svg from "../../../../../components/Svg.svelte";
  import type { AreaInterface } from "../../../../../models/area";
  import type { LinkInterface } from "../../../../../models/link";
  import { AreasStore } from "../../../../../stores/areas";
  import { LinksStore } from "../../../../../stores/links";
  const { links } = LinksStore;
  const { areas, areasMap } = AreasStore;
  import { WorldBuilderStore } from "./state";
  const {
    mapSelected,
    selectedMap,
    loadAllMapData,
    loadingMapData,
    selectedArea,
    areaUnderConstruction,
  } = WorldBuilderStore;

  export let readOnly = true;

  // Stuff to draw
  $: if ($mapSelected) {
    loadAllMapData($selectedMap.id);
  }

  // Zoom stuff
  let zoomMultipliers = [0.00775, 0.015, 0.03, 0.06, 0.125, 0.25, 0.5];
  let zoomMultierIndex = 3;
  $: zoomOutButtonDisabled = zoomMultierIndex == zoomMultipliers.length - 1;
  $: zoomInButtonDisabled = zoomMultierIndex == 0;

  // Aspect ratio
  let svgWrapperWidth = 16;
  let svgWrapperHeight = 9;

  // Viewbox sizing
  let xCenterPoint = 0;
  let yCenterPoint = 0;
  let viewBoxX = 0;
  let viewBoxY = 0;
  let viewBoxXSize = 0;
  let viewBoxYSize = 0;
  let viewBox = "";

  let chosenMap;

  selectedMap.subscribe((newMap) => {
    chosenMap = newMap;
    xCenterPoint = chosenMap.viewSize / 2;
    yCenterPoint = chosenMap.viewSize / 2;
    calculateViewBox();
  });

  function calculateViewBox() {
    viewBoxXSize = chosenMap.viewSize * zoomMultipliers[zoomMultierIndex];
    viewBoxYSize =
      chosenMap.viewSize *
      (svgWrapperWidth / (svgWrapperHeight - 64)) *
      zoomMultipliers[zoomMultierIndex];
    viewBoxX = xCenterPoint - viewBoxXSize / 2;
    viewBoxY = yCenterPoint - viewBoxYSize / 2;
    viewBox =
      viewBoxX + " " + viewBoxY + " " + viewBoxXSize + " " + viewBoxYSize;
  }

  let svgAreaShapes = [];

  function buildSvgAreaShapes(areas: AreaInterface[]) {
    svgAreaShapes = areas
      .map(function (area: AreaInterface) {
        return buildSquare(
          area,
          $selectedMap.gridSize,
          $selectedMap.viewSize,
          $selectedArea.id == area.id ? "green" : "blue",
          area.mapX,
          area.mapY,
          area.mapSize,
          area.mapCorners,
          readOnly ? "cursor-auto" : "cursor-pointer"
        );
      })
      .sort(function (area1, area2) {
        if (area1.id == $areaUnderConstruction.id) {
          return 1;
        } else if (area2.id == $areaUnderConstruction.id) {
          return -1;
        } else {
          area1 <= area2;
        }
      });
  }

  areas.subscribe((newAreas) => {
    buildSvgAreaShapes(newAreas);
  });

  selectedArea.subscribe(() => {
    buildSvgAreaShapes($areas);
  });

  let svglinkShapes = [];
  links.subscribe((newLinks) => {
    buildSvgLinkShapes(newLinks);
  });

  function buildSvgLinkShapes(links: LinkInterface[]) {
    svglinkShapes = links
      .filter(function (link: LinkInterface) {
        return (
          $areasMap[link.toId] != undefined &&
          $areasMap[link.fromId] != undefined
        );
      })
      .map(function (link: LinkInterface) {
        const toArea =
          link.toId == $areaUnderConstruction.id
            ? $areaUnderConstruction
            : $areasMap[link.toId];
        const fromArea =
          link.fromId == $areaUnderConstruction.id
            ? $areaUnderConstruction
            : $areasMap[link.fromId];
        const fromMapX = fromArea.mapX;
        const fromMapY = fromArea.mapY;
        const toMapX = toArea.mapX;
        const toMapY = toArea.mapY;
        const stroke = "white";
        const gridSize = $selectedMap.gridSize;
        const viewSize = $selectedMap.viewSize;

        return {
          id: link.id,
          type: "line",
          x1: fromMapX * gridSize + viewSize / 2,
          y1: -fromMapY * gridSize + viewSize / 2,
          x2: toMapX * gridSize + viewSize / 2,
          y2: -toMapY * gridSize + viewSize / 2,
          stroke: stroke,
          link: link,
        };
      });
  }

  areaUnderConstruction.subscribe((newArea) => {
    const mappedAreas = $areas.map((area) =>
      area.id == newArea.id ? newArea : area
    );
    buildSvgAreaShapes(mappedAreas);
    buildSvgLinkShapes($links);
  });

  function buildSquare(
    area: AreaInterface,
    gridSize: number,
    viewSize: number,
    fill: string,
    x: number,
    y: number,
    size: number,
    corners: number,
    cls: string
  ): Record<string, unknown> {
    return {
      id: area.id,
      type: "rect",
      x: x * gridSize + viewSize / 2 - size / 2,
      y: -y * gridSize + viewSize / 2 - size / 2,
      width: size,
      height: size,
      corners: corners,
      fill: fill,
      name: area.name,
      area: area,
      cls: cls,
    };
  }

  function zoomIn() {
    zoomMultierIndex = --zoomMultierIndex;
    calculateViewBox();
  }

  function zoomOut() {
    zoomMultierIndex = ++zoomMultierIndex;
    calculateViewBox();
  }

  function handleSelectArea(event) {
    $selectedArea = event.detail;
  }
</script>

<div
  bind:clientWidth={svgWrapperWidth}
  bind:clientHeight={svgWrapperHeight}
  class="p-1 h-full w-full max-w-full max-h-full flex flex-col {$mapSelected ? '' : 'place-content-center'}">
  {#if $mapSelected}
    {#if $loadingMapData}
      <div class="flex-1 flex flex-col items-center justify-center">
        <Circle2 />
        <h2 class="mt-6 text-center text-3xl font-extrabold text-gray-500">
          Loading map data
        </h2>
      </div>
    {:else}
      <p class="flex-shrink text-gray-300 w-full text-center">
        {$selectedMap.name}
      </p>
      <div class="flex-1 overflow-hidden">
        <Svg
          {viewBox}
          shapes={[...svglinkShapes, ...svgAreaShapes]}
          on:selectArea={handleSelectArea} />
      </div>
      <div class="flex">
        <button
          on:click={zoomIn}
          disabled={zoomInButtonDisabled}
          type="button"
          class="flex-1 rounded-l-md {zoomInButtonDisabled ? 'text-gray-600 bg-gray-500' : 'bg-gray-300 text-black hover:text-gray-500 hover:bg-gray-400'} p-2 focus:outline-none {zoomInButtonDisabled ? 'cursor-not-allowed' : 'cursor-pointer'}"><i
            class="fas fa-plus" /></button>
        <button
          on:click={zoomOut}
          disabled={zoomOutButtonDisabled}
          type="button"
          class="flex-1 rounded-r-md {zoomOutButtonDisabled ? 'text-gray-600 bg-gray-500' : 'bg-gray-300 text-black hover:text-gray-500 hover:bg-gray-400'} p-2 focus:outline-none {zoomOutButtonDisabled ? 'cursor-not-allowed' : 'cursor-pointer'}"><i
            class="fas fa-minus" /></button>
      </div>
    {/if}
  {:else}
    <p class="text-gray-300 text-center">Select a map</p>
  {/if}
</div>
