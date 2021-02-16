import * as _ from "lodash";
import { get, writable } from "svelte/store";
import {
  startGameSession as apiStartGameSession,
  saveCharacterSettings as saveCharSettings,
  initializeCharacterClientData,
} from "../../api/server";
import type { CharacterInterface } from "../../models/character";
import CharacterState from "../../models/character";
import type { ItemInterface } from "../../models/item";
import ItemState from "../../models/item";
import CharacterSettingsState, {
  CharacterSettingsInterface,
} from "../../models/characterSettings";
import { Socket } from "phoenix";
import type { AreaInterface } from "../../models/area";
import AreaState from "../../models/area";
import type { LinkInterface } from "../../models/link";

export const key = {};

export function createState() {
  //
  // Overall UI stuff, such as whether to show the play view or the other views
  //
  const view = writable("play");

  async function selectSettingsView() {
    if (get(view) != "settings") {
      const settings = get(selectedCharacter).settings;
      const newSettings = _.cloneDeep(settings);
      characterSettings.set(newSettings);

      view.set("settings");
    }
  }

  async function selectSettingsGeneralView() {
    if (get(settingsView) != "general") {
      const settings = get(selectedCharacter).settings;
      const newSettings = _.cloneDeep(settings);
      characterSettings.set(newSettings);

      settingsView.set("general");
    }
  }

  async function selectSettingsCommandsView() {
    if (get(settingsView) != "commands") {
      const settings = get(selectedCharacter).settings;
      const newSettings = _.cloneDeep(settings);
      characterSettings.set(newSettings);

      settingsView.set("commands");
    }
  }

  async function selectSettingsHotkeysView() {
    if (get(settingsView) != "hotkeys") {
      const settings = get(selectedCharacter).settings;
      const newSettings = _.cloneDeep(settings);
      characterSettings.set(newSettings);

      settingsView.set("hotkeys");
    }
  }

  async function selectPlayView() {
    if (get(view) != "play") {
      view.set("play");
    }
  }

  //
  // Settings stuff
  //
  const settingsView = writable("general");
  const characterSettings = writable(<CharacterSettingsInterface>{
    ...CharacterSettingsState,
  });

  async function resetCharacterSettings() {
    characterSettings.set(_.cloneDeep(get(selectedCharacter).settings));
  }

  async function saveCharacterSettings() {
    try {
      const res = (await saveCharSettings(get(characterSettings))).data;

      selectedCharacter.update(function (character) {
        character.settings = _.cloneDeep(res);
        return character;
      });

      characterSettings.set(_.cloneDeep(res));

      selectPlayView();

      return true;
    } catch (e) {
      alert(e.message);

      return false;
    }
  }

  //
  // Character Stuff
  //

  const characterInitialized = writable(false);
  const characterInitializing = writable(false);
  const selectedCharacter = writable({ ...CharacterState });

  // Inventory comes over as a single list of all held and worn items, and all their children assuming there are any
  // Break up the single list into a couple of different lists and indexes
  // held items list
  //    for displaying held items
  //    maybe explicitly keep track of left hand and right hand for display elsewhere
  const itemInLeftHand = writable({ ...ItemState });
  const leftHandHasItem = writable(false);
  const itemInRightHand = writable({ ...ItemState });
  const rightHandHasItem = writable(false);
  // worn items list
  //    for displaying worn items, the slots they occupy, and so on
  const wornContainers = writable(<ItemInterface[]>[]);
  // all items index
  //    For referencing during all other actions, maybe even other lists are just ids which all reference this
  const allInventoryItemsIndex = writable(<Record<string, ItemInterface>>{});
  // parent child index
  //    keep track of what items belong to what containers for easy display
  const inventoryItemsParentChildIndex = writable(
    <Record<string, ItemInterface[]>>{}
  );

  // explored areas set
  //    A set of ids of the areas known to the character in the current map.
  const exploredAreas = writable(<string[]>[]);

  // This is where all of the setup should occur for a character logging in.
  // This means getting data for the map where the character is, getting inventory data, getting room data
  async function initializeCharacter(character: CharacterInterface) {
    characterInitialized.set(false);
    characterInitializing.set(true);
    selectedCharacter.set(character);
    // load all data needed to set up the context for the character

    // load map data for character
    const res = (await initializeCharacterClientData(character.id)).data;
    console.log("initializeCharacter");
    console.log(res);

    exploredAreas.set(res.mapData.exploredAreas);

    console.log("knownMapsList");
    console.log(res.maps);
    knownMapsList.set(res.maps);
    const newMapsIndex = res.maps.reduce(
      (obj, map) => ((obj[map.id] = map), obj),
      {}
    );
    knownMapsIndex.set(newMapsIndex);

    console.log("knownAreasForCharacterMap");
    console.log(res.mapData.areas);
    resetMapData(res.mapData);

    setupInventory(res.inventory);

    characterSettings.set(_.cloneDeep(character.settings));

    characterInitializing.set(false);
    characterInitialized.set(true);
    console.log("selectedCharacter");
    console.log(get(selectedCharacter));
    console.log(get(knownAreasForCharacterMapIndex));
    console.log(get(selectedCharacter)["areaId"]);
    console.log(
      get(knownAreasForCharacterMapIndex)[get(selectedCharacter)["areaId"]]
    );
    console.log(
      knownMapsIndex[
        get(knownAreasForCharacterMapIndex)[get(selectedCharacter).areaId].mapId
      ]
    );
    console.log(get(selectedCharacter).areaId);
  }

  function setupInventory(items) {
    const newAllItemsIndex = {};

    items.forEach((item) => {
      newAllItemsIndex[item.id] = item;
    });

    allInventoryItemsIndex.set(newAllItemsIndex);

    resetHeldItems();
    resetWornContainers();
    resetParentChildIndex();
  }

  function resetAllInventoryItemsIndex(items) {
    const newAllItemsIndex = {};

    items.forEach((item) => {
      newAllItemsIndex[item.id] = item;
    });

    allInventoryItemsIndex.set(newAllItemsIndex);

    resetParentChildIndex();
  }

  function removeItemsFromAllInventoryItemsIndex(items) {
    const ids = items.map((item) => item.id);

    allInventoryItemsIndex.update(function (index) {
      ids.forEach((id) => delete index[id]);
      return index;
    });
  }

  function resetHeldItems() {
    itemInLeftHand.set({ ...ItemState });
    leftHandHasItem.set(false);
    itemInRightHand.set({ ...ItemState });
    rightHandHasItem.set(false);

    Object.values(get(allInventoryItemsIndex)).forEach((item) => {
      if (item.location.held_in_hand) {
        if (item.location.hand == "left") {
          itemInLeftHand.set(item);
          leftHandHasItem.set(true);
        } else if (item.location.hand == "right") {
          itemInRightHand.set(item);
          rightHandHasItem.set(true);
        }
      }
    });
  }

  function resetToi() {
    const newToi = [];

    Object.values(get(allAreaItemsIndex)).forEach((item) => {
      if (item.location.on_ground && item.flags.scenery) {
        newToi.push(item);
      }
    });

    toiInArea.set(newToi);
  }

  function resetOtherCharacters(characters) {
    otherCharactersInArea.set(characters);
  }

  function resetOnGround() {
    const newOnGround = [];

    Object.values(get(allAreaItemsIndex)).forEach((item) => {
      if (item.location.on_ground && !item.flags.scenery) {
        newOnGround.push(item);
      }
    });

    onGroundInArea.set(newOnGround);
  }

  function resetWornContainers() {
    const newWornContainers = [];

    Object.values(get(allInventoryItemsIndex)).forEach((item) => {
      if (
        item.location.worn_on_character &&
        item.flags.container &&
        item.flags.wearable
      ) {
        newWornContainers.push(item);
      }
    });

    wornContainers.set(newWornContainers);
  }

  function resetAreaItemsParentChildIndex() {
    const newParentChildIndex = {};
    console.log("resetAreaItemsParentChildIndex");
    console.log(Object.values(get(allAreaItemsIndex)));

    Object.values(get(allAreaItemsIndex)).forEach((item) => {
      if (item.location.relative_to_item) {
        const existingChildren =
          newParentChildIndex[item.location.relative_item_id] || [];
        existingChildren.push(item);
        newParentChildIndex[item.location.relative_item_id] = existingChildren;
      }
    });

    areaItemsParentChildIndex.set(newParentChildIndex);
    console.log(get(areaItemsParentChildIndex));
  }

  function resetParentChildIndex() {
    const newParentChildIndex = {};

    Object.values(get(allInventoryItemsIndex)).forEach((item) => {
      if (item.location.relative_to_item) {
        const existingChildren =
          newParentChildIndex[item.location.relative_item_id] || [];
        existingChildren.push(item);
        newParentChildIndex[item.location.relative_item_id] = existingChildren;
      }
    });

    inventoryItemsParentChildIndex.set(newParentChildIndex);
  }

  function addOtherCharacters(characters) {
    characters.forEach((character) => {
      otherCharactersInArea.update(function (others) {
        others.push(character);
        return others;
      });
    });
  }

  function addExits(exits) {
    exits.forEach((item) => {
      exitsInArea.update(function (ext) {
        ext.push(item);
        return ext;
      });
    });
  }

  function updateExits(exits) {
    exitsInArea.set(
      [...exits, ...get(exitsInArea)].filter(
        (v, i, a) => a.findIndex((it) => it.id == v.id) === i
      )
    );
  }

  function updateOtherCharacters(characters) {
    characters.forEach((character) => {
      otherCharactersInArea.update(function (index) {
        index[character.id] = character;
        return index;
      });
    });

    resetOtherCharacters(get(otherCharactersInArea));
  }

  function updateInventory(items) {
    items.forEach((item) => {
      allInventoryItemsIndex.update(function (index) {
        index[item.id] = item;
        return index;
      });
    });

    resetParentChildIndex();
    resetHeldItems();
    resetWornContainers();
  }

  function addInventory(items) {
    console.log("addInventory");
    console.log(items);
    items.forEach((item) => {
      allInventoryItemsIndex.update(function (index) {
        index[item.id] = item;
        return index;
      });

      if (item.location.held_in_hand) {
        if (item.location.hand == "left") {
          itemInLeftHand.set(item);
          leftHandHasItem.set(true);
        } else if (item.location.hand == "right") {
          itemInRightHand.set(item);
          rightHandHasItem.set(true);
        }
      } else if (
        item.location.worn_on_character &&
        item.flags.container &&
        item.flags.wearable
      ) {
        wornContainers.update(function (containers) {
          containers.push(item);
          return containers;
        });
      } else if (item.location.relative_to_item) {
        inventoryItemsParentChildIndex.update(function (index) {
          const existingChildren = index[item.location.relative_item_id] || [];
          existingChildren.push(item);
          index[item.location.relative_item_id] = existingChildren;

          return index;
        });
      }

      console.log(get(inventoryItemsParentChildIndex));
    });
  }

  function removeOtherCharacters(characters) {
    characters.forEach((character) => {
      otherCharactersInArea.update(function (others) {
        return others.filter((other) => other.id != character.id);
      });
    });
  }

  function removeExits(exits) {
    exits.forEach((exit) => {
      exitsInArea.update(function (eia) {
        return eia.filter((ext) => ext.id != exit.id);
      });
    });
  }

  function removeInventory(items) {
    removeItemsFromAllInventoryItemsIndex(items);
    resetHeldItems();
    resetWornContainers();
  }

  //
  // Map Stuff
  //

  // Characters have a set of 'known' maps that they have visited before.
  // This is the client side canonical list of those maps
  const knownMapsList = writable([]);
  const knownMapsIndex = writable({});

  const mapZoomMultipliers = writable([
    0.00775,
    0.015,
    0.03,
    0.06,
    0.125,
    0.25, // 4x size
    0.5, // double size
    1,
    2, // half size
    4, // quarter
    8,
    16,
    32,
    64,
    128,
    256,
    512,
  ]);
  const mapZoomMultiplierIndex = writable(7);

  const mapAtMaxZoom = writable(false);
  const mapAtMinZoom = writable(false);

  async function zoomMapOut() {
    if (get(mapZoomMultiplierIndex) < get(mapZoomMultipliers).length - 1) {
      mapZoomMultiplierIndex.set(get(mapZoomMultiplierIndex) + 1);

      let areaId = get(selectedCharacter).areaId;
      let area = get(knownAreasForCharacterMapIndex)[areaId];
      let map = get(knownMapsIndex)[area.mapId];

      if (map.maximumZoomIndex == get(mapZoomMultiplierIndex)) {
        mapAtMaxZoom.set(true);
      } else {
        mapAtMinZoom.set(false);
      }
    }
  }

  async function zoomMapIn() {
    if (get(mapZoomMultiplierIndex) > 0) {
      mapZoomMultiplierIndex.set(get(mapZoomMultiplierIndex) - 1);

      let areaId = get(selectedCharacter).areaId;
      let area = get(knownAreasForCharacterMapIndex)[areaId];
      let map = get(knownMapsIndex)[area.mapId];

      if (map.minimumZoomIndex == get(mapZoomMultiplierIndex)) {
        mapAtMinZoom.set(true);
      } else {
        mapAtMaxZoom.set(false);
      }
    }
  }

  // Characters only know about areas they have visited, or those marked as automatically known, and this is that list
  // of areas for the map the player is currently present in
  const knownAreasForCharacterMap = writable(<AreaInterface[]>[]);
  const knownAreasForCharacterMapIndex = writable(
    <Record<string, AreaInterface>>{}
  );
  const knownLinksForCharacterMap = writable(<LinkInterface[]>[]);
  const knownLinksForCharacterIndex = writable(
    <Record<string, LinkInterface>>{}
  );

  //
  // Connection Stuff
  //

  const initializingGameSession = writable(false);
  const gameSessionInitialized = writable(false);
  const channel = writable(<any>{});
  const socketInitialized = writable(false);
  const socket = writable(<any>{});

  async function startGameSession(characterId: string) {
    initializingGameSession.set(true);
    try {
      const res = (await apiStartGameSession(characterId)).data;

      initSocket(res.token);

      connectChannel(characterId);

      gameSessionInitialized.set(true);

      return true;
    } catch (e) {
      alert(e.message);

      return false;
    } finally {
      initializingGameSession.set(false);
    }
  }

  function initSocket(token) {
    if (!get(socketInitialized)) {
      const newSocket = new Socket("wss://localhost:4000/socket", {
        params: { token: token },
      });

      newSocket.connect();

      socket.set(newSocket);
      socketInitialized.set(true);
    }
  }

  const worldHourOfDay = writable(0.0);
  const worldTimeString = writable("");

  function connectChannel(characterId) {
    let sock = get(socket);
    const newChannel = sock.channel(`character:${characterId}`);
    newChannel.on("output:story", async function (msg) {
      console.log("received messages");
      console.log(msg);
      msg.messages.forEach((output) => {
        const segments = output.segments.map((segment) => {
          return {
            text: segment.text,
            type: segment.type,
          };
        });

        appendNewStoryMessage({ segments: segments });
      });
    });

    newChannel.on("update:character", async function (msg) {
      console.log("received an update for character");
      console.log(msg);

      if (msg.action == "character") {
        // double check that this update is for the selected character, as it should be
        if (get(selectedCharacter).id == msg.character.id) {
          console.log("character matches as expected");
          selectedCharacter.set(msg.character);
        } else {
          console.log("characters do not match");
        }
      } else if (msg.action == "wealth") {
        selectedCharacter.update(function (char) {
          char.wealth = msg.wealth;
          return char;
        });
      } else if (msg.action == "bank") {
        selectedCharacter.update(function (char) {
          char.bank = msg.bank;
          return char;
        });

        selectedCharacter.update(function (char) {
          char.wealth = msg.wealth;
          return char;
        });
      }
    });

    newChannel.on("update:area", async function (msg) {
      console.log("received an update for area");
      console.log(msg);

      if (msg.action == "look") {
        resetAreaItemsIndex(msg.items);
        currentArea.set(msg.area);
        otherCharactersInArea.set(msg.otherCharacters);
        resetToi();
        resetOnGround();
        exitsInArea.set(msg.exits);
      } else if (msg.action == "update") {
        addItemsToAreaItemsIndex(msg.items);
        resetToi();
        resetOnGround();
        updateOtherCharacters(msg.otherCharacters);
        updateExits(msg.exits);
      } else if (msg.action == "add") {
        addItemsToAreaItemsIndex(msg.items);
        resetToi();
        resetOnGround();
        addExits(msg.exits);
        addOtherCharacters(msg.otherCharacters);
      } else if (msg.action == "remove") {
        removeItemsFromAreaItemsIndex(msg.items);
        resetToi();
        resetOnGround();
        removeExits(msg.exits);
        removeOtherCharacters(msg.items);
      }
    });

    newChannel.on("update:inventory", async function (msg) {
      console.log("received an update for inventory");
      console.log(msg);

      if (msg.action == "update") {
        updateInventory(msg.items);
      } else if (msg.action == "add") {
        updateInventory(msg.items);
      } else if (msg.action == "remove") {
        removeInventory(msg.items);
      }
    });

    newChannel.on("update:map", async function (msg) {
      console.log("received an update for map");
      console.log(msg);

      if (msg.action == "move") {
        resetMapData(msg);
      }
    });

    newChannel.on("update:explored_areas", async function (msg) {
      console.log("received an update for updating known areas");
      console.log(msg);

      if (msg.action == "add") {
        addExploredAreas(msg);
      }
    });

    newChannel.on("update:explored_maps", async function (msg) {
      console.log("received an update for updating known maps");
      console.log(msg);

      if (msg.action == "add") {
        addExploredMaps(msg);
      }
    });

    newChannel.on("update:time", async function (msg) {
      console.log("received an update for time");
      console.log(msg);

      worldHourOfDay.set(msg.hour);
      worldTimeString.set(msg.time_string);
    });

    newChannel.join();

    channel.set(newChannel);
  }

  function addItemsToAreaItemsIndex(items) {
    allAreaItemsIndex.update(function (index) {
      items.forEach((itm) => {
        index[itm.id] = itm;
      });
      return index;
    });

    resetAreaItemsParentChildIndex();
  }

  function removeItemsFromAreaItemsIndex(items) {
    allAreaItemsIndex.update(function (index) {
      items.forEach((itm) => {
        delete index[itm.id];
      });
      return index;
    });

    resetAreaItemsParentChildIndex();
  }

  function resetAreaItemsIndex(items) {
    const newIndex = {};

    items.forEach((itm) => (newIndex[itm.id] = itm));

    allAreaItemsIndex.set(newIndex);
    resetAreaItemsParentChildIndex();
  }

  function resetMapData(mapData) {
    knownAreasForCharacterMap.set(mapData.areas);
    const newAreasIndex = mapData.areas.reduce(
      (obj, area) => ((obj[area.id] = area), obj),
      {}
    );
    knownAreasForCharacterMapIndex.set(newAreasIndex);

    knownLinksForCharacterMap.set(mapData.links);
    const newLinksIndex = mapData.links.reduce(
      (obj, area) => ((obj[area.id] = area), obj),
      {}
    );
    knownLinksForCharacterIndex.set(newLinksIndex);
  }

  function addExploredMaps(msg) {
    console.log("updating known maps");
    knownMapsIndex.update(function (index) {
      msg.maps.forEach((map) => {
        index[map.id] = map;
      });
      return index;
    });

    knownMapsList.set(
      [...msg.maps, ...get(knownMapsList)].filter(
        (v, i, a) => a.findIndex((it) => it.id == v.id) === i
      )
    );

    console.log("updated known maps");
    console.log(get(knownMapsIndex));
    console.log(get(knownMapsList));
  }

  function addExploredAreas(msg) {
    const ids = msg.areas.map((area) => area.id);
    knownAreasForCharacterMap.set(
      [...msg.areas, ...get(knownAreasForCharacterMap)].filter(
        (v, i, a) => a.findIndex((it) => it.id == v.id) === i
      )
    );

    knownAreasForCharacterMapIndex.update(function (index) {
      msg.areas.forEach((area) => {
        index[area.id] = area;
      });
      return index;
    });

    knownLinksForCharacterMap.set(
      [...msg.links, ...get(knownLinksForCharacterMap)].filter(
        (v, i, a) => a.findIndex((it) => it.id == v.id) === i
      )
    );

    knownLinksForCharacterIndex.update(function (index) {
      msg.links.forEach((link) => {
        index[link.id] = link;
      });
      return index;
    });

    exploredAreas.set([...get(exploredAreas), ...msg.explored]);
  }

  const endingGameSession = writable(false);
  async function endGameSession() {
    endingGameSession.set(true);
    try {
      get(channel).leave();

      return true;
    } catch (e) {
      alert(e.message);

      return false;
    } finally {
      endingGameSession.set(false);
    }
  }

  //
  // Area Window stuff
  //
  const allAreaItemsIndex = writable(<Record<string, ItemInterface>>{});
  const areaItemsParentChildIndex = writable(
    <Record<string, ItemInterface[]>>{}
  );

  const otherCharactersInArea = writable([]);
  const onGroundInArea = writable([]);
  const exitsInArea = writable([]);
  const denizensInArea = writable([]);
  const toiInArea = writable([]);
  const currentArea = writable({ ...AreaState });

  //
  // Story/History Window stuff
  //
  const storyWindowView = writable("current");
  const storyWindowMessages = writable([]);
  const maxStoryWindowMessagesCount = writable(100);
  const historyWindowMessageBuffer = writable([]);
  const historyWindowMessages = writable([]);
  const maxHistoryWindowMessagesCount = writable(10000);
  const echoCommands = writable(true);
  const echoInterface = writable(true);

  async function flushHistoryMessageBuffer() {
    await historyWindowMessages.update(function (buffer) {
      return [...buffer, ...get(historyWindowMessageBuffer)].slice(
        -get(maxHistoryWindowMessagesCount)
      );
    });

    historyWindowMessageBuffer.set([]);
  }

  async function appendNewStoryMessage(newMessage) {
    storyWindowMessages.set(
      [...get(storyWindowMessages), newMessage].slice(
        -maxStoryWindowMessagesCount
      )
    );

    // if history window is open, fill buffer without checking

    // if history window is closed, check buffer
    // if messages in buffer, add them and then add the new message...or just do it blindly with the expand syntax

    if (get(storyWindowView) == "history") {
      historyWindowMessageBuffer.update(function (buffer) {
        buffer.push(newMessage);
        return buffer.slice(-get(maxHistoryWindowMessagesCount));
      });
    } else if (get(storyWindowView) == "current") {
      historyWindowMessageBuffer.update(function (buffer) {
        buffer.push(newMessage);
        return buffer.slice(-get(maxHistoryWindowMessagesCount));
      });

      flushHistoryMessageBuffer();
    }
  }

  async function toggleHistoryWindow() {
    if (get(storyWindowView) == "history") {
      await storyWindowView.set("current");
    } else {
      flushHistoryMessageBuffer();
      await storyWindowView.set("history");
    }
  }

  async function hideHistoryWindow() {
    storyWindowView.set("current");
  }

  // async function maybeEchoCommand(text, isInterface) {
  //   if (get(echoCommands) && isInterface && get(echoInterface)) {
  //     appendNewStoryMessage({...Mess})
  //   }
  // }

  return {
    //
    // Overall UI stuff, such as whether to show the play view or the other views
    //
    view,
    selectSettingsView,
    selectPlayView,
    //
    // Area Stuff
    //
    otherCharactersInArea,
    onGroundInArea,
    exitsInArea,
    denizensInArea,
    toiInArea,
    currentArea,
    areaItemsParentChildIndex,
    //
    // Settings stuff
    //
    settingsView,
    characterSettings,
    resetCharacterSettings,
    saveCharacterSettings,
    selectSettingsHotkeysView,
    selectSettingsGeneralView,
    selectSettingsCommandsView,
    //
    // Map stuff
    //
    knownMapsList,
    knownMapsIndex,
    knownAreasForCharacterMap,
    knownAreasForCharacterMapIndex,
    knownLinksForCharacterMap,
    knownLinksForCharacterIndex,
    mapZoomMultipliers,
    mapZoomMultiplierIndex,
    mapAtMinZoom,
    mapAtMaxZoom,
    exploredAreas,
    zoomMapIn,
    zoomMapOut,
    //
    // Environment stuff
    //
    worldHourOfDay,
    worldTimeString,
    //
    // Character Stuff
    //
    characterInitialized,
    characterInitializing,
    selectedCharacter,
    initializeCharacter,
    itemInLeftHand,
    leftHandHasItem,
    itemInRightHand,
    rightHandHasItem,
    wornContainers,
    allInventoryItemsIndex,
    inventoryItemsParentChildIndex,
    updateInventory,
    addInventory,
    removeInventory,
    //
    // Connection Stuff
    //
    startGameSession,
    initializingGameSession,
    gameSessionInitialized,
    channel,
    endGameSession,
    endingGameSession,
    //
    // Story/History window stuff
    //
    appendNewStoryMessage,
    hideHistoryWindow,
    toggleHistoryWindow,
    storyWindowView,
    storyWindowMessages,
    maxStoryWindowMessagesCount,
    historyWindowMessageBuffer,
    historyWindowMessages,
    maxHistoryWindowMessagesCount,
    echoCommands,
    echoInterface,
  };
}

export const State = createState();
