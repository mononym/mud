<script lang="ts">
  import { Circle2 } from "svelte-loading-spinners";
  import Svg from "../Svg.svelte";
  import AreaState from "../../models/area";
  import type { AreaInterface } from "../../models/area";
  import LinkState from "../../models/link";
  import type { LinkInterface } from "../../models/link";
  import { createEventDispatcher } from "svelte";
  import { WorldBuilderStore } from "./state";

  const dispatch = createEventDispatcher();

  export let selectedLink = { ...LinkState };
  export let mapSelected = true;
  export let loadingMapData = false;
  export let buildingArea = false;
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
    : buildingArea
    ? areaUnderConstruction.mapX * chosenMap.gridSize + chosenMap.viewSize / 2
    : chosenMap.viewSize / 2;
  $: yCenterPoint = focusOnArea
    ? -areasMap[focusAreaId].mapY * chosenMap.gridSize + chosenMap.viewSize / 2
    : buildingArea
    ? -areaUnderConstruction.mapY * chosenMap.gridSize + chosenMap.viewSize / 2
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
    .filter((area) => areaUnderConstruction.id != area.id)
    .map(function (area: AreaInterface) {
      let corners = area.mapCorners;
      let size = area.mapSize;
      let x = area.mapX;
      let y = area.mapY;
      let name = area.name;
      let cls = svgMapAllowIntraMapAreaSelection
        ? selectedArea != undefined && area.id == selectedArea.id
          ? "cursor-not-allowed"
          : "cursor-pointer"
        : "cursor-auto";

      let borderWidth = area.borderWidth;
      let borderColor = area.borderColor;
      let color = area.color;

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
            borderWidth = link.localFromBorderWidth;
            borderColor = link.localFromBorderColor;
          } else {
            // incoming link, use to values
            corners = link.localToCorners;
            size = link.localToSize;
            x = link.localToX;
            y = link.localToY;
            color = link.localToColor;
            borderWidth = link.localToBorderWidth;
            borderColor = link.localToBorderColor;
          }
        }
      }

      const params = buildSquare(
        area,
        chosenMap.gridSize,
        chosenMap.viewSize,
        color,
        x,
        y,
        size,
        corners,
        cls,
        name,
        borderColor,
        borderWidth
      );

      if (selectedArea.id == area.id) {
        return [
          {
            ...params,
            ...{
              borderWidth: 6,
              borderColor: "#ff6600",
              width: <number>params.width + 2,
              height: <number>params.height + 2,
              x: <number>params.x - 1,
              y: <number>params.y - 1,
              fill: "#ff6600",
            },
          },
          params,
        ];
      } else {
        return [params];
      }
    })
    .flat();

  $: svgPreviewLinkShapes = [linkUnderConstruction]
    .filter(
      (link) =>
        // preview only if the link has areas at both ends selected
        link.toId != "" &&
        link.fromId != "" &&
        // If areas at either end are on different maps, make sure both are loaded
        ((selectedArea.mapId != chosenMap.id &&
          areasMap[linkPreviewAreaId] != undefined) ||
          // Otherwise if same map continue
          selectedArea.mapId == chosenMap.id)
    )
    .map(function (link) {
      let x1 = 0;
      let y1 = 0;
      let x2 = 0;
      let y2 = 0;
      let label = "";
      let labelRotation = 0;
      let labelHorizontalOffset;
      let labelVerticalOffset;
      let labelTransform = "";
      let labelFontSize = 8;
      let labelColor = "#000000";
      let lineWidth = 2;
      let lineColor = "#000000";
      let lineDash = 0;
      let hasMarker = link.hasMarker;
      let markerOffset = link.markerOffset;

      // the selected area can only belong to another map if we're looking from the perspective of the secondary map
      // Use that to determine which coordinates to use
      const primaryMap = selectedArea.mapId == chosenMap.id;

      if (primaryMap && selectedArea.id == link.toId) {
        // incoming: Link is coming "from" other area
        x2 = selectedArea.mapX;
        y2 = selectedArea.mapY;

        const otherArea = areasMap[link.fromId];
        if (otherArea.mapId != selectedArea.mapId) {
          // Different maps
          x1 = link.localFromX;
          y1 = link.localFromY;
        } else {
          // Same map
          x1 = otherArea.mapX;
          y1 = otherArea.mapY;
        }

        lineWidth = link.lineWidth;
      } else if (primaryMap && selectedArea.id == link.fromId) {
        // Outgoing Link is going "to" other area so take the local to coordinate
        x1 = selectedArea.mapX;
        y1 = selectedArea.mapY;
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

        lineWidth = link.localToLineWidth;
      } else if (!primaryMap && selectedArea.id == link.toId) {
        const otherArea = areasMap[link.fromId]; // grab from
        x1 = otherArea.mapX;
        y1 = otherArea.mapY;
        x2 = link.localToX;
        y2 = link.localToY;

        lineWidth = link.localToLineWidth;
      } else if (!primaryMap && selectedArea.id == link.fromId) {
        const otherArea = areasMap[link.toId]; // grab from
        x2 = otherArea.mapX;
        y2 = otherArea.mapY;
        x1 = link.localFromX;
        y1 = link.localFromY;

        lineWidth = link.localFromLineWidth;
      }

      if (primaryMap) {
        label = link.label;
        labelRotation = link.labelRotation;
        labelHorizontalOffset = link.labelHorizontalOffset;
        labelVerticalOffset = link.labelVerticalOffset;
        labelFontSize = link.labelFontSize;
        lineColor = link.lineColor;
        lineWidth = link.lineWidth;
        lineDash = link.lineDash;
        labelColor = link.labelColor;
      } else if (!primaryMap && selectedArea.id == link.fromId) {
        label = link.localFromLabel;
        labelRotation = link.localFromLabelRotation;
        labelHorizontalOffset = link.localFromLabelHorizontalOffset;
        labelVerticalOffset = link.localFromLabelVerticalOffset;
        labelFontSize = link.localFromLabelFontSize;
        lineColor = link.localFromLineColor;
        lineWidth = link.localFromLineWidth;
        lineDash = link.localFromLineDash;
        labelColor = link.localFromLabelColor;
      } else if (!primaryMap && selectedArea.id == link.toId) {
        label = link.localToLabel;
        labelRotation = link.localToLabelRotation;
        labelHorizontalOffset = link.localToLabelHorizontalOffset;
        labelVerticalOffset = link.localToLabelVerticalOffset;
        labelFontSize = link.localToLabelFontSize;
        lineColor = link.localToLineColor;
        lineWidth = link.localToLineWidth;
        lineDash = link.localToLineDash;
        labelColor = link.localToLabelColor;
      }

      const gridSize = chosenMap.gridSize;
      const viewSize = chosenMap.viewSize;

      x1 = x1 * gridSize + viewSize / 2;
      y1 = -y1 * gridSize + viewSize / 2;
      x2 = x2 * gridSize + viewSize / 2;
      y2 = -y2 * gridSize + viewSize / 2;

      const horizontalPosition = ((x1 + x2) / 2).toString();
      const verticalPosition = ((y1 + y2) / 2).toString();

      labelTransform = `translate(${labelHorizontalOffset}, ${-labelVerticalOffset}) rotate(${labelRotation}, ${horizontalPosition}, ${verticalPosition})`;

      const params = {
        id: "preview",
        type: "path",
        x1: x1,
        y1: y1,
        x2: x2,
        y2: y2,
        link: link,
        label: label.split("\n"),
        labelTransform: labelTransform,
        labelFontSize: labelFontSize,
        labelX: horizontalPosition,
        labelY: verticalPosition,
        lineWidth: lineWidth,
        lineColor: lineColor,
        lineDash: lineDash,
        labelColor: labelColor,
        hasMarker: hasMarker,
        markerOffset: markerOffset,
        markerColor: lineColor,
        markerWidth: lineWidth * 3,
        markerHeight: lineWidth * 3,
      };

      if (link.id == selectedLinkId) {
        const duplicateResults = {
          ...params,
          ...{
            lineColor: "#FF6600",
            lineWidth: params.lineWidth + 6,
            label: "",
            hasMarker: false,
            id: "preview-duplicate",
          },
        };

        return [duplicateResults, params];
      } else {
        return [params];
      }
    })
    .flat();

  $: svgPreviewLinkAreaShapes = [linkUnderConstruction]
    .filter(function (link) {
      return (
        (link.toId != "" || link.fromId != "") &&
        linkPreviewAreaId != "" &&
        ((selectedArea.mapId == chosenMap.id &&
          areasMap[linkPreviewAreaId] != undefined &&
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
      let borderWidth;
      let borderColor;

      // the selected area can only belong to another map if we're looking from the perspective of the secondary map
      // Use that to determine which coordinates to use
      const primaryMap = selectedArea.mapId == chosenMap.id;

      if (
        (primaryMap && link.toId == selectedArea.id) ||
        (!primaryMap && link.toId == linkPreviewAreaId)
      ) {
        x = link.localFromX;
        y = link.localFromY;
        color = link.localFromColor;
        size = link.localFromSize;
        corners = link.localFromCorners;
        borderWidth = link.localFromBorderWidth;
        borderColor = link.localFromBorderColor;
      } else if (
        (primaryMap && link.fromId == selectedArea.id) ||
        (!primaryMap && link.fromId == linkPreviewAreaId)
      ) {
        x = link.localToX;
        y = link.localToY;
        color = link.localToColor;
        size = link.localToSize;
        corners = link.localToCorners;
        borderWidth = link.localToBorderWidth;
        borderColor = link.localToBorderColor;
      }

      // In this case same map means the "source" map which is being linked from
      if (primaryMap) {
        name =
          mapsMap[areasMap[linkPreviewAreaId].mapId].name +
          ": " +
          areasMap[linkPreviewAreaId].name;
      } else {
        name = mapsMap[selectedArea.mapId].name + ": " + selectedArea.name;
      }

      const props = buildSquare(
        selectedArea,
        chosenMap.gridSize,
        chosenMap.viewSize,
        color,
        x,
        y,
        size,
        corners,
        svgMapAllowIntraMapAreaSelection ? "cursor-pointer" : "cursor-auto",
        name,
        borderColor,
        borderWidth
      );

      return [
        {
          ...props,
          ...{
            borderColor: "#ff6600",
            borderWidth: 6,
            width: <number>props.width + 2,
            height: <number>props.height + 2,
            x: <number>props.x - 1,
            y: <number>props.y - 1,
            fill: "#ff6600",
          },
        },
        props,
      ];
    })
    .flat();

  $: svgAreaUnderConstructionPreviewShapes = [areaUnderConstruction]
    .filter(function (area) {
      return buildingArea == true;
    })
    .map(function (area) {
      let cls = svgMapAllowIntraMapAreaSelection
        ? "cursor-pointer"
        : "cursor-auto";

      const props = buildSquare(
        area,
        chosenMap.gridSize,
        chosenMap.viewSize,
        area.color,
        area.mapX,
        area.mapY,
        area.mapSize,
        area.mapCorners,
        cls,
        area.name,
        area.borderColor,
        area.borderWidth
      );

      return [
        {
          ...props,
          ...{
            borderColor: "#ff6600",
            borderWidth: Math.max(2, area.borderWidth),
            width: <number>props.width + 2,
            height: <number>props.height + 2,
            x: <number>props.x - 1,
            y: <number>props.y - 1,
            fill: "#ff6600",
          },
        },
        props,
      ];
    })
    .flat();

  $: svglinkShapes = links
    .filter(function (link: LinkInterface) {
      return (
        areasMap[link.toId] != undefined &&
        areasMap[link.fromId] != undefined &&
        link.id != linkUnderConstruction.id
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
      const gridSize = chosenMap.gridSize;
      const viewSize = chosenMap.viewSize;

      const primaryMap =
        selectedArea.id == "" || selectedArea.mapId == chosenMap.id;
      let label = "";
      let labelRotation;
      let labelHorizontalOffset;
      let labelVerticalOffset;
      let labelTransform = "";
      let labelFontSize = 8;
      let lineWidth = 2;
      let lineColor = "#FFFFFF";
      let lineDash = 0;
      let labelColor = "#FFFFFF";
      let hasMarker = link.hasMarker;
      let markerOffset = link.markerOffset;

      if (primaryMap) {
        label = link.label;
        labelRotation = link.labelRotation;
        labelHorizontalOffset = link.labelHorizontalOffset;
        labelVerticalOffset = link.labelVerticalOffset;
        labelFontSize = link.labelFontSize;
        lineColor = link.lineColor;
        lineWidth = link.lineWidth;
        lineDash = link.lineDash;
        labelColor = link.labelColor;
      } else if (!primaryMap && selectedArea.id == link.fromId) {
        label = link.localFromLabel;
        labelRotation = link.localFromLabelRotation;
        labelHorizontalOffset = link.localFromLabelHorizontalOffset;
        labelVerticalOffset = link.localFromLabelVerticalOffset;
        labelFontSize = link.localFromLabelFontSize;
        lineColor = link.localFromLineColor;
        lineWidth = link.localFromLineWidth;
        lineDash = link.localFromLineDash;
        labelColor = link.localFromLabelColor;
      } else if (!primaryMap && selectedArea.id == link.toId) {
        label = link.localToLabel;
        labelRotation = link.localToLabelRotation;
        labelHorizontalOffset = link.localToLabelHorizontalOffset;
        labelVerticalOffset = link.localToLabelVerticalOffset;
        labelFontSize = link.localToLabelFontSize;
        lineColor = link.localToLineColor;
        lineWidth = link.localToLineWidth;
        lineDash = link.localToLineDash;
        labelColor = link.localToLabelColor;
      }

      const x1 = fromMapX * gridSize + viewSize / 2;
      const y1 = -fromMapY * gridSize + viewSize / 2;
      const x2 = toMapX * gridSize + viewSize / 2;
      const y2 = -toMapY * gridSize + viewSize / 2;

      const horizontalPosition = ((x1 + x2) / 2).toString();
      const verticalPosition = ((y1 + y2) / 2).toString();

      labelTransform = `translate(${labelHorizontalOffset}, ${-labelVerticalOffset}) rotate(${labelRotation}, ${horizontalPosition}, ${verticalPosition})`;
      const result = {
        id: link.id,
        type: "path",
        x1: x1,
        y1: y1,
        x2: x2,
        y2: y2,
        link: link,
        label: label.split("\n"),
        labelTransform: labelTransform,
        labelFontSize: labelFontSize,
        labelX: horizontalPosition,
        labelY: verticalPosition,
        lineWidth: lineWidth,
        lineColor: lineColor,
        lineDash: lineDash,
        labelColor: labelColor,
        hasMarker,
        markerOffset,
        markerColor: lineColor,
        markerWidth: lineWidth * 3,
        markerHeight: lineWidth * 3,
      };
      if (link.id == selectedLinkId) {
        const duplicateResults = {
          ...result,
          ...{
            lineColor: "#FF6600",
            lineWidth: result.lineWidth + 6,
            label: "",
            hasMarker: false,
            id: `${link.id}-duplicate`,
          },
        };

        return [duplicateResults, result];
      } else {
        return [result];
      }
    })
    .flat();

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
    name: string,
    borderColor: string,
    borderWidth: number
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
      borderColor: borderColor,
      borderWidth: borderWidth,
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
          shapes={[...svglinkShapes, ...svgPreviewLinkShapes, ...svgAreaShapes, ...svgPreviewLinkAreaShapes, ...svgAreaUnderConstructionPreviewShapes]}
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
