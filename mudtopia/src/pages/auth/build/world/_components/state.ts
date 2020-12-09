import { derived, writable, get } from "svelte/store";
import MapState, { MapInterface } from "../../../../../models/map";
import AreaState, { AreaInterface } from "../../../../../models/area";
import LinkState from "../../../../../models/link";
import { loadMapData, loadAreasForMap } from "../../../../../api/server";
import { AreasStore } from "../../../../../stores/areas";
import { MapsStore } from "../../../../../stores/maps";
import { LinksStore } from "../../../../../stores/links";
const { mapsMap } = MapsStore;

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
  const linkEditorMapForOtherAreaId = writable("");
  const selectedLink = writable({ ...LinkState });
  const linkSelected = derived(
    selectedLink,
    ($selectedLink) => $selectedLink.id != ""
  );
  const linkUnderConstruction = writable({ ...LinkState });

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

  async function selectArea(area: AreaInterface) {
    // Special rules apply when the selected area does not match up with the currently selected map
    if (area.mapId != get(selectedMap).id) {
      // if in map details mode, or area details mode, switch maps
      if (
        (get(mode) == "map" || get(mode) == "area") &&
        get(view) == "details"
      ) {
        selectedMap.set(get(mapsMap)[area.mapId]);
        WorldBuilderStore.loadAllMapData(area.mapId);
        selectedArea.set({ ...AreaState });
      } else if (get(mode) == "link" && get(view) == "edit") {
        // Otherwise in editing links mode, selecting another map is the same as changing the map selection dropdown

        if (get(linkUnderConstruction).toId == get(selectedArea).id) {
          // incoming
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

        linkEditorMapForOtherAreaId.set(area.mapId);

        WorldBuilderStore.loadAreasForLinkEditor(area.mapId);
      }

      return;
    }
    // If an area is selected while an area is being linked, it is not the 'selectedArea'
    // that needs updating, but the selected area should be treated as the target for the
    // linking of the 'selectedArea', which means it needs to both trigger actions in the
    // link editor as well as making sure the map shows a preview of where the link will go.
    if (get(mode) == "link") {
      // Detect if the map for other area is set to different map. If so set it back
      if (get(linkEditorMapForOtherAreaId) != get(selectedMap).id) {
        linkEditorMapForOtherAreaId.set(get(selectedMap).id);
        loadAreasForLinkEditor(get(selectedMap).id);
      }

      // If area being set is the same area already selected do nothing
      // If the link does not have to and from id's set it's not really constructed yet, so do nothing
      if (
        (get(linkUnderConstruction).toId == "" &&
          get(linkUnderConstruction).fromId == "") ||
        area.id == get(selectedArea).id
      ) {
        return;
      }

      // Check which direction the link under construction is going in, and make sure to set the right id
      if (get(linkUnderConstruction).toId == get(selectedArea).id) {
        linkUnderConstruction.update(function (link) {
          link.fromId = area.id;
          return link;
        });
      } else if (get(linkUnderConstruction).fromId == get(selectedArea).id) {
        linkUnderConstruction.update(function (link) {
          link.toId = area.id;
          return link;
        });
      }
    } else {
      selectedArea.set(area);
    }
  }

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
  const areasForLinkEditor = writable(<AreaInterface[]>[]);
  const areasForLinkEditorMap = writable(<Record<string, AreaInterface>>{});

  async function loadAreasForLinkEditor(mapId: string) {
    let areasToMap = [];

    if (mapId == get(selectedMap).id) {
      const filteredAreas = get(AreasStore.areas).filter(
        (area) =>
          area.mapId == get(selectedMap).id && area.id != get(selectedArea).id
      );
      areasForLinkEditor.set(filteredAreas);
      areasToMap = filteredAreas;
    } else {
      let res = (await loadAreasForMap(mapId, false)).data;
      areasForLinkEditor.set(res);
      areasToMap = res;
    }

    const newMapsMap = {};
    for (var i = 0; i < areasToMap.length; i++) {
      newMapsMap[areasToMap[i].id] = areasToMap[i];
    }

    areasForLinkEditorMap.set(newMapsMap);
  }

  return {
    // Area stuff
    areaUnderConstruction,
    areaSelected,
    selectedArea,
    areasForLinkEditor,
    areasForLinkEditorMap,
    // Links stuff
    linkUnderConstruction,
    linkSelected,
    selectedLink,
    linkPreviewAreaId,
    showPreviewLink,
    linkEditorMapForOtherAreaId,
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
    buildMap,
    loadAllMapData,
    selectArea,
    selectMap,
    loadAreasForLinkEditor,
    linkArea,
    cancelLinkArea,
  };
}

export const WorldBuilderStore = createWorldBuilderStore();
