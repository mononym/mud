import type { ItemLocationInterface } from "../models/itemLocation";
import ItemLocationState from "../models/itemLocation";

import type { ItemContainerInterface } from "../models/itemContainer";
import ItemContainerState from "../models/itemContainer";

import type { ItemDescriptionInterface } from "../models/itemDescription";
import ItemDescriptionState from "../models/itemDescription";

import type { ItemFlagsInterface } from "../models/itemFlags";
import ItemFlagsState from "../models/itemFlags";

import type { ItemPhysicsInterface } from "../models/itemPhysics";
import ItemPhysicsState from "../models/itemPhysics";
export interface ItemInterface {
  id: string;
  location: ItemLocationInterface;
  physics: ItemPhysicsInterface;
  flags: ItemFlagsInterface;
  description: ItemDescriptionInterface;
  container: ItemContainerInterface;
}

const state: ItemInterface = {
  id: "",
  physics: { ...ItemPhysicsState },
  flags: { ...ItemFlagsState },
  description: { ...ItemDescriptionState },
  container: { ...ItemContainerState },
  location: { ...ItemLocationState },
};

export default state;
