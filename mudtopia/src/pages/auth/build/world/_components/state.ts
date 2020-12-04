import { derived, writable } from "svelte/store";
import MapState from '../../../../../models/map'
import {loadMapData} from '../../../../../api/server'

function createWorldBuilderStore() {
  const loadingMapData = writable(false);
  const mapDataLoaded = writable(false);
  const areas = writable([]);
  const links = writable([]);
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
  links,
  loadingMapData,
  mapDataLoaded,
  selectedMap,
  mapSelected,
  loadAllMapData
  }
}


export const WorldBuilderStore = createWorldBuilderStore();