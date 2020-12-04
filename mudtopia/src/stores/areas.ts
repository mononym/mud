import { writable } from "svelte/store";
import {
  loadMaps
} from "../api/server";

function createMapsStore() {
  const loaded = writable(false);
  const isLoading = writable(false);
  const isSaving = writable(false);
  const isDeleting = writable(false);
  const areas = writable([]);
  const areasIndex = writable({});

  
return {
  loaded, isLoading, isSaving, isDeleting, areas, areasIndex
  }
}


export const MapsStore = createMapsStore();