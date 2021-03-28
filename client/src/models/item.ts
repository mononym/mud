import type { ItemLocationInterface } from "./itemLocation";
import ItemLocationState from "./itemLocation";

import type { ItemLockableInterface } from "./itemLockable";
import ItemLockableState from "./itemLockable";

import type { ItemPocketInterface } from "./itemPocket";
import ItemPocketState from "./itemPocket";

import type { ItemClosableInterface } from "./itemClosable";
import ItemClosableState from "./itemClosable";

import type { ItemDescriptionInterface } from "./itemDescription";
import ItemDescriptionState from "./itemDescription";

import type { ItemFlagsInterface } from "./itemFlags";
import ItemFlagsState from "./itemFlags";

import type { ItemPhysicsInterface } from "./itemPhysics";
import ItemPhysicsState from "./itemPhysics";

import type { ItemGemInterface } from "./itemGem";
import ItemGemState from "./itemGem";

import type { ItemWearableInterface } from "./itemWearable";
import ItemWearableState from "./itemWearable";

import type { ItemFurnitureInterface } from "./itemFurniture";
import ItemFurnitureState from "./itemFurniture";

import type { ItemSurfaceInterface } from "./itemSurface";
import ItemSurfaceState from "./itemSurface";

export interface ItemInterface {
  id: string;
  closable: ItemClosableInterface;
  description: ItemDescriptionInterface;
  flags: ItemFlagsInterface;
  furniture: ItemFurnitureInterface;
  gem: ItemGemInterface;
  location: ItemLocationInterface;
  lockable: ItemLockableInterface;
  physics: ItemPhysicsInterface;
  pocket: ItemPocketInterface;
  surface: ItemSurfaceInterface;
  wearable: ItemWearableInterface;
}

const state: ItemInterface = {
  id: "",
  closable: { ...ItemClosableState },
  description: { ...ItemDescriptionState },
  flags: { ...ItemFlagsState },
  furniture: { ...ItemFurnitureState },
  gem: { ...ItemGemState },
  location: { ...ItemLocationState },
  lockable: { ...ItemLockableState },
  physics: { ...ItemPhysicsState },
  pocket: { ...ItemPocketState },
  surface: { ...ItemSurfaceState },
  wearable: { ...ItemWearableState },
};

export default state;
