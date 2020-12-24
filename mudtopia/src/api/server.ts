import Api from "../services/api";
import type { AxiosResponse } from "axios";
import type { CharacterInterface } from "../models/character";
import type { PlayerInterface } from "../models/player";
import type { MapInterface } from "../models/map";
import type { LinkInterface } from "../models/link";
import type { AreaInterface } from "../models/area";

// Method to begin login/signup process by submitting an email address
export async function submitEmailForAuth(
  email: string
): Promise<AxiosResponse<unknown>> {
  return await Api.post("/authenticate/email", { email: email });
}

// Method for finalizing login/signup via OTP token
export async function submitTokenForAuth(
  token: string
): Promise<AxiosResponse<PlayerInterface>> {
  return await (<Promise<AxiosResponse<PlayerInterface>>>(
    Api.post("/authenticate/token", { token: token })
  ));
}

export async function syncPlayer(): Promise<
  AxiosResponse<{ authenticated: boolean; player: PlayerInterface }>
> {
  return await (<
    Promise<AxiosResponse<{ authenticated: boolean; player: PlayerInterface }>>
  >Api.get("/authenticate/sync"));
}

export async function logoutPlayer(): Promise<AxiosResponse<string>> {
  return await (<Promise<AxiosResponse<string>>>(
    Api.post("/authenticate/logout", "")
  ));
}

// Map Stuff

export async function loadMaps(): Promise<AxiosResponse<MapInterface[]>> {
  return await (<Promise<AxiosResponse<MapInterface[]>>>Api.get("/maps"));
}

export async function loadMapData(
  mapId: string
): Promise<AxiosResponse<{ areas: AreaInterface[]; links: LinkInterface[] }>> {
  return await (<
    Promise<AxiosResponse<{ areas: AreaInterface[]; links: LinkInterface[] }>>
  >Api.get("/maps/" + mapId + "/data"));
}

export async function createMap(
  params: Record<string, unknown>
): Promise<AxiosResponse<MapInterface>> {
  return await (<Promise<AxiosResponse<MapInterface>>>(
    Api.post("/maps", { map: params })
  ));
}

export async function updateMap(
  params: Record<string, unknown>
): Promise<AxiosResponse<MapInterface>> {
  return await (<Promise<AxiosResponse<MapInterface>>>(
    Api.patch("/maps/" + params.id, { map: params })
  ));
}

export async function deleteMap(mapId: string): Promise<AxiosResponse<string>> {
  return await (<Promise<AxiosResponse<string>>>(
    Api.delete("/maps/" + mapId, "")
  ));
}

// Area Stuff

export async function updateArea(
  params: AreaInterface
): Promise<AxiosResponse<AreaInterface>> {
  return await (<Promise<AxiosResponse<AreaInterface>>>(
    Api.patch("/areas/" + params.id, { area: params })
  ));
}

export async function deleteArea(
  areaId: string
): Promise<AxiosResponse<string>> {
  return await (<Promise<AxiosResponse<string>>>(
    Api.delete("/areas/" + areaId, "")
  ));
}

export async function loadAreasForMap(
  mapId: string,
  includeLinked: boolean
): Promise<AxiosResponse<AreaInterface[]>> {
  return await (<Promise<AxiosResponse<AreaInterface[]>>>(
    Api.get("/areas/map/" + mapId + "?include_linked=" + includeLinked)
  ));
}

export async function createArea(
  params: AreaInterface
): Promise<AxiosResponse<AreaInterface>> {
  return await (<Promise<AxiosResponse<AreaInterface>>>(
    Api.post("/areas", { area: params })
  ));
}

// Character Stuff

export async function updateCharacter(
  params: CharacterInterface
): Promise<AxiosResponse<CharacterInterface>> {
  return await (<Promise<AxiosResponse<CharacterInterface>>>(
    Api.patch("/characters/" + params.id, { character: params })
  ));
}

export async function deleteCharacter(
  characterId: string
): Promise<AxiosResponse<string>> {
  return await (<Promise<AxiosResponse<string>>>(
    Api.delete("/characters/" + characterId, "")
  ));
}

export async function loadCharactersForPlayer(
  playerId: string
): Promise<AxiosResponse<CharacterInterface[]>> {
  return await (<Promise<AxiosResponse<CharacterInterface[]>>>(
    Api.get("/characters/player/" + playerId)
  ));
}

export async function createCharacter(
  params: CharacterInterface
): Promise<AxiosResponse<CharacterInterface>> {
  return await (<Promise<AxiosResponse<CharacterInterface>>>(
    Api.post("/characters/create", params)
  ));
}

export async function loadCharacterCreationData(
  playerId: string
): Promise<AxiosResponse<CharacterInterface[]>> {
  return await (<Promise<AxiosResponse<CharacterInterface[]>>>(
    Api.get("/characters/get-creation-data")
  ));
}

// Link Stuff

export async function updateLink(
  id: string,
  params: LinkInterface
): Promise<AxiosResponse<LinkInterface>> {
  return await (<Promise<AxiosResponse<LinkInterface>>>(
    Api.patch("/links/" + id, { link: params })
  ));
}

export async function deleteLink(
  linkId: string
): Promise<AxiosResponse<string>> {
  return await (<Promise<AxiosResponse<string>>>(
    Api.delete("/links/" + linkId, "")
  ));
}

export async function loadLinksForMap(
  mapId: string
): Promise<AxiosResponse<LinkInterface[]>> {
  return await (<Promise<AxiosResponse<LinkInterface[]>>>(
    Api.get("/links/map/" + mapId)
  ));
}

export async function createLink(
  params: LinkInterface
): Promise<AxiosResponse<LinkInterface>> {
  return await (<Promise<AxiosResponse<LinkInterface>>>(
    Api.post("/links", { link: params })
  ));
}


//
//
// Mud Client Stuff
//
//

export async function startGameSession(
  characterId: string
): Promise<AxiosResponse<{token: string}>> {
  return await (<Promise<AxiosResponse<{token: string}>>>(
    Api.get(`/start-game-session/${characterId}`)
  ));
}