import Api from "../services/api";
import type { AxiosResponse } from "axios";
import type { CharacterInterface } from "../models/character";
import type { CharacterSettingsInterface } from "../models/characterSettings";
import type { PlayerInterface } from "../models/player";
import type { MapInterface } from "../models/map";
import type { LinkInterface } from "../models/link";
import type { AreaInterface } from "../models/area";
import type { ShopInterface } from "../models/shop";
import type { ShopProductInterface } from "../models/shopProduct";

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

export async function attachShopToArea(
  shopId: string,
  areaId: string
): Promise<AxiosResponse<string>> {
  return await (<Promise<AxiosResponse<string>>>(
    Api.post("/areas/attach_shop", { area_id: areaId, shop_id: shopId })
  ));
}

export async function detachShopFromArea(
  shopId: string
): Promise<AxiosResponse<string>> {
  return await (<Promise<AxiosResponse<string>>>(
    Api.post("/areas/detach_shop", { shop_id: shopId })
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
): Promise<AxiosResponse<{ token: string }>> {
  return await (<Promise<AxiosResponse<{ token: string }>>>(
    Api.get(`/start-game-session/${characterId}`)
  ));
}

export async function initializeCharacterClientData(
  characterId: string
): Promise<AxiosResponse<Record<string, any>>> {
  return await (<Promise<AxiosResponse<Record<string, any>>>>(
    Api.get(`/init-client-data/${characterId}`)
  ));
}

//
//
// Character Settings stuff
//
//

export async function saveCharacterSettings(
  settings: CharacterSettingsInterface
): Promise<AxiosResponse<CharacterSettingsInterface>> {
  return await (<Promise<AxiosResponse<CharacterSettingsInterface>>>(
    Api.patch(`/characters/settings/${settings.id}`, { settings: settings })
  ));
}

//
//
// Shops stuff
//
//

export async function loadShopsForBuilder(): Promise<
  AxiosResponse<ShopInterface[]>
> {
  return await (<Promise<AxiosResponse<ShopInterface[]>>>(
    Api.get(`/shops/builder`)
  ));
}

export async function createShop(
  params: ShopInterface
): Promise<AxiosResponse<ShopInterface>> {
  return await (<Promise<AxiosResponse<ShopInterface>>>(
    Api.post("/shops/create", { shop: params })
  ));
}

export async function updateShop(
  id: string,
  params: ShopInterface
): Promise<AxiosResponse<ShopInterface>> {
  return await (<Promise<AxiosResponse<ShopInterface>>>(
    Api.patch("/shops/" + id, { shop: params })
  ));
}

export async function deleteShop(
  shopId: string
): Promise<AxiosResponse<string>> {
  return await (<Promise<AxiosResponse<string>>>(
    Api.delete("/shops/" + shopId, "")
  ));
}

export async function updateShopProduct(
  id: string,
  params: ShopProductInterface
): Promise<AxiosResponse<ShopProductInterface>> {
  return await (<Promise<AxiosResponse<ShopProductInterface>>>(
    Api.patch("/shops/products/" + id, { shop_product: params })
  ));
}

export async function createShopProduct(
  params: ShopProductInterface
): Promise<AxiosResponse<ShopProductInterface>> {
  return await (<Promise<AxiosResponse<ShopProductInterface>>>(
    Api.post("/shops/products/create", { shop_product: params })
  ));
}

export async function deleteShopProduct(
  shopProductId: string
): Promise<AxiosResponse<string>> {
  return await (<Promise<AxiosResponse<string>>>(
    Api.delete("/shops/products/" + shopProductId, "")
  ));
}
