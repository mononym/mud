import { writable } from "svelte/store";
import {
  loadMaps
} from "../api/server";

function createMapsStore() {
  const loaded = writable(false);
  const isLoading = writable(false);
  const isSaving = writable(false);
  const isDeleting = writable(false);
  const links = writable([]);
  const linksIndex = writable({});

  
return {
  loaded, isLoading, isSaving, isDeleting, links, linksIndex
  }
}


export const MapsStore = createMapsStore();