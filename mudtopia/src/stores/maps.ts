import { writable } from "svelte/store";
import {
  loadMaps
} from "../api/server";

function createMapsStore() {
  const loaded = writable(false);
  const isLoading = writable(false);
  const isSaving = writable(false);
  const isDeleting = writable(false);
  const maps = writable([]);
  const mapsIndex = writable({});

  async function load(){
    isLoading.set(true)
    try {
      const res = (await loadMaps()).data;

      console.log(res)

      maps.set(res)

      const newIndex = {}
      res.forEach((map, index) => newIndex[map.id] = index)
      mapsIndex.set(newIndex)

      loaded.set(true)
    } catch (e) {
      alert(e.message);
    } finally {
      isLoading.set(false)
    }
  }
  
return {
  load,
  loaded, isLoading, isSaving, isDeleting, maps, mapsIndex
  }
}


export const MapsStore = createMapsStore();