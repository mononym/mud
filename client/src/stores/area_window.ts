import { get, writable } from "svelte/store";
import type { ItemInterface } from "../models/item";
import type { AreaInterface } from "../models/area";
import AreaState from "../models/area";

function createAreaWindowStore() {
  const allAreaItemsIndex = writable(<Record<string, ItemInterface>>{});
  const areaItemsParentChildIndex = writable(
    <Record<string, ItemInterface[]>>{}
  );

  const otherCharactersInArea = writable([]);
  const onGroundInArea = writable([]);
  const exitsInArea = writable([]);
  const denizensInArea = writable([]);
  const toiInArea = writable([]);
  const currentArea = writable({ ...AreaState });

  function resetAreaItemsIndex(items) {
    const newIndex = {};

    items.forEach((itm) => (newIndex[itm.id] = itm));

    allAreaItemsIndex.set(newIndex);
    resetAreaItemsParentChildIndex();
  }

  function resetAreaItemsParentChildIndex() {
    const newParentChildIndex = {};
    console.log("resetAreaItemsParentChildIndex");
    console.log(Object.values(get(allAreaItemsIndex)));

    Object.values(get(allAreaItemsIndex)).forEach((item) => {
      if (item.location.relative_to_item) {
        const existingChildren =
          newParentChildIndex[item.location.relative_item_id] || [];
        existingChildren.push(item);
        newParentChildIndex[item.location.relative_item_id] = existingChildren;
      }
    });

    areaItemsParentChildIndex.set(newParentChildIndex);
    console.log("resetAreaItemsParentChildIndex");
    console.log(get(areaItemsParentChildIndex));
  }

  function addItemsToAreaItemsIndex(items) {
    allAreaItemsIndex.update(function (index) {
      items.forEach((itm) => {
        index[itm.id] = itm;
      });
      return index;
    });

    resetAreaItemsParentChildIndex();
  }

  function removeItemsFromAreaItemsIndex(items) {
    allAreaItemsIndex.update(function (index) {
      items.forEach((itm) => {
        delete index[itm.id];
      });
      return index;
    });

    resetAreaItemsParentChildIndex();
  }

  function resetOnGround() {
    const newOnGround = [];

    Object.values(get(allAreaItemsIndex)).forEach((item) => {
      if (item.location.on_ground && !item.flags.scenery) {
        newOnGround.push(item);
      }
    });

    onGroundInArea.set(newOnGround);
  }

  function updateOtherCharacters(characters) {
    characters.forEach((character) => {
      otherCharactersInArea.update(function (index) {
        index[character.id] = character;
        return index;
      });
    });

    resetOtherCharacters(get(otherCharactersInArea));
  }

  function resetOtherCharacters(characters) {
    otherCharactersInArea.set(characters);
  }

  function updateExits(exits) {
    exitsInArea.set(
      [...exits, ...get(exitsInArea)].filter(
        (v, i, a) => a.findIndex((it) => it.id == v.id) === i
      )
    );
  }

  function resetToi() {
    const newToi = [];

    Object.values(get(allAreaItemsIndex)).forEach((item) => {
      if (item.location.on_ground && item.flags.scenery) {
        newToi.push(item);
      }
    });

    toiInArea.set(newToi);
  }

  function addExits(exits) {
    exits.forEach((item) => {
      exitsInArea.update(function (ext) {
        ext.push(item);
        return ext;
      });
    });
  }

  function removeOtherCharacters(characters) {
    characters.forEach((character) => {
      otherCharactersInArea.update(function (others) {
        return others.filter((other) => other.id != character.id);
      });
    });
  }

  function removeExits(exits) {
    exits.forEach((exit) => {
      exitsInArea.update(function (eia) {
        return eia.filter((ext) => ext.id != exit.id);
      });
    });
  }

  function addOtherCharacters(characters) {
    characters.forEach((character) => {
      otherCharactersInArea.update(function (others) {
        others.push(character);
        return others;
      });
    });
  }

  return {
    // Indexes/Lists
    allAreaItemsIndex,
    areaItemsParentChildIndex,
    currentArea,
    denizensInArea,
    exitsInArea,
    onGroundInArea,
    otherCharactersInArea,
    toiInArea,
    // Functions
    addItemsToAreaItemsIndex,
    removeItemsFromAreaItemsIndex,
    resetAreaItemsIndex,
    resetOnGround,
    updateOtherCharacters,
    resetOtherCharacters,
    updateExits,
    resetToi,
    addExits,
    removeOtherCharacters,
    removeExits,
    addOtherCharacters,
  };
}

export const AreaWindowStore = createAreaWindowStore();
