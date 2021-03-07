import { derived, writable } from "svelte/store";
import { createArea, updateArea, deleteArea as delArea } from "../api/server";
import type { AreaInterface } from "../models/area";

function createAreasStore() {
  const loaded = writable(false);
  const loading = writable(false);
  const saving = writable(false);
  const deleting = writable(false);
  const areasMap = writable(<Record<string, AreaInterface>>{});
  const areas = derived(
    areasMap,
    ($areasMap) => <AreaInterface[]>Object.values($areasMap)
  );

  async function putAreas(areas: AreaInterface[]) {
    const newAreasArea = {};
    for (var i = 0; i < areas.length; i++) {
      newAreasArea[areas[i].id] = areas[i];
    }

    areasMap.set(newAreasArea);
  }

  async function deleteArea(area: AreaInterface) {
    deleting.set(true);

    try {
      await delArea(area.id);

      areasMap.update(function (mm) {
        delete mm[area.id];
        return mm;
      });
    } catch (e) {
      alert(e.message);
    } finally {
      deleting.set(false);
    }
  }

  async function saveArea(area: AreaInterface) {
    saving.set(true);
    let oldData;
    const isNew = area.id == "";

    try {
      if (!isNew) {
        oldData = areasMap[area.id];
        areasMap[area.id] = area;
      }

      let res: AreaInterface;

      if (isNew) {
        res = (await createArea(area)).data;
      } else {
        res = (await updateArea(area)).data;
      }

      areasMap.update(function (mm) {
        mm[res.id] = res;
        return mm;
      });

      return res;
    } catch (e) {
      if (!isNew) {
        areasMap[area.id] = oldData;
      }
      alert(e.message);
    } finally {
      saving.set(false);
    }
  }

  return {
    putAreas,
    loaded,
    loading,
    saving,
    deleting,
    areas,
    areasMap,
    saveArea,
    deleteArea,
  };
}

export const AreasStore = createAreasStore();
