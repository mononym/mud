import { derived, writable, get } from "svelte/store";
import type { LinkInterface } from "../../../../../models/link";
import MapState, { MapInterface } from "../../../../../models/map";
import AreaState, { AreaInterface } from "../../../../../models/area";
import LinkState from "../../../../../models/link";
import { loadMapData, loadAreasForMap } from "../../../../../api/server";
import { AreasStore } from "../../../../../stores/areas";
import { MapsStore } from "../../../../../stores/maps";
import { LinksStore } from "../../../../../stores/links";
const { mapsMap } = MapsStore;
const { areasMap } = AreasStore;
const { links } = LinksStore;

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

  // Links stuff
  const incomingLinksForSelectedArea = derived(
    [areaSelected, selectedArea],
    ([$areaSelected, $selectedArea]) =>
      $areaSelected
        ? get(links).filter((link) => link.toId == $selectedArea.id)
        : []
  );
  const outgoingLinksForSelectedArea = derived(
    [areaSelected, selectedArea],
    ([$areaSelected, $selectedArea]) =>
      $areaSelected
        ? get(links).filter((link) => link.fromId == $selectedArea.id)
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
    linkUnderConstruction.set({ ...LinkState });
    selectedArea.set(area);
    mode.set("link");
    view.set("edit");
    console.log(get(linkUnderConstruction));
  }

  async function saveLink() {
    LinksStore.saveLink(get(linkUnderConstruction));
    linkUnderConstruction.set({ ...LinkState });
    mode.set("area");
    view.set("details");
  }

  async function cancelLinkArea() {
    linkUnderConstruction.set({ ...LinkState });
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

  async function loadDataForLinkEditor(mapId: string) {
    loadingLinkEditorData.set(true);
    linkEditorDataLoaded.set(false);
    let areasToMap = [];
    let newLinks = [];

    if (mapId == get(selectedMap).id) {
      // const filteredAreas = get(AreasStore.areas).filter(
      //   (area) => area.mapId == mapId && area.id != get(selectedArea).id
      // );

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

  async function selectArea(area: AreaInterface) {
    console.log("selecting area");
    console.log(area);
    // selecting area can come from two different places
    // one is the main map
    // second is the map that only shows during editing links
    // if a link is selected on the second map during editing there are three cases to handle
    // the area selected is for the same set of links and areas loaded for the link editor
    // the area selected is for the primary map
    // the area selected is for a new map that is neither the primary nor the one already loaded for the editor

    // if editing link
    // if area selected differs from the map area selected, load areas for the new map
    // if area is part of already loaded data, set the area as
    if (get(mode) == "link" && get(view) == "edit") {
      // Editing
      if (area.mapId != get(linkEditorMapForOtherAreaId)) {
        linkEditorMapForOtherAreaId.set(area.mapId);
        // Selected area is for a different map than is loaded in editor

        // Load the data
        if (area.mapId == get(selectedMap).id) {
          // Selected area is for the 'main' map that is being build, don't load from db again but use local copy
          areasForLinkEditorMap.set(get(areasMap));
          linksForLinkEditor.set(get(links));
        } else {
          await loadDataForLinkEditor(area.mapId);
        }
      }

      if (get(linkUnderConstruction).toId == get(selectedArea).id) {
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
    } else if (
      (get(mode) == "map" || get(mode) == "area") &&
      get(view) == "details"
    ) {
      // Not editing link, but just looking at the map/area lists/details
      // Selecting an area here actually changes that something is selected, and if it happens to be a new map then we jump over to that
      if (area.mapId != get(selectedMap).id) {
        selectedMap.set(get(mapsMap)[area.mapId]);
        loadAllMapData(area.mapId);
      }

      selectedArea.set(area);
    }
  }

  return {
    // Area stuff
    areaUnderConstruction,
    areaSelected,
    selectedArea,
    areasForLinkEditor,
    areasForLinkEditorMap,
    areasForLinkEditorFilteredMap,
    areasForLinkEditorFiltered,
    // Links stuff
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
    // Map stuff
    loadingMapData,
    mapDataLoaded,
    selectedMap,
    mapSelected,
    svgMapAllowIntraMapAreaSelection,
    svgMapAllowInterMapAreaSelection,
    // UI stuff,
    mode,
    view,
    // Methods
    saveLink,
    buildMap,
    loadAllMapData,
    selectArea,
    selectMap,
    loadDataForLinkEditor,
    linkArea,
    cancelLinkArea,
  };
}

export const WorldBuilderStore = createWorldBuilderStore();