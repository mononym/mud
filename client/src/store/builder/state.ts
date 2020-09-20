import { AreaInterface } from '../area/state';
import { MapInterface } from '../map/state';
import { LinkInterface } from '../link/state';

import areaState from '../area/state';
import mapState from '../map/state';
import linkState from '../link/state';

export interface BuilderInterface {
  // Area stuff
  areaIndex: Record<string, number>;
  areas: AreaInterface[];
  areaUnderConstruction: AreaInterface;
  isAreaUnderConstruction: boolean;
  isAreaUnderConstructionNew: boolean;
  selectedArea: AreaInterface;
  isAreaSelected: boolean;
  // Link stuff
  links: LinkInterface[];
  linkIndex: Record<string, number>;
  linkUnderConstruction: LinkInterface;
  selectedLink: LinkInterface;
  isLinkSelected: boolean;
  isLinkUnderConstruction: boolean;
  isLinkUnderConstructionNew: boolean;
  // Map stuff
  isMapUnderConstruction: boolean;
  isMapUnderConstructionNew: boolean;
  mapIndex: Record<string, number>;
  maps: MapInterface[];
  mapUnderConstruction: MapInterface;
  selectedMap: MapInterface;
  isMapSelected: boolean;
  // UI stuff
  bottomLeftPanel: string;
  bottomRightPanel: string;
}

const state: BuilderInterface = {
  // Area
  areaIndex: {},
  areas: [],
  areaUnderConstruction: { ...areaState },
  isAreaUnderConstruction: false,
  isAreaUnderConstructionNew: true,
  selectedArea: { ...areaState },
  isAreaSelected: false,
  // Link
  isLinkUnderConstruction: false,
  isLinkUnderConstructionNew: true,
  linkUnderConstruction: { ...linkState },
  linkIndex: {},
  links: [],
  selectedLink: { ...linkState },
  isLinkSelected: false,
  // Map
  isMapUnderConstruction: false,
  isMapUnderConstructionNew: true,
  mapIndex: {},
  maps: [],
  mapUnderConstruction: { ...mapState },
  selectedMap: { ...mapState },
  isMapSelected: false,
  // UI stuff
  bottomLeftPanel: 'mapTable',
  bottomRightPanel: 'areaTable'
};

export default state;
