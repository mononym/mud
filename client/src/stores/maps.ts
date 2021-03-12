import { derived, writable } from "svelte/store";
import {
  loadMaps,
  createMap,
  updateMap,
  deleteMap as delMap,
} from "../api/server";
import type { MapInterface } from "../models/map";

function createMapsStore() {
  const loaded = writable(false);
  const loadingMaps = writable(false);
  const savingMaps = writable(false);
  const deletingMaps = writable(false);
  const mapsMap = writable({});
  const maps = derived(mapsMap, ($mapsMap) => Object.values($mapsMap));

  async function load() {
    loadingMaps.set(true);
    try {
      let res = (await loadMaps()).data;

      const newMapsMap = {};
      for (var i = 0; i < res.length; i++) {
        newMapsMap[res[i].id] = res[i];
      }

      mapsMap.set(newMapsMap);

      loaded.set(true);
    } catch (e) {
      alert(e.message);
    } finally {
      loadingMaps.set(false);
    }
  }

  async function deleteMap(map: MapInterface) {
    deletingMaps.set(true);

    try {
      await delMap(map.id);

      mapsMap.update(function (mm) {
        delete mm[map.id];
        return mm;
      });
    } catch (e) {
      alert(e.message);
    } finally {
      deletingMaps.set(false);
    }
  }

  async function saveMap(map: MapInterface) {
    savingMaps.set(true);
    let oldData;
    const isNew = map.id == "";

    console.log("saveMap");
    console.log(map);

    const props = {
      id: map.id,
      name: map.name,
      description: map.description,
      view_size: map.viewSize,
      grid_size: map.gridSize,
      labels: map.labels,
      permanently_explored: map.permanently_explored,
    };
    console.log(props);

    try {
      if (!isNew) {
        oldData = mapsMap[map.id];
        mapsMap[map.id] = map;
      }

      let res: MapInterface;

      if (isNew) {
        res = (await createMap(props)).data;
      } else {
        res = (await updateMap(props)).data;
      }

      mapsMap.update(function (mm) {
        mm[res.id] = res;
        return mm;
      });

      return res;
    } catch (e) {
      if (!isNew) {
        mapsMap[map.id] = oldData;
      }
      alert(e.message);
    } finally {
      savingMaps.set(false);
    }
  }

  return {
    load,
    loaded,
    loadingMaps,
    savingMaps,
    deletingMaps,
    maps,
    mapsMap,
    saveMap,
    deleteMap,
  };
}

export const MapsStore = createMapsStore();
