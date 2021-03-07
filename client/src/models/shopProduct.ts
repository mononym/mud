export interface ShopProductInterface {
  id: string;
  shop_id: string;
  template_id: string;
  description: string;
  copper: number;
  bronze: number;
  silver: number;
  gold: number;
}

const state: ShopProductInterface = {
  id: "",
  shop_id: "",
  template_id: "",
  description: "",
  copper: 0,
  bronze: 0,
  silver: 0,
  gold: 0,
};

export default state;
