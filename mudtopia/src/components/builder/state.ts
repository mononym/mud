import { derived, writable, get } from "svelte/store";
import type { LinkInterface } from "../../models/link";
import MapState, { MapInterface } from "../../models/map";
import MapLabelState, { MapLabelInterface } from "../../models/mapLabel";
import AreaState, { AreaInterface } from "../../models/area";
import LinkState from "../../models/link";
import { loadMapData, deleteLink as delLink } from "../../api/server";
import { AreasStore } from "../../stores/areas";
import { MapsStore } from "../../stores/maps";
import { LinksStore } from "../../stores/links";
import { tick } from "svelte";

const { mapsMap } = MapsStore;
const { areasMap } = AreasStore;
const { links, linksMap } = LinksStore;

function createWorldBuilderStore() {
  const areaUnderConstruction = writable({ ...AreaState });
  const loadingMapData = writable(false);
  const mapDataLoaded = writable(false);
  const selectedMap = writable({ ...MapState });
  const mapSelected = derived(
    selectedMap,
    ($selectedMap) => $selectedMap.id != ""
  );
  const selectedArea = writable({ ...AreaState });
  const areaSelected = derived(
    selectedArea,
    ($selectedArea) => $selectedArea.id != ""
  );

  const mapUnderConstruction = writable(<MapInterface>{ ...MapState });

  // Links stuff
  const incomingLinksForSelectedArea = derived(
    [areaSelected, selectedArea, links],
    ([$areaSelected, $selectedArea, $links]) =>
      $areaSelected
        ? $links.filter((link) => link.toId == $selectedArea.id)
        : []
  );
  const outgoingLinksForSelectedArea = derived(
    [areaSelected, selectedArea, links],
    ([$areaSelected, $selectedArea, $links]) =>
      $areaSelected
        ? $links.filter((link) => link.fromId == $selectedArea.id)
        : []
  );
  const linkEditorMapForOtherAreaId = writable("");
  const selectedLink = writable({ ...LinkState });
  const linkSelected = derived(
    selectedLink,
    ($selectedLink) => $selectedLink.id != ""
  );
  const linkUnderConstruction = writable(<LinkInterface>{ ...LinkState });

  async function loadAllMapData(mapId) {
    try {
      const res = (await loadMapData(mapId)).data;

      AreasStore.putAreas(res.areas);
      LinksStore.putLinks(res.links);
    } catch (e) {
      alert(e.message);
    }
  }

  // what do I need to manage all UI state for world builder from the store?
  // mode: map, area, link
  const mode = writable("map");
  // view: details, edit
  const view = writable("details");

  // The ID of the area for which the link is being previewed
  // This is not the area that is being linked from/to in the interface, but the 'other' area
  const linkPreviewAreaId = derived(
    [linkUnderConstruction, selectedArea],
    function ([$linkUnderConstruction, $selectedArea]) {
      if (
        $linkUnderConstruction.toId != "" &&
        $linkUnderConstruction.fromId != ""
      ) {
        if ($linkUnderConstruction.toId == $selectedArea.id) {
          return $linkUnderConstruction.fromId;
        } else {
          return $linkUnderConstruction.toId;
        }
      } else {
        return "";
      }
    }
  );

  // previewLink: boolean
  // Show a preview of a link only if a valid preview area id has been set
  const showPreviewLink = derived(
    linkPreviewAreaId,
    ($linkPreviewAreaId) => $linkPreviewAreaId != ""
  );

  async function selectMap(map: MapInterface) {
    selectedMap.set(map);
  }

  async function buildMap(map: MapInterface) {
    if (map.id != get(selectedMap).id) {
      loadAllMapData(map.id);
    }

    selectedMap.set(map);
    mode.set("area");
  }

  async function linkArea(area: AreaInterface) {
    linkEditorMapForOtherAreaId.set(area.mapId);
    linkUnderConstruction.set({ ...LinkState });
    selectedArea.set(area);
    await loadDataForLinkEditor(area.mapId);
    mode.set("link");
    view.set("edit");
  }

  async function saveLink() {
    LinksStore.saveLink(get(linkUnderConstruction));
    selectedLink.set(get(linkUnderConstruction));
    linkUnderConstruction.set({ ...LinkState });
    mode.set("area");
    view.set("details");
  }

  async function cancelLinkArea() {
    linkEditorMapForOtherAreaId.set(get(selectedMap).id);
    selectedLink.set({ ...LinkState });
    linkUnderConstruction.set({ ...LinkState });

    // if (get(linkUnderConstruction).id == '')
    // if (get(linkUnderConstruction).id != '') {}
    mode.set("area");
    view.set("details");
  }

  // Whether or not to allow for clicking on the areas within a map depends on what mode is UI is in
  const svgMapAllowIntraMapAreaSelection = derived(
    [mode, view],
    ([$mode, $view]) =>
      ($mode == "area" && $view == "details") ||
      ($mode == "link" && $view == "edit")
  );

  // Whether to allow for clicking inter map links depends on what mode is UI is in
  const svgMapAllowInterMapAreaSelection = derived(
    [mode, view],
    ([$mode, $view]) =>
      $mode == "map" ||
      ($mode == "area" && $view == "details") ||
      ($mode == "link" && $view == "edit")
  );

  // When a link is being edited, the normal set of areas should be left alone in case areas need to be looked up for linking
  const linksForLinkEditor = writable(<LinkInterface[]>[]);
  const areasForLinkEditorMap = writable(<Record<string, AreaInterface>>{});
  const areasForLinkEditor = derived(
    areasForLinkEditorMap,
    ($areasForLinkEditorMap) => Object.values($areasForLinkEditorMap)
  );
  const areasForLinkEditorFilteredMap = derived(
    areasForLinkEditor,
    ($areasForLinkEditor) =>
      $areasForLinkEditor.filter(
        (area) => area.mapId == get(linkEditorMapForOtherAreaId)
      )
  );
  const areasForLinkEditorFiltered = derived(
    areasForLinkEditorFilteredMap,
    ($areasForLinkEditorFilteredMap) =>
      Object.values($areasForLinkEditorFilteredMap)
  );
  const loadingLinkEditorData = writable(false);
  const linkEditorDataLoaded = writable(false);

  async function changeMapForLinkEditor(mapId: string) {
    if (
      get(linkUnderConstruction).toId != "" &&
      get(areasMap)[get(linkUnderConstruction).toId].mapId == mapId
    ) {
      linkUnderConstruction.update(function (luc) {
        luc.fromId = "";
        return luc;
      });
    } else {
      linkUnderConstruction.update(function (luc) {
        luc.toId = "";
        return luc;
      });
    }

    loadDataForLinkEditor(mapId);
  }

  async function loadDataForLinkEditor(mapId: string) {
    loadingLinkEditorData.set(true);
    linkEditorDataLoaded.set(false);
    let areasToMap = [];
    let newLinks = [];

    if (mapId == get(selectedMap).id) {
      areasToMap = get(AreasStore.areas);

      newLinks = get(links);
    } else {
      const res = (await loadMapData(mapId)).data;

      areasToMap = res.areas;

      newLinks = res.links;
    }

    const newAreasMap = {};
    for (var i = 0; i < areasToMap.length; i++) {
      newAreasMap[areasToMap[i].id] = areasToMap[i];
    }

    areasForLinkEditorMap.set(newAreasMap);
    linksForLinkEditor.set(newLinks);
    loadingLinkEditorData.set(false);
    linkEditorDataLoaded.set(true);
  }

  async function editMap(map: MapInterface) {
    selectedMap.set(map);
    mapUnderConstruction.set({ ...map });
    mode.set("map");
    view.set("edit");
  }

  async function createNewMap() {
    selectedMap.set({ ...MapState });
    mapUnderConstruction.set({ ...MapState });
    mode.set("map");
    view.set("edit");
  }

  async function deleteMap(map: MapInterface) {
    MapsStore.deleteMap(map);
    if (map.id == get(selectedMap).id) {
      selectedMap.set({ ...MapState });
    }

    mode.set("map");
    view.set("details");
  }

  async function saveMap() {
    const newMap = await MapsStore.saveMap(get(mapUnderConstruction));
    selectedMap.set(newMap);
    mapUnderConstruction.set({ ...MapState });
    mode.set("map");
    view.set("details");
  }

  async function cancelEditMap() {
    mapUnderConstruction.set({ ...MapState });

    if (get(selectedMap).id == "") {
      selectedMap.set({ ...MapState });
    }

    mode.set("map");
    view.set("details");
  }

  //
  //
  // Area type stuff
  //
  //

  const buildingArea = derived(
    [mode, view],
    ([$mode, $view]) => $mode == "area" && $view == "edit"
  );

  async function createArea() {
    selectedArea.set({ ...AreaState });

    selectedLink.set({ ...LinkState });
    areaUnderConstruction.set({
      ...AreaState,
      ...{ mapId: get(selectedMap).id },
    });
    linkUnderConstruction.set({ ...LinkState });
    mode.set("area");
    view.set("edit");
  }

  async function cancelEditArea() {
    areaUnderConstruction.set({ ...AreaState });
    mode.set("area");
    view.set("details");
  }

  async function editArea(area: AreaInterface) {
    if (area.mapId == "") {
      area.mapId = get(selectedMap).id;
    }
    selectedArea.set(area);
    areaUnderConstruction.set({ ...area });
    mode.set("area");
    view.set("edit");
  }

  async function saveArea() {
    const newArea = await AreasStore.saveArea(get(areaUnderConstruction));
    selectedArea.set(newArea);
    areaUnderConstruction.set({ ...AreaState });
    mode.set("area");
    view.set("details");
  }

  async function deleteArea(area: AreaInterface) {
    AreasStore.deleteArea(area);
    if (area.id == get(selectedArea).id) {
      selectedArea.set({ ...AreaState });
    }

    linksMap.update(function (map) {
      get(links).forEach((link) => {
        if (link.toId == area.id || link.fromId == area.id) {
          delete map[link.id];
        }
      });
      return map;
    });

    mode.set("area");
    view.set("details");
  }

  async function selectArea(area: AreaInterface) {
    // selecting area can come from two different places
    // one is the main map
    // second is the map that only shows during editing links
    // if a link is selected on the second map during editing there are three cases to handle
    // the area selected is for the same set of links and areas loaded for the link editor
    // the area selected is for the primary map
    // the area selected is for a new map that is neither the primary nor the one already loaded for the editor

    // When changing/selecting areas, always clear any links which may have been selected
    selectedLink.set({ ...LinkState });

    if (area.id.endsWith("highlight")) {
      var dash = area.id.lastIndexOf("-");
      var id = area.id.substring(0, dash);
      area = get(areasMap)[id];
    }

    // if editing link
    // if area selected differs from the map area selected, load areas for the new map
    // if area is part of already loaded data, set the area as
    if (get(mode) == "link" && get(view) == "edit") {
      // Editing
      if (area.mapId != get(linkEditorMapForOtherAreaId)) {
        linkEditorMapForOtherAreaId.set(area.mapId);
        // Selected area is for a different map than is loaded in editor
      }

      // Load the data
      if (area.mapId == get(selectedMap).id) {
        // Selected area is for the 'main' map that is being build, don't load from db again but use local copy
        areasForLinkEditorMap.set(get(areasMap));
        linksForLinkEditor.set(get(links));
      } else {
        await loadDataForLinkEditor(area.mapId);
      }

      if (get(linkUnderConstruction).toId == area.id) {
        // incoming
        linkUnderConstruction.update(function (luc) {
          luc.fromId = area.id;
          return luc;
        });
      } else {
        linkUnderConstruction.update(function (luc) {
          luc.toId = area.id;
          return luc;
        });
      }
    } else if (get(mode) == "map" && get(view) == "details") {
      // Not editing link, but just looking at the map/area lists/details
      // Selecting an area here actually changes that something is selected, and if it happens to be a new map then we jump over to that
      if (area.mapId != get(selectedMap).id) {
        selectedMap.set(get(mapsMap)[area.mapId]);
        loadAllMapData(area.mapId);
      }
    } else if (get(mode) == "area" && get(view) == "details") {
      // Not editing link, but just looking at the map/area lists/details
      // Selecting an area here actually changes that something is selected, and if it happens to be a new map then we jump over to that
      await tick;
      if (area.mapId != get(selectedMap).id) {
        selectedMap.set(get(mapsMap)[area.mapId]);
        selectedArea.set({ ...AreaState });
        loadAllMapData(area.mapId);
      } else {
        selectedArea.set(area);
        await tick();
        document.getElementById(`AreaList:${area.id}`).scrollIntoView();
      }
    }
  }

  //
  //
  // Link type stuff
  //
  //

  const buildingLink = derived(
    [mode, view],
    ([$mode, $view]) => $mode == "link" && $view == "edit"
  );

  let deletingLink = writable(false);

  async function deleteLink(link: LinkInterface) {
    LinksStore.deleteLink(link);
    if (link.id == get(selectedLink).id) {
      selectedLink.set({ ...LinkState });
    }

    mode.set("area");
    view.set("details");
  }

  async function selectLink(link: LinkInterface) {
    selectedLink.set(link);
  }

  async function followLink(link: LinkInterface) {
    // find opposite link if there is one and unset if there is not, otherwise set opposite link as selected
    // call selectArea

    const otherArea =
      get(selectedArea).id == link.toId
        ? get(areasMap)[link.fromId]
        : get(areasMap)[link.toId];

    selectArea(otherArea);
    selectedLink.set(link);
  }

  async function editLink(link: LinkInterface) {
    selectedLink.set(link);
    linkUnderConstruction.set(link);
    // check to see if the map for the area on the other side of the link is the same. If it is different, load up the other map and set ids

    const area = get(selectedArea);
    const areaMapId = area.mapId;

    if (link.toId == area.id && areaMapId != get(areasMap)[link.fromId].mapId) {
      linkEditorMapForOtherAreaId.set(get(areasMap)[link.fromId].mapId);
    } else if (
      link.fromId == area.id &&
      areaMapId != get(areasMap)[link.toId].mapId
    ) {
      linkEditorMapForOtherAreaId.set(get(areasMap)[link.toId].mapId);
    } else {
      linkEditorMapForOtherAreaId.set(area.mapId);
    }

    await loadDataForLinkEditor(get(linkEditorMapForOtherAreaId));

    mode.set("link");
    view.set("edit");
  }

  // Map Label Stuff

  const selectedMapLabel = writable(<MapLabelInterface>{ ...MapLabelState });
  const mapLabelUnderConstruction = writable(<MapLabelInterface>{
    ...MapLabelState,
  });

  async function selectMapLabel(mapLabel: MapLabelInterface) {
    selectedMapLabel.set(mapLabel);
  }

  async function addLabelToMap(map: MapInterface) {
    selectedMapLabel.set({ ...MapLabelState });
    mapUnderConstruction.set({ ...map });
    mapLabelUnderConstruction.set({ ...MapLabelState });

    await tick();
    mode.set("map");
    view.set("label");
  }

  async function editMapLabel(mapLabel: MapLabelInterface) {
    selectedMapLabel.set(mapLabel);
    mapUnderConstruction.set({ ...get(selectedMap) });
    mapLabelUnderConstruction.set({ ...mapLabel });

    await tick();
    mode.set("map");
    view.set("label");
  }

  async function cancelEditMapLabel() {
    mapUnderConstruction.set({ ...MapState });
    mapLabelUnderConstruction.set({ ...MapLabelState });
    selectedMapLabel.set({ ...MapLabelState });

    if (get(selectedMap).id == "") {
      selectedMap.set({ ...MapState });
    }

    await tick();
    mode.set("map");
    view.set("details");
  }

  async function saveMapLabel() {
    let newLabel = false;
    let oldIds;

    if (get(mapLabelUnderConstruction).id == "") {
      newLabel = true;
      oldIds = get(mapUnderConstruction).labels.map((label) => label.id);
    }

    mapUnderConstruction.update(function (map) {
      var foundLabel = false;
      for (var i = 0; i < map.labels.length; i++) {
        if (map.labels[i].id == get(mapLabelUnderConstruction).id) {
          foundLabel = true;
          break;
        }
      }

      if (foundLabel) {
        map.labels = map.labels.map((label) =>
          label.id == get(mapLabelUnderConstruction).id
            ? get(mapLabelUnderConstruction)
            : label
        );
      } else {
        map.labels.push(get(mapLabelUnderConstruction));
      }

      return map;
    });

    const newMap = await MapsStore.saveMap(get(mapUnderConstruction));

    if (newLabel) {
      const newMapLabel = newMap.labels.filter(
        (label) => !oldIds.includes(label.id)
      )[0];

      selectedMapLabel.set(newMapLabel);
    } else {
      const newMapLabel = newMap.labels.filter(
        (label) => label.id == get(mapLabelUnderConstruction).id
      )[0];

      selectedMapLabel.set(newMapLabel);
    }

    selectedMap.set(newMap);
    mapUnderConstruction.set({ ...MapState });
    mapLabelUnderConstruction.set({ ...MapLabelState });

    await tick();
    mode.set("map");
    view.set("details");
  }

  async function deleteMapLabel(mapLabelId: string) {
    mapUnderConstruction.update(function (map) {
      map.labels = map.labels.filter((label) => label.id != mapLabelId);
      return map;
    });

    selectedMapLabel.set({ ...MapLabelState });
    mapLabelUnderConstruction.set({ ...MapLabelState });

    const newMap = await MapsStore.saveMap(get(mapUnderConstruction));
    selectedMap.set(newMap);
    mapUnderConstruction.set({ ...MapState });

    await tick();
    mode.set("map");
    view.set("details");
  }

  const mapZoomMultipliers = writable([
    0.00775,
    0.015,
    0.03,
    0.06,
    0.125,
    0.25, // 4x size
    0.5, // double size
    1,
    2, // half size
    4, // quarter
    8,
    16,
    32,
    64,
    128,
    256,
    512,
  ]);
  const mapZoomMultiplierIndex = writable(7);

  const mapAtMaxZoom = writable(false);
  const mapAtMinZoom = writable(false);

  async function zoomMapOut() {
    if (get(mapZoomMultiplierIndex) < get(mapZoomMultipliers).length - 1) {
      mapZoomMultiplierIndex.set(get(mapZoomMultiplierIndex) + 1);

      if (get(selectedMap).maximumZoomIndex == get(mapZoomMultiplierIndex)) {
        mapAtMaxZoom.set(true);
      } else {
        mapAtMinZoom.set(false);
      }
    }
  }

  async function zoomMapIn() {
    if (get(mapZoomMultiplierIndex) > 0) {
      mapZoomMultiplierIndex.set(get(mapZoomMultiplierIndex) - 1);

      if (get(selectedMap).minimumZoomIndex == get(mapZoomMultiplierIndex)) {
        mapAtMinZoom.set(true);
      } else {
        mapAtMaxZoom.set(false);
      }
    }
  }

  return {
    // Area stuff
    buildingArea,
    areaUnderConstruction,
    areaSelected,
    selectedArea,
    areasForLinkEditor,
    areasForLinkEditorMap,
    areasForLinkEditorFilteredMap,
    areasForLinkEditorFiltered,
    // Links stuff
    buildingLink,
    linkUnderConstruction,
    linkSelected,
    selectedLink,
    linkPreviewAreaId,
    showPreviewLink,
    linkEditorMapForOtherAreaId,
    linksForLinkEditor,
    loadingLinkEditorData,
    linkEditorDataLoaded,
    incomingLinksForSelectedArea,
    outgoingLinksForSelectedArea,
    deletingLink,
    // Map stuff
    loadingMapData,
    mapDataLoaded,
    selectedMap,
    mapSelected,
    svgMapAllowIntraMapAreaSelection,
    svgMapAllowInterMapAreaSelection,
    mapUnderConstruction,
    mapZoomMultipliers,
    mapZoomMultiplierIndex,
    mapAtMinZoom,
    mapAtMaxZoom,
    zoomMapIn,
    zoomMapOut,
    // UI stuff,
    mode,
    view,
    // Methods
    // Link stuff
    changeMapForLinkEditor,
    deleteLink,
    editLink,
    followLink,
    saveLink,
    loadDataForLinkEditor,
    linkArea,
    cancelLinkArea,
    selectLink,
    // Area stuff
    deleteArea,
    createArea,
    cancelEditArea,
    saveArea,
    selectArea,
    editArea,
    // Map stuff
    editMap,
    buildMap,
    loadAllMapData,
    selectMap,
    saveMap,
    cancelEditMap,
    createNewMap,
    deleteMap,
    // Map Label stuff
    selectedMapLabel,
    selectMapLabel,
    editMapLabel,
    mapLabelUnderConstruction,
    cancelEditMapLabel,
    saveMapLabel,
    deleteMapLabel,
    addLabelToMap,
  };
}

export const WorldBuilderStore = createWorldBuilderStore();
