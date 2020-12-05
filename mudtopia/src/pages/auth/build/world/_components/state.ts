import { derived, writable } from "svelte/store";
import MapState from '../../../../../models/map'
import {loadMapData} from '../../../../../api/server'

function createWorldBuilderStore() {
  const loadingMapData = writable(false);
  const mapDataLoaded = writable(false);
  const areas = writable([]);
  const areasIndex = derived(
    areas,
    $areas => $areas.reduce((obj, area) => (obj[area.id] = area, obj) ,{})
  )
  const links = writable([]);
  const linksIndex = derived(
    links,
    $links => $links.reduce((obj, link) => (obj[link.id] = link, obj) ,{})
  )
  const selectedMap = writable({...MapState});
  const mapSelected = derived(
    selectedMap,
    $selectedMap => $selectedMap.id != ''
  )

  async function loadAllMapData(mapId){
    try {
      const res = (await loadMapData(mapId)).data;
      
      areas.set(res.areas)
      links.set(res.links)
    } catch (e) {
      alert(e.message);
    }
  }
  
return {
  areas,
  areasIndex,
  links,
  linksIndex,
  loadingMapData,
  mapDataLoaded,
  selectedMap,
  mapSelected,
  loadAllMapData
  }
}


export const WorldBuilderStore = createWorldBuilderStore();