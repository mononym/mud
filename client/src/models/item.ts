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

import type { ItemFurnitureInterface } from "./ItemFurniture";
import ItemFurnitureState from "./ItemFurniture";

export interface ItemInterface {
  id: string;
  location: ItemLocationInterface;
  physics: ItemPhysicsInterface;
  flags: ItemFlagsInterface;
  description: ItemDescriptionInterface;
  container: ItemContainerInterface;
  gem: ItemGemInterface;
  furniture: ItemFurnitureInterface;
  wearable: ItemWearableInterface;
}

const state: ItemInterface = {
  id: "",
  physics: { ...ItemPhysicsState },
  flags: { ...ItemFlagsState },
  description: { ...ItemDescriptionState },
  container: { ...ItemContainerState },
  location: { ...ItemLocationState },
  gem: { ...ItemGemState },
  furniture: { ...ItemFurnitureState },
  wearable: { ...ItemWearableState },
};

export default state;
