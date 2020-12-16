<script lang="ts">
  import { Circle2 } from "svelte-loading-spinners";
  import Svg from "../../../../../components/Svg.svelte";
  import AreaState from "../../../../../models/area";
  import type { AreaInterface } from "../../../../../models/area";
  import LinkState from "../../../../../models/link";
  import type { LinkInterface } from "../../../../../models/link";
  import { WorldBuilderStore } from "./state";
  import { beforeUpdate } from "svelte";
  import App from "../../../../../App.svelte";
  import AreaDetails from "./AreaDetails.svelte";
  import AreaEditor from "./AreaEditor.svelte";

  // This map can be in one of two modes.
  // Primary mode
  //    It is the main map in the builder
  // Secondary mode
  //    It is the secondary map in the link editor

  // It needs a list of all areas and maps
  //  In both cases it will need all areas and maps because it needs to extract names

  // Focus area
  //  Focus area can be the area being constructed or the area being chosen to be linked to

  // Focus link
  //   Focus link can be the link being constructed, the link being selected

  // In both Primary and Secondary mode, the map is the perspective that the rooms are being drawn from.
  // As the map will only be shown in Secondary mode when trying to create a new link to a different map, this will always be the "other" map
  export let chosenMap;
  $: mapSelected = chosenMap != undefined && chosenMap.id != "";

  // All of the maps that can potentially be referenced by an outgoing/incoming link
  // export let mapsMap = {};

  // All of the areas that need to be drawn on the map
  export let areas = [];

  // A superset of the areas above. Must contain all the areas being drawn within the map, and any areas being linked to from other maps.
  export let areasMap = {};

  // All of the loaded maps that could be linked to
  export let mapsMap = {};

  // All of the links that need to be drawn on the map
  export let links = [];

  // The area, if any, that should be the central focus of the map. If this is not set, the center of the map will be used instead
  export let focusAreaId = "";
  $: focusOnArea = focusAreaId != "";

  // Whether or not the data for the chosen map is loading. This would be the links, areasMap, and areas
  export let loadingMapData = false;

  // An array of all of the areas which should be highlighted. For example an area that is focused on may or may not be highlighted.
  export let highlightedAreaIds = [];

  // An array of all of the links which should be highlighted. For example a link that is selected may or may not be highlighted.
  export let highlightedLinkIds = [];

  // Areas being built need to be displayed for helping with positioning and map look
  // export let buildingArea = false;
  // export let areaUnderConstruction = { ...AreaState };

  // Links being built need to be displayed for helping with positioning and map look
  // export let buildingLink = false;
  export let linkUnderConstruction = { ...LinkState };

  // When constructing a link it's coming/going from/to "somewhere". One "end" of the link is the room being linked, and this is the source.
  // export let linkUnderConstructionSourceAreaId = "";

  // Controls display and code behavior when it comes to selecting different types of areas
  export let svgMapAllowIntraMapAreaSelection = false;
  export let svgMapAllowInterMapAreaSelection = false;

  const highlightColor = "#ff6600";

  // Zoom stuff
  let zoomMultipliers = [0.00775, 0.015, 0.03, 0.06, 0.125, 0.25, 0.5];
  let zoomMultierIndex = 3;
  $: zoomOutButtonDisabled = zoomMultierIndex == zoomMultipliers.length - 1;
  $: zoomInButtonDisabled = zoomMultierIndex == 0;

  // Aspect ratio
  let svgWrapperWidth = 16;
  let svgWrapperHeight = 9;

  // Viewbox sizing
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
  $: viewBox = `${viewBoxX} ${viewBoxY} ${viewBoxXSize} ${viewBoxYSize}`;

  $: existingIntraMapLinks =
    mapSelected && links != undefined && areasMap != undefined
      ? buildExistingIntraMapLinks()
      : [];

  // These are your already existing links between rooms, within a single map. One or more of them could be highlighted.
  function buildExistingIntraMapLinks() {
    console.log("buildExistingIntraMapLinks");
    console.log(areasMap);
    console.log(links);
    return links
      .filter((link) => {
        return (
          link.id != "" &&
          areasMap[link.toId] != undefined &&
          areasMap[link.fromId] != undefined &&
          areasMap[link.fromId].mapId == chosenMap.id &&
          areasMap[link.fromId].mapId == areasMap[link.toId].mapId
        );
      })
      .map((link) => {
        console.log("link");
        console.log(link);
        return buildPathFromLink(
          link,
          areasMap[link.fromId].mapX,
          areasMap[link.fromId].mapY,
          areasMap[link.toId].mapX,
          areasMap[link.toId].mapY
        );
      });
  }

  $: newIntraMapLinks =
    mapSelected &&
    links != undefined &&
    areasMap != undefined &&
    linkUnderConstruction != undefined
      ? buildNewIntraMapLinks()
      : [];

  // These links, though per current design it is only ever one, are under construction and are being displayed as a preview
  function buildNewIntraMapLinks() {
    console.log("buildNewIntraMapLinks");
    console.log(areasMap);
    console.log(links);
    return [linkUnderConstruction]
      .filter((link) => {
        return (
          link.id == "" &&
          areasMap[link.toId] != undefined &&
          areasMap[link.fromId] != undefined &&
          areasMap[link.fromId].mapId == chosenMap.id &&
          areasMap[link.fromId].mapId == areasMap[link.toId].mapId
        );
      })
      .map((link) => {
        console.log("link");
        console.log(link);
        return buildPathFromLink(
          link,
          areasMap[link.fromId].mapX,
          areasMap[link.fromId].mapY,
          areasMap[link.toId].mapX,
          areasMap[link.toId].mapY
        );
      });
  }

  $: existingInterMapLinks =
    mapSelected && links != undefined && areasMap != undefined
      ? buildExistingInterMapLinks()
      : [];

  // These are your already existing links between rooms, within a single map. One or more of them could be highlighted.
  function buildExistingInterMapLinks() {
    console.log("buildExistingInterMapLinks");
    console.log(areasMap);
    console.log(links);
    return links
      .filter((link) => {
        return (
          link.id != "" &&
          areasMap[link.toId] != undefined &&
          areasMap[link.fromId] != undefined &&
          areasMap[link.fromId].mapId != areasMap[link.toId].mapId &&
          (areasMap[link.fromId].mapId == chosenMap.id ||
            areasMap[link.toId].mapId == chosenMap.id)
        );
      })
      .map((link) => {
        return buildInterMapLink(link);
      });
  }

  $: newInterMapLinks =
    mapSelected &&
    links != undefined &&
    areasMap != undefined &&
    linkUnderConstruction != undefined
      ? buildNewInterMapLinks()
      : [];

  // These are your already existing links between rooms, within a single map. One or more of them could be highlighted.
  function buildNewInterMapLinks() {
    console.log("buildNewInterMapLinks");
    console.log(areasMap);
    console.log(links);
    return [linkUnderConstruction]
      .filter((link) => {
        return (
          link.id == "" &&
          areasMap[link.toId] != undefined &&
          areasMap[link.fromId] != undefined &&
          areasMap[link.fromId].mapId != areasMap[link.toId].mapId &&
          (areasMap[link.fromId].mapId == chosenMap.id ||
            areasMap[link.toId].mapId == chosenMap.id)
        );
      })
      .map((link) => {
        return buildInterMapLink(link);
      });
  }

  function buildInterMapLink(link) {
    const modifiedLink = { ...link };
    let toX;
    let toY;
    let fromX;
    let fromY;

    // incoming
    if (areasMap[link.toId].mapId == chosenMap.id) {
      modifiedLink.label = link.localFromLabel;
      modifiedLink.labelFontSize = link.localFromLabelFontSize;
      modifiedLink.labelHorizontalOffset = link.localFromLabelHorizontalOffset;
      modifiedLink.labelVerticalOffset = link.localFromLabelVerticalOffset;
      modifiedLink.labelRotation = link.localFromLabelRotation;
      modifiedLink.labelColor = link.localFromLabelColor;
      modifiedLink.lineColor = link.localFromLineColor;
      modifiedLink.lineDash = link.localFromLineDash;
      modifiedLink.lineWidth = link.localFromLineWidth;
      fromX = link.localFromX;
      fromY = link.localFromY;
      toX = areasMap[link.toId].mapX;
      toY = areasMap[link.toId].mapY;
    } else {
      modifiedLink.label = link.localToLabel;
      modifiedLink.labelFontSize = link.localToLabelFontSize;
      modifiedLink.labelHorizontalOffset = link.localToLabelHorizontalOffset;
      modifiedLink.labelVerticalOffset = link.localToLabelVerticalOffset;
      modifiedLink.labelRotation = link.localToLabelRotation;
      modifiedLink.labelColor = link.localToLabelColor;
      modifiedLink.lineColor = link.localToLineColor;
      modifiedLink.lineDash = link.localToLineDash;
      modifiedLink.lineWidth = link.localToLineWidth;
      toX = link.localToX;
      toY = link.localToY;
      fromX = areasMap[link.fromId].mapX;
      fromY = areasMap[link.fromId].mapY;
    }

    return buildPathFromLink(link, fromX, fromY, toX, toY);
  }

  $: newInterMapLinkAreas =
    mapSelected &&
    links != undefined &&
    areasMap != undefined &&
    linkUnderConstruction != undefined
      ? buildNewInterMapLinkAreas()
      : [];

  // These are the areas being linked to that exist outside the map. A local representation of the area needs to be
  // built from the link
  function buildNewInterMapLinkAreas() {
    console.log("buildNewInterMapLinkAreas");
    console.log(areasMap);
    console.log(links);
    return [linkUnderConstruction]
      .filter((link) => {
        return (
          link.id == "" &&
          areasMap[link.toId] != undefined &&
          areasMap[link.fromId] != undefined &&
          areasMap[link.fromId].mapId != areasMap[link.toId].mapId &&
          (areasMap[link.fromId].mapId == chosenMap.id ||
            areasMap[link.toId].mapId == chosenMap.id)
        );
      })
      .map((link) => {
        // Build up an area from the link and display that
        const generatedArea = { ...AreaState };
        generatedArea.id = "InterMapLinkAreaPreview";

        // incoming link
        if (areasMap[link.toId].mapId == chosenMap.id) {
          generatedArea.color = link.localFromColor;
          generatedArea.borderColor = link.localFromBorderColor;
          generatedArea.borderWidth = link.localFromBorderWidth;
          generatedArea.mapCorners = link.localFromCorners;
          generatedArea.mapSize = link.localFromSize;
          generatedArea.mapX = link.localFromX;
          generatedArea.mapY = link.localFromY;
          generatedArea.name = `${mapsMap[areasMap[link.fromId].mapId].name}, ${
            areasMap[link.fromId].name
          }`;
        } else if (areasMap[link.fromId].mapId == chosenMap.id) {
          generatedArea.color = link.localToColor;
          generatedArea.borderColor = link.localToBorderColor;
          generatedArea.borderWidth = link.localToBorderWidth;
          generatedArea.mapCorners = link.localToCorners;
          generatedArea.mapSize = link.localToSize;
          generatedArea.mapX = link.localToX;
          generatedArea.mapY = link.localToY;
          generatedArea.name = `${mapsMap[areasMap[link.toId].mapId].name}, ${
            areasMap[link.toId].name
          }`;
        }

        return buildRectFromArea(generatedArea);
      });
  }

  $: highlightsForExistingIntraMapLinks =
    mapSelected && areasMap != undefined && highlightedLinkIds.length > 0
      ? buildHighlightsForExistingIntraMapLinks()
      : [];

  function buildHighlightsForExistingIntraMapLinks() {
    return highlightedLinkIds.map((linkId) => {
      const link = { ...links.find((link) => link.id == linkId) };
      link.lineColor = highlightColor;
      link.lineWidth = link.lineWidth + 1;
      link.label = "";
      link.hasMarker = false;

      return buildPathFromLink(
        link,
        areasMap[link.fromId].mapX,
        areasMap[link.fromId].mapY,
        areasMap[link.toId].mapX,
        areasMap[link.toId].mapY
      );
    });
  }

  function buildPathFromLink(link, fromX, fromY, toX, toY) {
    const gridSize = chosenMap.gridSize;
    const viewSize = chosenMap.viewSize;

    const horizontalPosition = ((fromX + toX) / 2).toString();
    const verticalPosition = ((fromY + toY) / 2).toString();

    let labelTransform = `translate(${
      link.labelHorizontalOffset
    }, ${-link.labelVerticalOffset}) rotate(${
      link.labelRotation
    }, ${horizontalPosition}, ${verticalPosition})`;

    const result = {
      id: link.id,
      type: "path",
      x1: fromX * gridSize + viewSize / 2,
      y1: -fromY * gridSize + viewSize / 2,
      x2: toX * gridSize + viewSize / 2,
      y2: -toY * gridSize + viewSize / 2,
      link: link,
      label: link.label.split("\n"),
      labelTransform: labelTransform,
      labelFontSize: link.labelFontSize,
      labelX: horizontalPosition,
      labelY: verticalPosition,
      lineWidth: link.lineWidth,
      lineColor: link.lineColor,
      lineDash: link.lineDash,
      labelColor: link.labelColor,
      hasMarker: link.hasMarker,
      markerOffset: link.markerOffset,
      markerColor: link.lineColor,
      markerWidth: link.lineWidth * 3,
      markerHeight: link.lineWidth * 3,
    };

    if (highlightedLinkIds.includes(link.id)) {
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
  }

  $: existingIntraMapAreas =
    mapSelected && links != undefined && areasMap != undefined
      ? buildExistingIntraMapAreas()
      : [];

  function buildExistingIntraMapAreas() {
    console.log("buildExistingIntraMapAreas");
    console.log(areasMap);
    console.log(areas);
    return areas
      .filter((area) => {
        return (
          area.id != "" &&
          areasMap[area.id] != undefined &&
          area.mapId == chosenMap.id
        );
      })
      .map((area) => {
        console.log("area");
        console.log(area);
        return buildRectFromArea(area);
      });
  }

  $: highlightsForExistingIntraMapAreas =
    mapSelected && areasMap != undefined && highlightedAreaIds.length > 0
      ? buildHighlightsForExistingIntraMapAreas()
      : [];

  function buildHighlightsForExistingIntraMapAreas() {
    return (
      highlightedAreaIds
        // .filter((area) => {
        //   return (
        //     area.id != "" &&
        //     highlightedAreaIds.includes(area.id) &&
        //     areasMap[area.id] != undefined &&
        //     area.mapId == chosenMap.id
        //   );
        // })
        .map((areaId) => {
          console.log("hightliughted araasdhasd");
          console.log(areaId);
          const area = { ...areasMap[areaId] };
          area.mapSize = area.mapSize + 3;
          area.borderColor = highlightColor;
          area.color = highlightColor;
          area.borderWidth = Math.max(3, area.borderWidth + 1);
          area.id = `${area.id}-highlight`;
          console.log(area);

          return buildRectFromArea(area);
        })
    );
  }

  function buildRectFromArea(area) {
    let cls = svgMapAllowIntraMapAreaSelection
      ? "cursor-pointer"
      : "cursor-auto";

    return {
      id: area.id,
      type: "rect",
      x:
        area.mapX * chosenMap.gridSize +
        chosenMap.viewSize / 2 -
        area.mapSize / 2,
      y:
        -area.mapY * chosenMap.gridSize +
        chosenMap.viewSize / 2 -
        area.mapSize / 2,
      width: area.mapSize,
      height: area.mapSize,
      corners: area.mapCorners,
      fill: area.color,
      name: area.name,
      area: area,
      cls: cls,
      borderColor: area.borderColor,
      borderWidth: area.borderWidth,
    };
  }

  $: existingInterMapAreas =
    mapSelected && links != undefined && areasMap != undefined
      ? buildExistingInterMapAreas()
      : [];

  function buildExistingInterMapAreas() {
    console.log("buildExistingInterMapAreas");
    console.log(areasMap);
    console.log(areas);
    return areas
      .filter((area) => {
        return (
          area.id != "" &&
          areasMap[area.id] != undefined &&
          area.mapId != chosenMap.id
        );
      })
      .map((area) => {
        console.log("area");
        console.log(area);

        const modifiedArea = { ...area };

        // find a link which points to this other area in this other map
        // overwrite area settings with 'local' settings from link and then build

        const link = links.find(
          (link) => link.toId == area.id || link.fromId == area.id
        );

        console.log("found link");
        console.log(link);

        // Outgoing to other area.
        // Use local 'to'
        if (link.toId == area.id) {
          modifiedArea.mapSize = link.localToSize;
          modifiedArea.mapCorners = link.localToCorners;
          modifiedArea.color = link.localToColor;

          modifiedArea.borderColor = link.localToBorderColor;
          modifiedArea.borderWidth = link.localToBorderWidth;

          modifiedArea.mapX = link.localToX;
          modifiedArea.mapY = link.localToY;

          modifiedArea.name = `${mapsMap[areasMap[link.toId].mapId].name}, ${
            areasMap[link.toId].name
          }`;
        } else {
          modifiedArea.mapSize = link.localFromSize;
          modifiedArea.mapCorners = link.localFromCorners;
          modifiedArea.color = link.localFromColor;

          modifiedArea.borderColor = link.localFromBorderColor;
          modifiedArea.borderWidth = link.localFromBorderWidth;

          modifiedArea.mapX = link.localFromX;
          modifiedArea.mapY = link.localFromY;

          modifiedArea.name = `${mapsMap[areasMap[link.fromId].mapId].name}, ${
            areasMap[link.fromId].name
          }`;
        }

        console.log("modifiedArea");
        console.log(modifiedArea);

        return buildRectFromArea(modifiedArea);
      });
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
          shapes={[...highlightsForExistingIntraMapLinks, ...highlightsForExistingIntraMapAreas, ...existingIntraMapLinks, ...existingInterMapLinks, ...newIntraMapLinks, ...newInterMapLinks, ...existingIntraMapAreas, ...existingInterMapAreas, ...newInterMapLinkAreas].flat(2)}
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
