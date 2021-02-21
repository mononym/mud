<script lang="ts">
  import Svg from "../Svg.svelte";

  // It needs a list of all areas and maps because it needs to extract names

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

  // All of the areas that the character knows about
  export let exploredAreas = [];

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

  // An array of all of the areas which should be highlighted. For example an area that is focused on may or may not be highlighted.
  export let highlightedAreaIds = [];

  // An array of all of the links which should be highlighted. For example a link that is selected may or may not be highlighted.
  export let highlightedLinkIds = [];

  // Controls display and code behavior when it comes to selecting different types of areas
  export let svgMapAllowIntraMapAreaSelection = false;
  export let svgMapAllowInterMapAreaSelection = false;

  export let zoomMultiplier = 1;

  export let mapSettings = <Record<string, string>>{};

  const highlightColor = "#ff6600";

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
  $: viewBoxXSize = chosenMap.viewSize * zoomMultiplier;
  $: viewBoxYSize = Math.max(
    chosenMap.viewSize *
      (svgWrapperWidth / (svgWrapperHeight - 64)) *
      zoomMultiplier,
    0
  );
  $: viewBoxX = xCenterPoint - viewBoxXSize / 2;
  $: viewBoxY = yCenterPoint - viewBoxYSize / 2;
  $: viewBox = `${viewBoxX} ${viewBoxY} ${viewBoxXSize} ${viewBoxYSize}`;

  $: existingMapLabels =
    mapSelected && chosenMap != undefined ? buildExistingMapLabels() : [];

  // Labels for all of the labels within a single map
  function buildExistingMapLabels() {
    return chosenMap.labels.map((label) => {
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
    mapSelected &&
    chosenMap != undefined &&
    links != undefined &&
    areasMap != undefined &&
    exploredAreas != undefined
      ? buildExistingIntraMapLinkText()
      : [];

  // Labels for all of the links within a single map
  function buildExistingIntraMapLinkText() {
    console.log("buildExistingIntraMapLinkText");
    return links
      .filter((link) => {
        return (
          link.id != "" &&
          link.label != "" &&
          areasMap[link.toId] != undefined &&
          areasMap[link.fromId] != undefined &&
          areasMap[link.fromId].mapId == chosenMap.id &&
          areasMap[link.fromId].mapId == areasMap[link.toId].mapId &&
          exploredAreas.includes(link.toId) &&
          exploredAreas.includes(link.fromId)
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

  $: existingInterMapLinkText =
    mapSelected &&
    links != undefined &&
    areasMap != undefined &&
    chosenMap != undefined &&
    exploredAreas != undefined
      ? buildExistingInterMapLinkText()
      : [];

  // Labels for all of the links within a single map
  function buildExistingInterMapLinkText() {
    console.log("buildExistingInterMapLinkText");
    return links
      .filter((link) => {
        return (
          link.id != "" &&
          (link.localToLabel != "" || link.localFromLabel != "") &&
          areasMap[link.toId] != undefined &&
          areasMap[link.fromId] != undefined &&
          areasMap[link.fromId].mapId != areasMap[link.toId].mapId &&
          ((areasMap[link.fromId].mapId == chosenMap.id &&
            link.localToLabel != "") ||
            (areasMap[link.toId].mapId == chosenMap.id &&
              link.localFromLabel != "")) &&
          exploredAreas.includes(link.toId) &&
          exploredAreas.includes(link.fromId)
        );
      })
      .map((link) => {
        const modifiedLink = { ...link };
        let fromX;
        let fromY;
        let toX;
        let toY;

        // incoming
        if (areasMap[link.toId].mapId == chosenMap.id) {
          modifiedLink.label = link.localFromLabel;
          modifiedLink.labelFontSize = link.localFromLabelFontSize;
          modifiedLink.labelHorizontalOffset =
            link.localFromLabelHorizontalOffset;
          modifiedLink.labelVerticalOffset = link.localFromLabelVerticalOffset;
          modifiedLink.labelRotation = link.localFromLabelRotation;
          modifiedLink.labelColor = link.localFromLabelColor;
          fromX = link.localFromX;
          fromY = link.localFromY;
          toX = areasMap[link.toId].mapX;
          toY = areasMap[link.toId].mapY;
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
          fromX = areasMap[link.fromId].mapX;
          fromY = areasMap[link.fromId].mapY;
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

  $: existingUnexploredIntraMapLinks =
    mapSelected &&
    links != undefined &&
    areasMap != undefined &&
    chosenMap != undefined &&
    exploredAreas != undefined
      ? buildExistingUnexploredIntraMapLinks()
      : [];

  // These are your already existing links between rooms, within a single map. One or more of them could be highlighted.
  function buildExistingUnexploredIntraMapLinks() {
    console.log("buildExistingIntraMapLinks");
    console.log(exploredAreas);

    return links
      .filter((link) => {
        return (
          link.id != "" &&
          areasMap[link.toId] != undefined &&
          areasMap[link.fromId] != undefined &&
          areasMap[link.fromId].mapId == chosenMap.id &&
          areasMap[link.fromId].mapId == areasMap[link.toId].mapId &&
          exploredAreas.includes(link.fromId) &&
          !exploredAreas.includes(link.toId)
        );
      })
      .map((link) => {
        return buildUnexploredPathFromLink(
          link,
          areasMap[link.fromId].mapX,
          areasMap[link.fromId].mapY,
          areasMap[link.toId].mapX,
          areasMap[link.toId].mapY
        );
      });
  }

  $: existingUnexploredInterMapLinks =
    mapSelected &&
    links != undefined &&
    areasMap != undefined &&
    chosenMap != undefined &&
    exploredAreas != undefined
      ? buildExistingUnexploredInterMapLinks()
      : [];

  function buildExistingUnexploredInterMapLinks() {
    return links
      .filter((link) => {
        return (
          link.id != "" &&
          areasMap[link.toId] != undefined &&
          areasMap[link.fromId] != undefined &&
          areasMap[link.fromId].mapId != areasMap[link.toId].mapId &&
          areasMap[link.fromId].mapId == chosenMap.id &&
          !exploredAreas.includes(link.toId) &&
          exploredAreas.includes(link.fromId)
        );
      })
      .map((link) => {
        return buildUnexploredPathFromLink(
          link,
          areasMap[link.fromId].mapX,
          areasMap[link.fromId].mapY,
          link.localToX,
          link.localToY
        );
      });
  }

  $: existingIntraMapLinks =
    mapSelected &&
    links != undefined &&
    areasMap != undefined &&
    chosenMap != undefined &&
    exploredAreas != undefined
      ? buildExistingIntraMapLinks()
      : [];

  // These are your already existing links between rooms, within a single map. One or more of them could be highlighted.
  function buildExistingIntraMapLinks() {
    console.log("buildExistingIntraMapLinks");
    return links
      .filter((link) => {
        return (
          link.id != "" &&
          areasMap[link.toId] != undefined &&
          areasMap[link.fromId] != undefined &&
          areasMap[link.fromId].mapId == chosenMap.id &&
          areasMap[link.fromId].mapId == areasMap[link.toId].mapId &&
          exploredAreas.includes(link.toId) &&
          exploredAreas.includes(link.fromId)
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
    mapSelected &&
    links != undefined &&
    areasMap != undefined &&
    chosenMap != undefined &&
    exploredAreas != undefined
      ? buildExistingInterMapLinks()
      : [];

  // These are your already existing links between rooms, within a single map. One or more of them could be highlighted.
  function buildExistingInterMapLinks() {
    return links
      .filter((link) => {
        return (
          link.id != "" &&
          areasMap[link.toId] != undefined &&
          areasMap[link.fromId] != undefined &&
          areasMap[link.fromId].mapId != areasMap[link.toId].mapId &&
          (areasMap[link.fromId].mapId == chosenMap.id ||
            areasMap[link.toId].mapId == chosenMap.id) &&
          exploredAreas.includes(link.toId) &&
          exploredAreas.includes(link.fromId)
        );
      })
      .map((link) => {
        return buildInterMapLink(link);
      });
  }

  function buildInterMapLink(link) {
    console.log("buildInterMapLink");
    const modifiedLink = buildModifiedLocalLink(link);
    let toX;
    let toY;
    let fromX;
    let fromY;

    // incoming
    if (areasMap[link.toId].mapId == chosenMap.id) {
      fromX = link.localFromX;
      fromY = link.localFromY;
      toX = areasMap[link.toId].mapX;
      toY = areasMap[link.toId].mapY;
    } else {
      toX = link.localToX;
      toY = link.localToY;
      fromX = areasMap[link.fromId].mapX;
      fromY = areasMap[link.fromId].mapY;
    }

    return buildPathFromLink(link, fromX, fromY, toX, toY);
  }

  function buildModifiedLocalLink(link) {
    const modifiedLink = { ...link };

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
    }

    return modifiedLink;
  }

  $: highlightsForExistingIntraMapLinks =
    mapSelected &&
    areasMap != undefined &&
    chosenMap != undefined &&
    highlightedLinkIds.length > 0
      ? buildHighlightsForExistingIntraMapLinks()
      : [];

  function buildHighlightsForExistingIntraMapLinks() {
    console.log("buildHighlightsForExistingIntraMapLinks");
    return highlightedLinkIds.map((linkId) => {
      const link = { ...links.find((link) => link.id == linkId) };

      if (
        link != undefined &&
        link.toId != "" &&
        link.fromId != "" &&
        areasMap[link.toId] != undefined &&
        areasMap[link.fromId].mapId != undefined &&
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
    mapSelected &&
    areasMap != undefined &&
    chosenMap != undefined &&
    highlightedLinkIds.length > 0
      ? buildHighlightsForExistingInterMapLinks()
      : [];

  function buildHighlightsForExistingInterMapLinks() {
    console.log("buildHighlightsForExistingInterMapLinks");
    return highlightedLinkIds.map((linkId) => {
      const link = { ...links.find((link) => link.id == linkId) };

      if (
        link != undefined &&
        link.toId != "" &&
        link.fromId != "" &&
        areasMap[link.toId].mapId != areasMap[link.fromId].mapId &&
        (areasMap[link.toId].mapId == chosenMap.id ||
          areasMap[link.fromId].mapId == chosenMap.id)
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
          x2 = areasMap[link.toId].mapX;
          y2 = areasMap[link.toId].mapY;
        } else {
          link.lineWidth = link.localToLineWidth;
          link.lineDash = link.localToLineDash;

          x2 = link.localToX;
          y2 = link.localToY;
          x1 = areasMap[link.fromId].mapX;
          y1 = areasMap[link.fromId].mapY;
        }

        link.lineColor = highlightColor;
        link.lineWidth = link.lineWidth + 6;

        return buildPathFromLink(link, x1, y1, x2, y2);
      } else {
        return [];
      }
    });
  }

  function buildUnexploredPathFromLink(link, fromX, fromY, toX, toY) {
    const gridSize = chosenMap.gridSize;
    const viewSize = chosenMap.viewSize;

    let x1 = fromX * gridSize + viewSize / 2;
    let y1 = -fromY * gridSize + viewSize / 2;
    let x2 = toX * gridSize + viewSize / 2;
    let y2 = -toY * gridSize + viewSize / 2;
    let distanceBetweenEndPoints = Math.sqrt(
      Math.pow(x2 - x1, 2) + Math.pow(y2 - y1, 2)
    );
    let desiredDistance = gridSize * 0.5;

    let x3 = x1 + (desiredDistance / distanceBetweenEndPoints) * (x2 - x1);
    let y3 = y1 + (desiredDistance / distanceBetweenEndPoints) * (y2 - y1);

    return {
      id: link.id,
      type: "path",
      x1: fromX * gridSize + viewSize / 2,
      y1: -fromY * gridSize + viewSize / 2,
      x2: x3,
      y2: y3,
      link: link,
      lineWidth: link.lineWidth,
      lineColor: mapSettings.unexplored_link_color,
      lineDash: link.lineDash,
      labelColor: mapSettings.unexplored_link_color,
      hasMarker: false,
      markerOffset: link.markerOffset,
      markerColor: mapSettings.unexplored_link_color,
      markerWidth: link.lineWidth * 3,
      markerHeight: link.lineWidth * 3,
    };
  }

  function buildPathFromLink(link, fromX, fromY, toX, toY) {
    const gridSize = chosenMap.gridSize;
    const viewSize = chosenMap.viewSize;

    return {
      id: link.id,
      type: "path",
      x1: fromX * gridSize + viewSize / 2,
      y1: -fromY * gridSize + viewSize / 2,
      x2: toX * gridSize + viewSize / 2,
      y2: -toY * gridSize + viewSize / 2,
      link: link,
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
  }

  $: existingIntraMapAreas =
    mapSelected &&
    areas != undefined &&
    areasMap != undefined &&
    chosenMap != undefined &&
    svgMapAllowIntraMapAreaSelection != undefined &&
    svgMapAllowInterMapAreaSelection != undefined &&
    exploredAreas != undefined
      ? buildExistingIntraMapAreas()
      : [];

  function buildExistingIntraMapAreas() {
    console.log("buildExistingIntraMapAreas");
    console.log(exploredAreas);
    return areas
      .filter((area) => {
        console.log({
          area: area.id,
          explored: exploredAreas.includes(area.id),
        });
        return (
          area.id != "" &&
          areasMap[area.id] != undefined &&
          area.mapId == chosenMap.id &&
          exploredAreas.includes(area.id)
        );
      })
      .map((area) => {
        return buildRectFromArea(area);
      });
  }

  $: highlightsForExistingIntraMapAreas =
    mapSelected &&
    areasMap != undefined &&
    chosenMap != undefined &&
    highlightedAreaIds.length > 0 &&
    exploredAreas != undefined
      ? buildHighlightsForExistingIntraMapAreas()
      : [];

  function buildHighlightsForExistingIntraMapAreas() {
    return highlightedAreaIds
      .filter((areaId) => {
        return (
          areasMap[areaId] != undefined &&
            areasMap[areaId].mapId == chosenMap.id,
          exploredAreas.includes(areaId)
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
    console.log("buildRectFromArea");
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
    mapSelected &&
    areas != undefined &&
    links != undefined &&
    areasMap != undefined &&
    chosenMap != undefined &&
    mapsMap != undefined &&
    svgMapAllowIntraMapAreaSelection != undefined &&
    svgMapAllowInterMapAreaSelection != undefined &&
    exploredAreas != undefined
      ? buildExistingInterMapAreas()
      : [];

  function buildExistingInterMapAreas() {
    console.log("buildExistingInterMapAreas");
    return areas
      .filter((area) => {
        return (
          area.id != "" &&
          areasMap[area.id] != undefined &&
          area.mapId != chosenMap.id &&
          exploredAreas.includes(area.id)
        );
      })
      .map((area) => {
        console.log(areas);
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

          let id = areasMap[link.toId].mapId;

          if (mapsMap[id] == undefined) {
            return;
          }

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

          let id = areasMap[link.toId].mapId;

          if (mapsMap[id] == undefined) {
            return;
          }

          modifiedArea.name = `${mapsMap[areasMap[link.fromId].mapId].name}, ${
            areasMap[link.fromId].name
          }`;
        }

        return buildRectFromArea(modifiedArea);
      })
      .filter((thing) => thing != undefined);
  }

  function handleSelectArea(event) {
    if (
      (svgMapAllowIntraMapAreaSelection &&
        event.detail.mapId == chosenMap.id) ||
      (svgMapAllowInterMapAreaSelection && event.detail.mapId != chosenMap.id)
    ) {
      // TODO: Trigger the move script
      // WorldBuilderStore.selectArea(event.detail);
    }
  }
</script>

<div
  bind:offsetWidth={svgWrapperWidth}
  bind:offsetHeight={svgWrapperHeight}
  class="h-full w-full flex flex-col"
>
  <p class="flex-shrink text-gray-300 w-full text-center overflow-hidden">
    {chosenMap.name}
  </p>
  <Svg
    {viewBox}
    shapes={[
      ...highlightsForExistingIntraMapLinks,
      ...highlightsForExistingInterMapLinks,
      ...highlightsForExistingIntraMapAreas,
      ...existingIntraMapLinks,
      ...existingInterMapLinks,
      ...existingUnexploredIntraMapLinks,
      ...existingUnexploredInterMapLinks,
      ...existingIntraMapAreas,
      ...existingInterMapAreas,
      ...existingIntraMapLinkText,
      ...existingInterMapLinkText,
      ...existingMapLabels,
    ].flat(2)}
    on:selectArea={handleSelectArea}
  />
</div>
