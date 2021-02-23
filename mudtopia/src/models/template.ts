import ItemState, { ItemInterface } from "./item";

export interface TemplateInterface {
  id: string;
  name: string;
  description: string;
  template: ItemInterface;
}

const state: TemplateInterface = {
  id: "",
  name: "",
  description: "",
  template: { ...ItemState },
};

export default state;
