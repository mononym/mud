import { LinkInterface } from '../link/state';

export interface LinksInterface {
  links: LinkInterface[];
  linkIndex: Record<string, number>;
}

const state: LinksInterface = {
  links: [],
  linkIndex: {}
};

export default state;
