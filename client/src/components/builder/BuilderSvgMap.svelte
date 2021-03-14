<script lang="ts">
  import { Circle2 } from "svelte-loading-spinners";
  import Svg from "../Svg.svelte";
  import AreaState from "../../models/area";
  import LinkState from "../../models/link";
  import MapLabelState from "../../models/mapLabel";
  import { WorldBuilderStore } from "./state";

  const { localToMapCoordinate } = WorldBuilderStore;

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

  // An areaMap for all of the areas that belong to another map being linked to, for referencing when drawing and so on.
  export let areasMapForOtherMap = {};

  // All of the loaded maps that could be linked to
  export let mapsMap = {};

  // All of the links that need to be drawn on the map
  export let links = [];

  // Whether or not the data for the chosen map is loading. This would be the links, areasMap, and areas
  export let loadingMapData = false;

  // An array of all of the areas which should be highlighted. For example an area that is focused on may or may not be highlighted.
  export let highlightedAreaIds = [];

  // An array of all of the links which should be highlighted. For example a link that is selected may or may not be highlighted.
  export let highlightedLinkIds = [];

  // Areas being built need to be displayed for helping with positioning and map look
  export let buildingArea = false;
  export let areaUnderConstruction = { ...AreaState };

  // Links being built need to be displayed for helping with positioning and map look
  export let buildingLink = false;
  export let linkUnderConstruction = { ...LinkState };

  // Map Labels being constructed.
  export let mapLabelUnderConstruction = { ...MapLabelState };

  // When constructing a link it's coming/going from/to "somewhere". One "end" of the link is the room being linked, and this is the source.
  // export let linkUnderConstructionSourceAreaId = "";

  // Controls display and code behavior when it comes to selecting different types of areas
  export let svgMapAllowIntraMapAreaSelection = false;
  export let svgMapAllowInterMapAreaSelection = false;

  export let mapFocusPointsX = 0;
  export let mapFocusPointsY = 0;

  $: allAreasMap = Object.assign(areasMap, areasMapForOtherMap);

  const highlightColor = "#ff6600";

  // Zoom stuff
  export let zoomMultiplier = 1;

  // Aspect ratio
  let svgWrapperWidth = 16;
  let svgWrapperHeight = 9;

  $: viewBoxXSize = chosenMap.viewSize * zoomMultiplier;
  $: viewBoxYSize = Math.max(
    chosenMap.viewSize *
      (svgWrapperWidth / (svgWrapperHeight - 64)) *
      zoomMultiplier,
    0
  );
  $: viewBoxX = mapFocusPointsX - viewBoxXSize / 2;
  $: viewBoxY = mapFocusPointsY - viewBoxYSize / 2;
  $: viewBox = `${viewBoxX} ${viewBoxY} ${viewBoxXSize} ${viewBoxYSize}`;

  $: newMapLabels =
    mapSelected &&
    chosenMap != undefined &&
    mapLabelUnderConstruction != undefined
      ? buildNewMapLabels()
      : [];

  // Labels for all of the under construction labels within a single map
  function buildNewMapLabels() {
    return [mapLabelUnderConstruction]
      .filter((label) => {
        return label.text != "";
      })
      .map((label) => {
        return buildLabelFromMapLabel(label);
      });
  }

  $: existingMapLabels =
    mapSelected &&
    chosenMap != undefined &&
    mapLabelUnderConstruction != undefined
      ? buildExistingMapLabels()
      : [];

  // Labels for all of the labels within a single map
  function buildExistingMapLabels() {
    return chosenMap.labels
      .filter((label) => {
        return label.id != mapLabelUnderConstruction.id;
      })
      .map((label) => {
        return buildLabelFromMapLabel(label);
      });
  }

  function buildLabelFromMapLabel(label) {
    const gridSize = chosenMap.gridSize;
    const viewSize = chosenMap.viewSize;

    const horizontalPosition = (label.x * gridSize + viewSize / 2).toString();
    const verticalPosition = (-label.y * gridSize + viewSize / 2).toString();

    let labelTransform = `translate(${
      label.horizontal_offset
    }, ${-label.vertical_offset}) rotate(${
      label.rotation
    }, ${horizontalPosition}, ${verticalPosition})`;

    return {
      id: label.id,
      type: "text",
      label: label.text.split("\n"),
      labelTransform: labelTransform,
      labelFontSize: label.size,
      labelFontWeight: label.weight,
      labelFontFamily: label.family,
      labelFontStyle: label.style,
      labelX: horizontalPosition,
      labelY: verticalPosition,
      labelColor: label.color,
    };
  }

  $: existingIntraMapLinkText =
    mapSelected && links != undefined && areasMap != undefined
      ? buildExistingIntraMapLinkText()
      : [];

  // Labels for all of the links within a single map
  function buildExistingIntraMapLinkText() {
    return links
      .filter((link) => {
        return (
          link.id != "" &&
          link.label != "" &&
          link.id != linkUnderConstruction.id &&
          areasMap[link.toId] != undefined &&
          areasMap[link.fromId] != undefined &&
          areasMap[link.fromId].mapId == chosenMap.id &&
          areasMap[link.fromId].mapId == areasMap[link.toId].mapId
        );
      })
      .map((link) => {
        return buildLabelFromLink(
          link,
          areasMap[link.fromId].mapX,
          areasMap[link.fromId].mapY,
          areasMap[link.toId].mapX,
          areasMap[link.toId].mapY
        );
      });
  }

  $: newIntraMapLinkText =
    mapSelected &&
    links != undefined &&
    areasMap != undefined &&
    buildingLink &&
    linkUnderConstruction != undefined
      ? buildNewIntraMapLinkText()
      : [];

  // Labels for the link under construction within a map
  function buildNewIntraMapLinkText() {
    return [linkUnderConstruction]
      .filter((link) => {
        return (
          buildingLink &&
          link.label != "" &&
          areasMap[link.toId] != undefined &&
          areasMap[link.fromId] != undefined &&
          areasMap[link.fromId].mapId == chosenMap.id &&
          areasMap[link.fromId].mapId == areasMap[link.toId].mapId
        );
      })
      .map((link) => {
        return buildLabelFromLink(
          link,
          areasMap[link.fromId].mapX,
          areasMap[link.fromId].mapY,
          areasMap[link.toId].mapX,
          areasMap[link.toId].mapY
        );
      });
  }

  $: newInterMapLinkText =
    mapSelected &&
    links != undefined &&
    allAreasMap != undefined &&
    linkUnderConstruction != undefined &&
    buildingLink
      ? buildNewInterMapLinkText()
      : [];

  // Labels for all of the links within a single map
  function buildNewInterMapLinkText() {
    return [linkUnderConstruction]
      .filter((link) => {
        return (
          (link.localToLabel != "" || link.localFromLabel != "") &&
          allAreasMap[link.toId] != undefined &&
          allAreasMap[link.fromId] != undefined &&
          allAreasMap[link.fromId].mapId != allAreasMap[link.toId].mapId &&
          ((allAreasMap[link.fromId].mapId == chosenMap.id &&
            link.localToLabel != "") ||
            (allAreasMap[link.toId].mapId == chosenMap.id &&
              link.localFromLabel != ""))
        );
      })
      .map((link) => {
        const modifiedLink = { ...link };
        let fromX;
        let fromY;
        let toX;
        let toY;

        // incoming
        if (allAreasMap[link.toId].mapId == chosenMap.id) {
          modifiedLink.label = link.localFromLabel;
          modifiedLink.labelFontSize = link.localFromLabelFontSize;
          modifiedLink.labelHorizontalOffset =
            link.localFromLabelHorizontalOffset;
          modifiedLink.labelVerticalOffset = link.localFromLabelVerticalOffset;
          modifiedLink.labelRotation = link.localFromLabelRotation;
          modifiedLink.labelColor = link.localFromLabelColor;
          fromX = link.localFromX;
          fromY = link.localFromY;
          toX = allAreasMap[link.toId].mapX;
          toY = allAreasMap[link.toId].mapY;
        } else {
          modifiedLink.label = link.localToLabel;
          modifiedLink.labelFontSize = link.localToLabelFontSize;
          modifiedLink.labelHorizontalOffset =
            link.localToLabelHorizontalOffset;
          modifiedLink.labelVerticalOffset = link.localToLabelVerticalOffset;
          modifiedLink.labelRotation = link.localToLabelRotation;
          modifiedLink.labelColor = link.localToLabelColor;
          toX = link.localToX;
          toY = link.localToY;
          fromX = allAreasMap[link.fromId].mapX;
          fromY = allAreasMap[link.fromId].mapY;
        }

        return buildLabelFromLink(modifiedLink, fromX, fromY, toX, toY);
      });
  }

  $: existingInterMapLinkText =
    mapSelected &&
    links != undefined &&
    allAreasMap != undefined &&
    linkUnderConstruction != undefined
      ? buildExistingInterMapLinkText()
      : [];

  // Labels for all of the links within a single map
  function buildExistingInterMapLinkText() {
    return links
      .filter((link) => {
        return (
          link.id != "" &&
          link.id != linkUnderConstruction.id &&
          (link.localToLabel != "" || link.localFromLabel != "") &&
          allAreasMap[link.toId] != undefined &&
          allAreasMap[link.fromId] != undefined &&
          allAreasMap[link.fromId].mapId != allAreasMap[link.toId].mapId &&
          ((allAreasMap[link.fromId].mapId == chosenMap.id &&
            link.localToLabel != "") ||
            (allAreasMap[link.toId].mapId == chosenMap.id &&
              link.localFromLabel != ""))
        );
      })
      .map((link) => {
        const modifiedLink = { ...link };
        let fromX;
        let fromY;
        let toX;
        let toY;

        // incoming
        if (allAreasMap[link.toId].mapId == chosenMap.id) {
          modifiedLink.label = link.localFromLabel;
          modifiedLink.labelFontSize = link.localFromLabelFontSize;
          modifiedLink.labelHorizontalOffset =
            link.localFromLabelHorizontalOffset;
          modifiedLink.labelVerticalOffset = link.localFromLabelVerticalOffset;
          modifiedLink.labelRotation = link.localFromLabelRotation;
          modifiedLink.labelColor = link.localFromLabelColor;
          fromX = link.localFromX;
          fromY = link.localFromY;
          toX = allAreasMap[link.toId].mapX;
          toY = allAreasMap[link.toId].mapY;
        } else {
          modifiedLink.label = link.localToLabel;
          modifiedLink.labelFontSize = link.localToLabelFontSize;
          modifiedLink.labelHorizontalOffset =
            link.localToLabelHorizontalOffset;
          modifiedLink.labelVerticalOffset = link.localToLabelVerticalOffset;
          modifiedLink.labelRotation = link.localToLabelRotation;
          modifiedLink.labelColor = link.localToLabelColor;
          toX = link.localToX;
          toY = link.localToY;
          fromX = allAreasMap[link.fromId].mapX;
          fromY = allAreasMap[link.fromId].mapY;
        }

        return buildLabelFromLink(modifiedLink, fromX, fromY, toX, toY);
      });
  }

  function buildLabelFromLink(link, fromX, fromY, toX, toY) {
    const gridSize = chosenMap.gridSize;
    const viewSize = chosenMap.viewSize;

    const horizontalPosition = (
      ((fromX + toX) / 2) * gridSize +
      viewSize / 2
    ).toString();
    const verticalPosition = (
      -((fromY + toY) / 2) * gridSize +
      viewSize / 2
    ).toString();

    let labelTransform = `translate(${
      link.labelHorizontalOffset
    }, ${-link.labelVerticalOffset}) rotate(${
      link.labelRotation
    }, ${horizontalPosition}, ${verticalPosition})`;

    return {
      id: `${link.id}-text`,
      type: "text",
      link: link,
      label: link.label.split("\n"),
      labelTransform: labelTransform,
      labelFontSize: link.labelFontSize,
      labelX: horizontalPosition,
      labelY: verticalPosition,
      labelColor: link.labelColor,
    };
  }

  $: existingIntraMapLinksForAreaUnderConstruction =
    mapSelected &&
    links != undefined &&
    areasMap != undefined &&
    linkUnderConstruction != undefined &&
    areaUnderConstruction != undefined
      ? buildExistingIntraMapLinksForAreaUnderConstruction()
      : [];

  // These are your already existing links between areas, within a single map. One or more of them could be highlighted.
  function buildExistingIntraMapLinksForAreaUnderConstruction() {
    return links
      .filter((link) => {
        return (
          link.id != "" &&
          link.id != linkUnderConstruction.id &&
          areasMap[link.toId] != undefined &&
          areasMap[link.fromId] != undefined &&
          areasMap[link.fromId].mapId == chosenMap.id &&
          areasMap[link.fromId].mapId == areasMap[link.toId].mapId &&
          (link.fromId == areaUnderConstruction.id ||
            link.toId == areaUnderConstruction.id)
        );
      })
      .map((link) => {
        const fromArea =
          link.fromId == areaUnderConstruction.id
            ? areaUnderConstruction
            : areasMap[link.fromId];
        const toArea =
          link.toId == areaUnderConstruction.id
            ? areaUnderConstruction
            : areasMap[link.toId];
        return buildPathFromLink(
          link,
          fromArea.mapX,
          fromArea.mapY,
          toArea.mapX,
          toArea.mapY
        );
      });
  }

  $: existingIntraMapLinks =
    mapSelected &&
    links != undefined &&
    areasMap != undefined &&
    linkUnderConstruction != undefined &&
    areaUnderConstruction != undefined
      ? buildExistingIntraMapLinks()
      : [];

  // These are your already existing links between areas, within a single map. One or more of them could be highlighted.
  function buildExistingIntraMapLinks() {
    return links
      .filter((link) => {
        return (
          link.id != "" &&
          link.id != linkUnderConstruction.id &&
          areasMap[link.toId] != undefined &&
          areasMap[link.fromId] != undefined &&
          areasMap[link.fromId].mapId == chosenMap.id &&
          areasMap[link.fromId].mapId == areasMap[link.toId].mapId &&
          link.fromId != areaUnderConstruction.id &&
          link.toId != areaUnderConstruction.id
        );
      })
      .map((link) => {
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
    buildingLink &&
    areasMap != undefined &&
    linkUnderConstruction != undefined
      ? buildNewIntraMapLinks()
      : [];

  // These links, though per current design it is only ever one, are under construction and are being displayed as a preview
  function buildNewIntraMapLinks() {
    return [linkUnderConstruction]
      .filter((link) => {
        return (
          areasMap[link.toId] != undefined &&
          areasMap[link.fromId] != undefined &&
          areasMap[link.fromId].mapId == chosenMap.id &&
          areasMap[link.fromId].mapId == areasMap[link.toId].mapId
        );
      })
      .map((link) => {
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
    mapSelected && links != undefined && allAreasMap != undefined
      ? buildExistingInterMapLinks()
      : [];

  // These are your already existing links between rooms, within a single map. One or more of them could be highlighted.
  function buildExistingInterMapLinks() {
    return links
      .filter((link) => {
        return (
          link.id != "" &&
          allAreasMap[link.toId] != undefined &&
          allAreasMap[link.fromId] != undefined &&
          allAreasMap[link.fromId].mapId != allAreasMap[link.toId].mapId &&
          (allAreasMap[link.fromId].mapId == chosenMap.id ||
            allAreasMap[link.toId].mapId == chosenMap.id)
        );
      })
      .map((link) => {
        return buildInterMapLink(link);
      });
  }

  $: newInterMapLinks =
    mapSelected &&
    chosenMap != undefined &&
    buildingLink &&
    allAreasMap != undefined &&
    linkUnderConstruction != undefined
      ? buildNewInterMapLinks()
      : [];

  // These are your already existing links between rooms, between maps. One or more of them could be highlighted.
  function buildNewInterMapLinks() {
    return [linkUnderConstruction]
      .filter((link) => {
        return (
          allAreasMap[link.toId] != undefined &&
          allAreasMap[link.fromId] != undefined &&
          allAreasMap[link.fromId].mapId != allAreasMap[link.toId].mapId &&
          (allAreasMap[link.fromId].mapId != chosenMap.id ||
            allAreasMap[link.toId].mapId != chosenMap.id)
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
    const toArea =
      areaUnderConstruction.id == link.toId
        ? areaUnderConstruction
        : allAreasMap[link.toId];
    const fromArea =
      areaUnderConstruction.id == link.fromId
        ? areaUnderConstruction
        : allAreasMap[link.fromId];

    // incoming
    if (toArea.mapId == chosenMap.id) {
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
      toX = toArea.mapX;
      toY = toArea.mapY;
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
      fromX = fromArea.mapX;
      fromY = fromArea.mapY;
    }

    return buildPathFromLink(link, fromX, fromY, toX, toY);
  }

  $: newInterMapLinkAreas =
    mapSelected &&
    links != undefined &&
    allAreasMap != undefined &&
    linkUnderConstruction != undefined
      ? buildNewInterMapLinkAreas()
      : [];

  // These are the areas being linked to that exist outside the map. A local representation of the area needs to be
  // built from the link
  function buildNewInterMapLinkAreas() {
    return [linkUnderConstruction]
      .filter((link) => {
        return (
          buildingLink &&
          allAreasMap[link.toId] != undefined &&
          allAreasMap[link.fromId] != undefined &&
          allAreasMap[link.fromId].mapId != allAreasMap[link.toId].mapId &&
          (allAreasMap[link.fromId].mapId == chosenMap.id ||
            allAreasMap[link.toId].mapId == chosenMap.id)
        );
      })
      .map((link) => {
        // Build up an area from the link and display that
        const generatedArea = { ...AreaState };
        generatedArea.id = "InterMapLinkAreaPreview";

        // incoming link
        if (allAreasMap[link.toId].mapId == chosenMap.id) {
          generatedArea.color = link.localFromColor;
          generatedArea.borderColor = link.localFromBorderColor;
          generatedArea.borderWidth = link.localFromBorderWidth;
          generatedArea.mapCorners = link.localFromCorners;
          generatedArea.mapSize = link.localFromSize;
          generatedArea.mapX = link.localFromX;
          generatedArea.mapY = link.localFromY;
          generatedArea.name = `${
            mapsMap[allAreasMap[link.fromId].mapId].name
          }, ${allAreasMap[link.fromId].name} (${link.localFromX},${
            link.localFromY
          })`;
        } else if (allAreasMap[link.fromId].mapId == chosenMap.id) {
          generatedArea.color = link.localToColor;
          generatedArea.borderColor = link.localToBorderColor;
          generatedArea.borderWidth = link.localToBorderWidth;
          generatedArea.mapCorners = link.localToCorners;
          generatedArea.mapSize = link.localToSize;
          generatedArea.mapX = link.localToX;
          generatedArea.mapY = link.localToY;
          generatedArea.name = `${
            mapsMap[allAreasMap[link.toId].mapId].name
          }, ${allAreasMap[link.toId].name} (${link.localToX},${
            link.localToY
          })`;
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

      if (
        link != undefined &&
        link.toId != "" &&
        link.fromId != "" &&
        areasMap[link.toId].mapId == areasMap[link.fromId].mapId &&
        areasMap[link.toId].mapId == chosenMap.id
      ) {
        link.lineColor = highlightColor;
        link.lineWidth = link.lineWidth + 6;
        link.label = "";
        link.hasMarker = false;

        return buildPathFromLink(
          link,
          areasMap[link.fromId].mapX,
          areasMap[link.fromId].mapY,
          areasMap[link.toId].mapX,
          areasMap[link.toId].mapY
        );
      } else {
        return [];
      }
    });
  }

  $: highlightsForExistingInterMapLinks =
    mapSelected && allAreasMap != undefined && highlightedLinkIds.length > 0
      ? buildHighlightsForExistingInterMapLinks()
      : [];

  function buildHighlightsForExistingInterMapLinks() {
    return highlightedLinkIds.map((linkId) => {
      const link = { ...links.find((link) => link.id == linkId) };

      if (
        link != undefined &&
        link.toId != "" &&
        link.fromId != "" &&
        allAreasMap[link.toId].mapId != allAreasMap[link.fromId].mapId &&
        (allAreasMap[link.toId].mapId == chosenMap.id ||
          allAreasMap[link.fromId].mapId == chosenMap.id)
      ) {
        link.lineColor = highlightColor;
        link.hasMarker = false;
        let x1;
        let y1;
        let x2;
        let y2;

        // incoming
        if (areasMap[link.toId].mapId == chosenMap.id) {
          link.lineWidth = link.localFromLineWidth;
          link.lineDash = link.localFromLineDash;

          x1 = link.localFromX;
          y1 = link.localFromY;
          x2 = allAreasMap[link.toId].mapX;
          y2 = allAreasMap[link.toId].mapY;
        } else {
          link.lineWidth = link.localToLineWidth;
          link.lineDash = link.localToLineDash;

          x2 = link.localToX;
          y2 = link.localToY;
          x1 = allAreasMap[link.fromId].mapX;
          y1 = allAreasMap[link.fromId].mapY;
        }

        link.lineColor = highlightColor;
        link.lineWidth = link.lineWidth + 6;

        return buildPathFromLink(link, x1, y1, x2, y2);
      } else {
        return [];
      }
    });
  }

  function buildPathFromLink(link, fromX, fromY, toX, toY) {
    const gridSize = chosenMap.gridSize;
    const viewSize = chosenMap.viewSize;

    // const horizontalPosition = ((fromX + toX) / 2).toString();
    // const verticalPosition = ((fromY + toY) / 2).toString();

    // const result = {
    return {
      id: link.id,
      type: "path",
      x1: fromX * gridSize + viewSize / 2,
      y1: -fromY * gridSize + viewSize / 2,
      x2: toX * gridSize + viewSize / 2,
      y2: -toY * gridSize + viewSize / 2,
      link: link,
      // label: link.label.split("\n"),
      // labelTransform: labelTransform,
      // labelFontSize: link.labelFontSize,
      // labelX: horizontalPosition,
      // labelY: verticalPosition,
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

    // if (highlightedLinkIds.includes(link.id)) {
    //   const duplicateResults = {
    //     ...result,
    //     ...{
    //       lineColor: "#FF6600",
    //       lineWidth: result.lineWidth + 6,
    //       label: "",
    //       hasMarker: false,
    //       id: `${link.id}-duplicate`,
    //     },
    //   };

    //   return [duplicateResults, result];
    // } else {
    //   return [result];
    // }
  }

  // Current implementation is only ever one being constructed at a time
  $: newIntraMapAreas =
    areaUnderConstruction != undefined &&
    buildingArea == true &&
    chosenMap != undefined &&
    svgMapAllowIntraMapAreaSelection != undefined &&
    svgMapAllowInterMapAreaSelection != undefined
      ? buildNewIntraMapAreas()
      : [];

  function buildNewIntraMapAreas() {
    return [areaUnderConstruction]
      .filter((area) => {
        return buildingArea == true && area.mapId == chosenMap.id;
      })
      .map((area) => {
        return buildRectFromArea(area);
      });
  }

  $: existingIntraMapAreas =
    mapSelected &&
    areas != undefined &&
    areasMap != undefined &&
    svgMapAllowIntraMapAreaSelection != undefined &&
    svgMapAllowInterMapAreaSelection != undefined
      ? buildExistingIntraMapAreas()
      : [];

  function buildExistingIntraMapAreas() {
    return areas
      .filter((area) => {
        return (
          area.id != "" &&
          areasMap[area.id] != undefined &&
          area.mapId == chosenMap.id &&
          area.id != areaUnderConstruction.id
        );
      })
      .map((area) => {
        return buildRectFromArea(area);
      });
  }

  $: highlightsForNewIntraMapAreas =
    mapSelected && areasMap != undefined && areaUnderConstruction.id != ""
      ? buildHighlightsForNewIntraMapAreas()
      : [];

  function buildHighlightsForNewIntraMapAreas() {
    const area = { ...areaUnderConstruction };
    area.mapSize = area.mapSize + 3;
    area.borderColor = highlightColor;
    area.color = highlightColor;
    area.borderWidth = Math.max(3, area.borderWidth + 1);
    area.id = `${area.id}-highlight`;

    return [buildRectFromArea(area)];
  }

  $: highlightsForExistingIntraMapAreas =
    mapSelected && areasMap != undefined && highlightedAreaIds.length > 0
      ? buildHighlightsForExistingIntraMapAreas()
      : [];

  function buildHighlightsForExistingIntraMapAreas() {
    return highlightedAreaIds
      .filter((areaId) => {
        return (
          areasMap[areaId] != undefined &&
          areasMap[areaId].mapId == chosenMap.id &&
          areaId != areaUnderConstruction.id
        );
      })
      .map((areaId) => {
        const area = { ...areasMap[areaId] };
        area.mapSize = area.mapSize + 3;
        area.borderColor = highlightColor;
        area.color = highlightColor;
        area.borderWidth = Math.max(3, area.borderWidth + 1);
        area.id = `${area.id}-highlight`;

        return buildRectFromArea(area);
      });
  }

  function buildRectFromArea(area) {
    let cls = svgMapAllowIntraMapAreaSelection
      ? "cursor-pointer"
      : "cursor-auto";

    const x = localToMapCoordinate(area.mapX) - area.mapSize / 2;

    const y = localToMapCoordinate(-area.mapY) - area.mapSize / 2;

    return {
      id: area.id,
      type: "rect",
      x: x,
      y: y,
      width: area.mapSize,
      height: area.mapSize,
      corners: area.mapCorners,
      fill: area.color,
      name: `${area.name} (${area.mapX},${-area.mapY})`,
      area: area,
      cls: cls,
      borderColor: area.borderColor,
      borderWidth: area.borderWidth,
    };
  }

  $: existingInterMapAreas =
    mapSelected &&
    areas != undefined &&
    links != undefined &&
    allAreasMap != undefined &&
    chosenMap != undefined &&
    mapsMap != undefined &&
    svgMapAllowIntraMapAreaSelection != undefined &&
    svgMapAllowInterMapAreaSelection != undefined
      ? buildExistingInterMapAreas()
      : [];

  function buildExistingInterMapAreas() {
    return areas
      .filter((area) => {
        return (
          area.id != "" &&
          allAreasMap[area.id] != undefined &&
          area.mapId != chosenMap.id
        );
      })
      .map((area) => {
        const modifiedArea = { ...area };

        // find a link which points to this other area in this other map
        // overwrite area settings with 'local' settings from link and then build
        const link = links.find(
          (link) => link.toId == area.id || link.fromId == area.id
        );

        // Sometimes there is a race condition when loading things
        // This makes sure the link has been populated
        if (link == undefined) {
          return [];
        }

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

          modifiedArea.name = `${mapsMap[allAreasMap[link.toId].mapId].name}, ${
            allAreasMap[link.toId].name
          }`;
        } else {
          modifiedArea.mapSize = link.localFromSize;
          modifiedArea.mapCorners = link.localFromCorners;
          modifiedArea.color = link.localFromColor;

          modifiedArea.borderColor = link.localFromBorderColor;
          modifiedArea.borderWidth = link.localFromBorderWidth;

          modifiedArea.mapX = link.localFromX;
          modifiedArea.mapY = link.localFromY;

          modifiedArea.name = `${
            mapsMap[allAreasMap[link.fromId].mapId].name
          }, ${allAreasMap[link.fromId].name}`;
        }

        return buildRectFromArea(modifiedArea);
      });
  }

  function handleStartDragMap() {
    WorldBuilderStore.setMapManuallyScrolled(true);
  }

  function handleDragMap(event) {
    WorldBuilderStore.scrollMapByDelta(event.detail);
  }

  function handleSelectArea(event) {
    
    if (
      (svgMapAllowIntraMapAreaSelection &&
      event.detail.mapId == chosenMap.id) ||
      (svgMapAllowInterMapAreaSelection && event.detail.mapId != chosenMap.id)
      ) {
      WorldBuilderStore.setMapManuallyScrolled(false);
      WorldBuilderStore.selectArea(event.detail);
    }
  }
</script>

<div
  bind:clientWidth={svgWrapperWidth}
  bind:clientHeight={svgWrapperHeight}
  class="p-1 h-full w-full max-w-full max-h-full flex flex-col {mapSelected
    ? ''
    : 'place-content-center'}"
>
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
          showGrid={true}
          shapes={[
            ...highlightsForExistingIntraMapLinks,
            ...highlightsForExistingInterMapLinks,
            ...highlightsForExistingIntraMapAreas,
            ...highlightsForNewIntraMapAreas,
            ...existingIntraMapLinksForAreaUnderConstruction,
            ...existingIntraMapLinks,
            ...existingInterMapLinks,
            ...newIntraMapLinks,
            ...newInterMapLinks,
            ...existingIntraMapAreas,
            ...existingInterMapAreas,
            ...newInterMapLinkAreas,
            ...newIntraMapAreas,
            ...existingIntraMapLinkText,
            ...existingInterMapLinkText,
            ...newIntraMapLinkText,
            ...newInterMapLinkText,
            ...existingMapLabels,
            ...newMapLabels,
          ].flat(2)}
          on:dragMap={handleStartDragMap}
          on:dragMap={handleDragMap}
          on:selectArea={handleSelectArea}
        />
      </div>
    {/if}
  {:else}
    <p class="text-gray-300 text-center">Select a map</p>
  {/if}
</div>
