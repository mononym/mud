import { derived, writable } from "svelte/store";
import MapState from '../../../../../models/map'

function createWorldBuilderStore() {
  const selectedMap = writable({...MapState});
  const mapSelected = derived(
    selectedMap,
    $selectedMap => $selectedMap.id != ''
  )
  
return {
  selectedMap,
  mapSelected
  }
}


export const WorldBuilderStore = createWorldBuilderStore();