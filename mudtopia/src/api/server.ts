import Api from "../services/api";
import type {AxiosResponse} from 'axios'
import type { PlayerInterface } from "../models/player";
import type { MapInterface } from "../models/map";
import type { LinkInterface } from "../models/link";
import type { AreaInterface } from "../models/area";

// Method to begin login/signup process by submitting an email address
export async function submitEmailForAuth(email: string): Promise<AxiosResponse<unknown>> {
  return await Api.post("/authenticate/email", {email: email});
}

// Method for finalizing login/signup via OTP token
export async function submitTokenForAuth(token: string): Promise<AxiosResponse<PlayerInterface>> {
  return await <Promise<AxiosResponse<PlayerInterface>>>Api.post("/authenticate/token", {token: token});
}

export async function syncPlayer(): Promise<AxiosResponse<{authenticated: boolean, player: PlayerInterface}>> {
  return await <Promise<AxiosResponse<{authenticated: boolean, player: PlayerInterface}>>>Api.get("/authenticate/sync");
}

export async function logoutPlayer(): Promise<AxiosResponse<string>> {
  return await <Promise<AxiosResponse<string>>>Api.post("/authenticate/logout", '');
}

export async function loadMaps(): Promise<AxiosResponse<MapInterface[]>> {
  return await <Promise<AxiosResponse<MapInterface[]>>>Api.get("/maps");
}

export async function loadMapData(mapId: string): Promise<AxiosResponse<{areas: AreaInterface[], links: LinkInterface[]}>> {
  return await <Promise<AxiosResponse<{areas: AreaInterface[], links: LinkInterface[]}>>>Api.get("/maps/" + mapId + "/data");
}

export async function createMap(params: Record<string, unknown>): Promise<AxiosResponse<MapInterface>> {
  return await <Promise<AxiosResponse<MapInterface>>>Api.post("/maps", params);
}

export async function updateMap(params: Record<string, unknown>): Promise<AxiosResponse<MapInterface>> {
  return await <Promise<AxiosResponse<MapInterface>>>Api.patch("/maps/" + params.id, {map: params});
}