import { AreaInterface } from '../area/state';
import { MapInterface } from '../map/state';
import { LinkInterface } from '../link/state';

import areaState from '../area/state';
import mapState from '../map/state';
import linkState from '../link/state';

export interface BuilderInterface {
  internalAreaIndex: Record<string, number>;
  externalAreaIndex: Record<string, number>;
  internalAreas: AreaInterface[];
  externalAreas: AreaInterface[];
  linkIndex: Record<string, number>;
  links: LinkInterface[];
  linkUnderConstruction: LinkInterface;
  selectedLink: LinkInterface;
  isLinkUnderConstruction: boolean;
  isLinkUnderConstructionNew: boolean;
  areaUnderConstruction: AreaInterface;
  isAreaUnderConstruction: boolean;
  isAreaUnderConstructionNew: boolean;
  selectedArea: AreaInterface;
  isMapUnderConstruction: boolean;
  isMapUnderConstructionNew: boolean;
  mapIndex: Record<string, number>;
  maps: MapInterface[];
  mapUnderConstruction: MapInterface;
  selectedMap: MapInterface;
}

const state: BuilderInterface = {
  internalAreaIndex: {},
  externalAreaIndex: {},
  internalAreas: [],
  externalAreas: [],
  areaUnderConstruction: { ...areaState },
  isAreaUnderConstruction: false,
  isAreaUnderConstructionNew: true,
  selectedArea: { ...areaState },
  isMapUnderConstruction: false,
  isMapUnderConstructionNew: true,
  mapIndex: {},
  maps: [],
  mapUnderConstruction: { ...mapState },
  selectedMap: { ...mapState },
  isLinkUnderConstruction: false,
  isLinkUnderConstructionNew: true,
  linkIndex: {},
  links: [],
  linkUnderConstruction: { ...linkState },
  selectedLink: { ...linkState }
};

export default state;
