import { derived, writable } from "svelte/store";
import {
  loadLinksForMap,
  createLink,
  updateLink,
  deleteLink as delLink,
} from "../api/server";
import type { LinkInterface } from "../models/link";

function createLinksStore() {
  const loaded = writable(false);
  const loading = writable(false);
  const saving = writable(false);
  const deleting = writable(false);
  const linksMap = writable(<Record<string, LinkInterface>>{});
  const links = derived(
    linksMap,
    ($linksMap) => <LinkInterface[]>Object.values($linksMap)
  );

  async function putLinks(areas: LinkInterface[]) {
    const newAreasArea = {};
    for (var i = 0; i < areas.length; i++) {
      newAreasArea[areas[i].id] = areas[i];
    }

    linksMap.set(newAreasArea);
  }

  async function deleteLink(link: LinkInterface) {
    deleting.set(true);

    try {
      await delLink(link.id);

      linksMap.update(function (mm) {
        delete mm[link.id];
        return mm;
      });
    } catch (e) {
      alert(e.message);
    } finally {
      deleting.set(false);
    }
  }

  async function saveLink(link: LinkInterface) {
    saving.set(true);
    let oldData;
    const isNew = link.id == "";

    const props = {
      icon: link.icon,
      local_from_corners: link.localFromCorners,
      local_from_color: link.localFromColor,
      local_from_size: link.localFromSize,
      local_from_x: link.localFromX,
      local_from_y: link.localFromY,
      local_from_label: link.localFromLabel,
      local_from_label_flipped: link.localFromLabelFlipped,
      local_from_label_vertical_offset: link.localFromLabelVerticalOffset,
      local_from_label_horizontal_offset: link.localFromLabelHorizontalOffset,
      local_from_label_font_size: link.localFromLabelFontSize,
      local_to_corners: link.localToCorners,
      local_to_color: link.localToColor,
      local_to_size: link.localToSize,
      local_to_x: link.localToX,
      local_to_y: link.localToY,
      local_to_label: link.localToLabel,
      local_to_label_flipped: link.localToLabelFlipped,
      local_to_label_vertical_offset: link.localToLabelVerticalOffset,
      local_to_label_horizontal_offset: link.localToLabelHorizontalOffset,
      local_to_label_font_size: link.localToLabelFontSize,
      label: link.label,
      label_flipped: link.labelFlipped,
      label_vertical_offset: link.labelVerticalOffset,
      label_horizontal_offset: link.labelHorizontalOffset,
      label_font_size: link.labelFontSize,
      long_description: link.longDescription,
      short_description: link.shortDescription,
      arrival_text: link.arrivalText,
      departure_text: link.departureText,
      to_id: link.toId,
      from_id: link.fromId,
      type: link.type,
    };

    try {
      if (!isNew) {
        oldData = linksMap[link.id];
        linksMap[link.id] = link;
      }

      let res: LinkInterface;

      if (isNew) {
        res = (await createLink(props)).data;
      } else {
        res = (await updateLink(props)).data;
      }

      linksMap.update(function (mm) {
        mm[res.id] = res;
        return mm;
      });

      return res;
    } catch (e) {
      if (!isNew) {
        linksMap[link.id] = oldData;
      }
      alert(e.message);
    } finally {
      saving.set(false);
    }
  }

  return {
    putLinks,
    loaded,
    loading,
    saving,
    deleting,
    links,
    saveLink,
    deleteLink,
  };
}

export const LinksStore = createLinksStore();
