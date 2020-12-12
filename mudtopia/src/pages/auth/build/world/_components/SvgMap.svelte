<script lang="ts">
  import { Circle2 } from "svelte-loading-spinners";
  import Svg from "../../../../../components/Svg.svelte";
  import AreaState from "../../../../../models/area";
  import type { AreaInterface } from "../../../../../models/area";
  import LinkState from "../../../../../models/link";
  import type { LinkInterface } from "../../../../../models/link";
  import { createEventDispatcher } from "svelte";
  import { WorldBuilderStore } from "./state";

  const dispatch = createEventDispatcher();

  export let selectedLink = { ...LinkState };
  export let mapSelected = true;
  export let loadingMapData = false;
  export let selectedArea = { ...AreaState };
  export let areas = [];
  export let areaUnderConstruction = { ...AreaState };
  export let linkPreviewAreaId = "";
  export let linkUnderConstruction = { ...LinkState };
  export let mapsMap = {};
  export let svgMapAllowIntraMapAreaSelection = false;
  export let svgMapAllowInterMapAreaSelection = false;
  export let links = [];
  export let focusAreaId = "";
  $: focusOnArea = focusAreaId != "";
  $: selectedLinkId = selectedLink.id;

  export let areasMap;
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

  export let chosenMap;
  $: xCenterPoint = focusOnArea
    ? areasMap[focusAreaId].mapX * chosenMap.gridSize + chosenMap.viewSize / 2
    : chosenMap.viewSize / 2;
  $: yCenterPoint = focusOnArea
    ? -areasMap[focusAreaId].mapY * chosenMap.gridSize + chosenMap.viewSize / 2
    : chosenMap.viewSize / 2;
  $: viewBoxXSize = chosenMap.viewSize * zoomMultipliers[zoomMultierIndex];
  $: viewBoxYSize = Math.max(
    chosenMap.viewSize *
      (svgWrapperWidth / (svgWrapperHeight - 64)) *
      zoomMultipliers[zoomMultierIndex],
    0
  );
  $: viewBoxX = xCenterPoint - viewBoxXSize / 2;
  $: viewBoxY = yCenterPoint - viewBoxYSize / 2;
  $: viewBox =
    viewBoxX + " " + viewBoxY + " " + viewBoxXSize + " " + viewBoxYSize;

  $: svgAreaShapes = areas
    .map(function (area: AreaInterface) {
      let corners = area.mapCorners;
      let size = area.mapSize;
      let x = area.mapX;
      let y = area.mapY;
      let color =
        selectedArea != undefined && selectedArea.id == area.id
          ? "green"
          : linkPreviewAreaId == area.id
          ? "orange"
          : "blue";
      let name = area.name;
      let cls = svgMapAllowIntraMapAreaSelection
        ? selectedArea != undefined && area.id == selectedArea.id
          ? "cursor-not-allowed"
          : "cursor-pointer"
        : "cursor-auto";
      if (area.mapId != chosenMap.id) {
        name =
          (mapsMap[area.mapId] != undefined ? mapsMap[area.mapId].name : "") +
          ": " +
          area.name;
        cls = svgMapAllowInterMapAreaSelection
          ? "cursor-pointer"
          : "cursor-auto";
        // find link for map to override where this is drawn
        const link = links.find(
          (link) => link.toId == area.id || link.fromId == area.id
        );

        if (link != undefined) {
          if (link.fromId == area.id) {
            // outgoing link, use from values
            corners = link.localFromCorners;
            size = link.localFromSize;
            x = link.localFromX;
            y = link.localFromY;
            color = link.localFromColor;
          } else {
            // incoming link, use to values
            corners = link.localToCorners;
            size = link.localToSize;
            x = link.localToX;
            y = link.localToY;
            color = link.localToColor;
          }
        }
      }

      return buildSquare(
        area,
        chosenMap.gridSize,
        chosenMap.viewSize,
        color,
        x,
        y,
        size,
        corners,
        cls,
        name
      );
    })
    .sort(function (area1, area2) {
      if (area1.id == areaUnderConstruction.id) {
        return 1;
      } else if (area2.id == areaUnderConstruction.id) {
        return -1;
      } else {
        area1 <= area2;
      }
    });

  $: svgPreviewLinkShapes = [linkUnderConstruction]
    .filter(
      (link) =>
        link.toId != "" &&
        link.fromId != "" &&
        ((selectedArea.mapId != chosenMap.id &&
          areasMap[linkPreviewAreaId] != undefined) ||
          selectedArea.mapId == chosenMap.id)
    )
    .map(function (link) {
      let x1 = selectedArea.mapX;
      let y1 = selectedArea.mapY;
      let x2 = 0;
      let y2 = 0;
      let label;
      let labelRotation = 0;
      let labelHorizontalOffset;
      let labelVerticalOffset;
      let labelTransform = "";
      let labelFontSize = 12;

      // the selected area can only belong to another map if we're looking from the perspective of the secondary map
      // Use that to determine which coordinates to use
      const sameMap = selectedArea.mapId == chosenMap.id;

      if (sameMap && selectedArea.id == link.toId) {
        // incoming: Link is coming "from" other area
        const otherArea = areasMap[link.fromId];
        if (otherArea.mapId != selectedArea.mapId) {
          // Different maps
          x2 = link.localFromX;
          y2 = link.localFromY;
        } else {
          // Same map
          x2 = otherArea.mapX;
          y2 = otherArea.mapY;
        }
      } else if (sameMap && selectedArea.id == link.fromId) {
        // Outgoing Link is going "to" other area so take the local to coordinate
        const otherArea = areasMap[link.toId];

        if (otherArea.mapId != selectedArea.mapId) {
          // Different maps
          x2 = link.localToX;
          y2 = link.localToY;
        } else {
          // Same map
          x2 = otherArea.mapX;
          y2 = otherArea.mapY;
        }
      } else if (!sameMap) {
        const otherArea = areasMap[linkPreviewAreaId];
        x1 = otherArea.mapX;
        y1 = otherArea.mapY;

        if (link.toId == linkPreviewAreaId) {
          x2 = link.localFromX;
          y2 = link.localFromY;
        } else {
          x2 = link.localToX;
          y2 = link.localToY;
        }
      }

      if (sameMap) {
        label = link.label;
        labelRotation = link.labelRotation;
        labelHorizontalOffset = link.labelHorizontalOffset;
        labelVerticalOffset = link.labelVerticalOffset;
        labelFontSize = link.labelFontSize;
      } else if (!sameMap && selectedArea.id == link.fromId) {
        label = link.localFromLabel;
        labelRotation = link.localFromLabelRotation;
        labelHorizontalOffset = link.localFromLabelHorizontalOffset;
        labelVerticalOffset = link.localFromLabelVerticalOffset;
        labelFontSize = link.localFromLabelFontSize;
      } else if (!sameMap && selectedArea.id == link.toId) {
        label = link.localToLabel;
        labelRotation = link.localToLabelRotation;
        labelHorizontalOffset = link.localToLabelHorizontalOffset;
        labelVerticalOffset = link.localToLabelVerticalOffset;
        labelFontSize = link.localToLabelFontSize;
      }
      console.log(labelRotation);

      const stroke = "orange";
      const dashArray = "5";
      const gridSize = chosenMap.gridSize;
      const viewSize = chosenMap.viewSize;

      x1 = x1 * gridSize + viewSize / 2;
      y1 = -y1 * gridSize + viewSize / 2;
      x2 = x2 * gridSize + viewSize / 2;
      y2 = -y2 * gridSize + viewSize / 2;

      const horizontalPosition = ((x1 + x2) / 2).toString();
      const verticalPosition = ((y1 + y2) / 2).toString();

      labelTransform = `translate(${labelHorizontalOffset}, ${-labelVerticalOffset}) rotate(${labelRotation}, ${horizontalPosition}, ${verticalPosition})`;

      return {
        id: "preview",
        type: "path",
        x1: x1,
        y1: y1,
        x2: x2,
        y2: y2,
        stroke: stroke,
        link: link,
        strokeDashArray: dashArray,
        label: label,
        labelTransform: labelTransform,
        labelFontSize: labelFontSize,
        labelX: horizontalPosition,
        labelY: verticalPosition,
        strokeWidth: 3
      };
    });

  $: svgPreviewLinkAreaShapes = [linkUnderConstruction]
    .filter(function (link) {
      return (
        (link.toId != "" || link.fromId != "") &&
        linkPreviewAreaId != "" &&
        ((selectedArea.mapId == chosenMap.id &&
          areasMap[linkPreviewAreaId].mapId != chosenMap.id) ||
          selectedArea.mapId != chosenMap.id)
      );
    })
    .map(function (link) {
      let x;
      let y;
      let color;
      let size;
      let corners;
      let name;

      // the selected area can only belong to another map if we're looking from the perspective of the secondary map
      // Use that to determine which coordinates to use
      const sameMap = selectedArea.mapId == chosenMap.id;

      if (
        (sameMap && link.toId == selectedArea.id) ||
        (!sameMap && link.toId == linkPreviewAreaId)
      ) {
        x = link.localFromX;
        y = link.localFromY;
        color = link.localFromColor;
        size = link.localFromSize;
        corners = link.localFromCorners;
      } else if (
        (sameMap && link.fromId == selectedArea.id) ||
        (!sameMap && link.fromId == linkPreviewAreaId)
      ) {
        x = link.localToX;
        y = link.localToY;
        color = link.localToColor;
        size = link.localToSize;
        corners = link.localToCorners;
      }

      // In this case same map means the "source" map which is being linked from
      if (sameMap) {
        name =
          mapsMap[areasMap[linkPreviewAreaId].mapId].name +
          ": " +
          areasMap[linkPreviewAreaId].name;
      } else {
        name = mapsMap[selectedArea.mapId].name + ": " + selectedArea.name;
      }

      return buildSquare(
        selectedArea,
        chosenMap.gridSize,
        chosenMap.viewSize,
        color,
        x,
        y,
        size,
        corners,
        svgMapAllowIntraMapAreaSelection ? "cursor-pointer" : "cursor-auto",
        name
      );
    });

  $: svglinkShapes = links
    .filter(function (link: LinkInterface) {
      return (
        areasMap[link.toId] != undefined && areasMap[link.fromId] != undefined
      );
    })
    .sort(function (link1: LinkInterface, link2: LinkInterface) {
      if (link1.id == selectedLinkId) {
        return 1;
      } else if (link2.id == selectedLinkId) {
        return -1;
      } else {
        return link1.id == link2.id ? 0 : link1.id < link2.id ? -1 : 1;
      }
    })
    .map(function (link: LinkInterface) {
      const toArea =
        link.toId == areaUnderConstruction.id
          ? areaUnderConstruction
          : areasMap[link.toId];
      const fromArea =
        link.fromId == areaUnderConstruction.id
          ? areaUnderConstruction
          : areasMap[link.fromId];
      const fromMapX =
        fromArea.mapId == chosenMap.id ? fromArea.mapX : link.localFromX;
      const fromMapY =
        fromArea.mapId == chosenMap.id ? fromArea.mapY : link.localFromY;
      const toMapX = toArea.mapId == chosenMap.id ? toArea.mapX : link.localToX;
      const toMapY = toArea.mapId == chosenMap.id ? toArea.mapY : link.localToY;
      const stroke = "white";
      const gridSize = chosenMap.gridSize;
      const viewSize = chosenMap.viewSize;

      const sameMap =
        selectedArea.id == "" || selectedArea.mapId == chosenMap.id;
      let label;
      let labelRotation;
      let labelHorizontalOffset;
      let labelVerticalOffset;
      let labelTransform = "";
      let labelFontSize = 12;

      if (sameMap) {
        label = link.label;
        labelRotation = link.labelRotation;
        labelHorizontalOffset = link.labelHorizontalOffset;
        labelVerticalOffset = link.labelVerticalOffset;
        labelFontSize = link.labelFontSize;
      } else if (!sameMap && selectedArea.id == link.fromId) {
        label = link.localFromLabel;
        labelRotation = link.localFromLabelRotation;
        labelHorizontalOffset = link.localFromLabelHorizontalOffset;
        labelVerticalOffset = link.localFromLabelVerticalOffset;
        labelFontSize = link.localFromLabelFontSize;
      } else if (!sameMap && selectedArea.id == link.toId) {
        label = link.localToLabel;
        labelRotation = link.localToLabelRotation;
        labelHorizontalOffset = link.localToLabelHorizontalOffset;
        labelVerticalOffset = link.localToLabelVerticalOffset;
        labelFontSize = link.localToLabelFontSize;
      }

      const x1 = fromMapX * gridSize + viewSize / 2;
      const y1 = -fromMapY * gridSize + viewSize / 2;
      const x2 = toMapX * gridSize + viewSize / 2;
      const y2 = -toMapY * gridSize + viewSize / 2;

      const horizontalPosition = ((x1 + x2) / 2).toString();
      const verticalPosition = ((y1 + y2) / 2).toString();

      labelTransform = `translate(${labelHorizontalOffset}, ${-labelVerticalOffset}) rotate(${labelRotation}, ${horizontalPosition}, ${verticalPosition})`;

      return {
        id: link.id,
        type: "path",
        x1: x1,
        y1: y1,
        x2: x2,
        y2: y2,
        stroke: selectedLinkId == link.id ? "red" : stroke,
        link: link,
        strokeDashArray: "0",
        label: label,
        labelTransform: labelTransform,
        labelFontSize: labelFontSize,
        labelX: horizontalPosition,
        labelY: verticalPosition,
        strokeWidth: 3
      };
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
    cls: string,
    name: string
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
      name: name,
      area: area,
      cls: cls,
    };
  }

  function zoomIn() {
    zoomMultierIndex = --zoomMultierIndex;
    // calculateViewBox();
  }

  function zoomOut() {
    zoomMultierIndex = ++zoomMultierIndex;
    // calculateViewBox();
  }

  function handleSelectArea(event) {
    if (
      (svgMapAllowIntraMapAreaSelection &&
        event.detail.mapId == chosenMap.id) ||
      (svgMapAllowInterMapAreaSelection && event.detail.mapId != chosenMap.id)
    ) {
      WorldBuilderStore.selectArea(event.detail);
    }
  }
</script>

<div
  bind:clientWidth={svgWrapperWidth}
  bind:clientHeight={svgWrapperHeight}
  class="p-1 h-full w-full max-w-full max-h-full flex flex-col {mapSelected ? '' : 'place-content-center'}">
  {#if mapSelected}
    {#if loadingMapData}
      <div class="flex-1 flex flex-col items-center justify-center">
        <Circle2 />
        <h2 class="mt-6 text-center text-3xl font-extrabold text-gray-500">
          Loading map data
        </h2>
      </div>
    {:else}
      <p class="flex-shrink text-gray-300 w-full text-center">
        {chosenMap.name}
      </p>
      <div class="flex-1 overflow-hidden">
        <Svg
          {viewBox}
          shapes={[...svglinkShapes, ...svgPreviewLinkShapes, ...svgAreaShapes, ...svgPreviewLinkAreaShapes]}
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
