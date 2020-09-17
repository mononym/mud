import { LinkInterface } from '../link/state';

export interface LinksInterface {
  // allLinksIndex: string[];
  linksMap: Record<string, LinkInterface>;
  linksForMapIndex: Record<string, string[]>;
}

const state: LinksInterface = {
  // allLinksIndex: [],
  linksMap: {},
  linksForMapIndex: {}
};

export default state;
