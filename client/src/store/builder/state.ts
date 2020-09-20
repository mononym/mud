import { AreaInterface } from '../area/state';
import { MapInterface } from '../map/state';
import { LinkInterface } from '../link/state';

import areaState from '../area/state';
import mapState from '../map/state';
import linkState from '../link/state';

export interface BuilderInterface {
  // Area stuff
  internalAreaIndex: Record<string, number>;
  externalAreaIndex: Record<string, number>;
  internalAreas: AreaInterface[];
  externalAreas: AreaInterface[];
  areaUnderConstruction: AreaInterface;
  isAreaUnderConstruction: boolean;
  isAreaUnderConstructionNew: boolean;
  selectedArea: AreaInterface;
  // Link stuff
  internalLinks: LinkInterface[];
  externalLinks: LinkInterface[];
  internalLinkIndex: Record<string, number>;
  externalLinkIndex: Record<string, number>;
  linkUnderConstruction: LinkInterface;
  selectedLink: LinkInterface;
  isLinkUnderConstruction: boolean;
  isLinkUnderConstructionNew: boolean;
  // Map stuff
  isMapUnderConstruction: boolean;
  isMapUnderConstructionNew: boolean;
  mapIndex: Record<string, number>;
  maps: MapInterface[];
  mapUnderConstruction: MapInterface;
  selectedMap: MapInterface;
  // UI stuff
  bottomLeftPanel: string;
  bottomRightPanel: string;
}

const state: BuilderInterface = {
  // Area
  internalAreaIndex: {},
  externalAreaIndex: {},
  internalAreas: [],
  externalAreas: [],
  areaUnderConstruction: { ...areaState },
  isAreaUnderConstruction: false,
  isAreaUnderConstructionNew: true,
  selectedArea: { ...areaState },
  // Link
  isLinkUnderConstruction: false,
  isLinkUnderConstructionNew: true,
  linkUnderConstruction: { ...linkState },
  internalLinkIndex: {},
  externalLinkIndex: {},
  internalLinks: [],
  externalLinks: [],
  selectedLink: { ...linkState },
  // Map
  isMapUnderConstruction: false,
  isMapUnderConstructionNew: true,
  mapIndex: {},
  maps: [],
  mapUnderConstruction: { ...mapState },
  selectedMap: { ...mapState },
  // UI stuff
  bottomLeftPanel: 'mapTable',
  bottomRightPanel: 'areaTable'
};

export default state;
