import type { ItemLocationInterface } from "./itemLocation";
import ItemLocationState from "./itemLocation";

import type { ItemContainerInterface } from "./itemContainer";
import ItemContainerState from "./itemContainer";

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
  container: ItemContainerInterface;
  description: ItemDescriptionInterface;
  flags: ItemFlagsInterface;
  furniture: ItemFurnitureInterface;
  gem: ItemGemInterface;
  location: ItemLocationInterface;
  physics: ItemPhysicsInterface;
  surface: ItemSurfaceInterface;
  wearable: ItemWearableInterface;
}

const state: ItemInterface = {
  id: "",
  container: { ...ItemContainerState },
  description: { ...ItemDescriptionState },
  flags: { ...ItemFlagsState },
  furniture: { ...ItemFurnitureState },
  gem: { ...ItemGemState },
  location: { ...ItemLocationState },
  physics: { ...ItemPhysicsState },
  surface: { ...ItemSurfaceState },
  wearable: { ...ItemWearableState },
};

export default state;
