import type { ShopProductInterface } from "./shopProduct";

export interface ShopInterface {
  id: string;
  name: string;
  description: string;
  area_id: string;
  products: ShopProductInterface[];
}

const state: ShopInterface = {
  id: "",
  name: "",
  description: "",
  area_id: "",
  products: [],
};

export default state;
