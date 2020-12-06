import { derived, writable } from "svelte/store";
import MapState from "../../../../../models/map";
import AreaState from "../../../../../models/area";
import LinkState from "../../../../../models/link";
import { loadMapData } from "../../../../../api/server";
import { AreasStore } from "../../../../../stores/areas";
import { LinksStore } from "../../../../../stores/links";

function createWorldBuilderStore() {
  const loadingMapData = writable(false);
  const mapDataLoaded = writable(false);
  const links = writable([]);
  const linksIndex = derived(links, ($links) =>
    $links.reduce((obj, link) => ((obj[link.id] = link), obj), {})
  );
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
  const selectedLink = writable({ ...LinkState });
  const linkSelected = derived(
    selectedLink,
    ($selectedLink) => $selectedLink.id != ""
  );

  async function loadAllMapData(mapId) {
    try {
      const res = (await loadMapData(mapId)).data;

      AreasStore.putAreas(res.areas)
      LinksStore.putLinks(res.links)
    } catch (e) {
      alert(e.message);
    }
  }

  return {
    // Area stuff
    areaSelected,
    selectedArea,
    // Links stuff
    linkSelected,
    selectedLink,
    // Map stuff
    loadAllMapData,
    loadingMapData,
    mapDataLoaded,
    selectedMap,
    mapSelected,
  };
}

export const WorldBuilderStore = createWorldBuilderStore();
