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

    knownMapsList.set(res.maps);
    const newMapsIndex = res.maps.reduce(
      (obj, map) => ((obj[map.id] = map), obj),
      {}
    );
    knownMapsIndex.set(newMapsIndex);

    knownAreasForCharacterMap.set(res.mapData.areas);
    const newAreasIndex = res.mapData.areas.reduce(
      (obj, area) => ((obj[area.id] = area), obj),
      {}
    );
    knownAreasForCharacterMapIndex.set(newAreasIndex);

    knownLinksForCharacterMap.set(res.mapData.links);
    const newLinksIndex = res.mapData.links.reduce(
      (obj, area) => ((obj[area.id] = area), obj),
      {}
    );
    knownLinksForCharacterIndex.set(newLinksIndex);

    setupInventory(res.inventory);

    characterSettings.set(_.cloneDeep(character.settings));

    characterInitializing.set(false);
    characterInitialized.set(true);
  }

  function setupInventory(items) {
    const newWornContainers = [];
    const newAllItemsIndex = {};
    const newParentChildIndex = {};

    items.forEach((item) => {
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
        newWornContainers.push(item);
      }

      newAllItemsIndex[item.id] = item;

      if (item.location.relative_to_item) {
        const existingChildren =
          newParentChildIndex[item.location.relative_item_id] || [];
        existingChildren.push(item);
        newParentChildIndex[item.location.relative_item_id] = existingChildren;
      }
    });

    wornContainers.set(newWornContainers);
    allInventoryItemsIndex.set(newAllItemsIndex);
    inventoryItemsParentChildIndex.set(newParentChildIndex);
  }

  function updateInventory(items) {
    items.forEach((item) => {
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
          var foundIndex = containers.findIndex(
            (container) => container.id == item.id
          );
          containers[foundIndex] = item;
          return containers;
        });
      }

      allInventoryItemsIndex.update(function (index) {
        index[item.id] = item;
        return index;
      });

      if (item.location.relative_to_item) {
        inventoryItemsParentChildIndex.update(function (index) {
          const existingChildren = index[item.location.relative_item_id] || [];
          existingChildren.push(item);
          index[item.location.relative_item_id] = existingChildren;

          return index;
        });
      }
    });
  }

  function addInventory(items) {
    items.forEach((item) => {
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
      }

      allInventoryItemsIndex.update(function (index) {
        index[item.id] = item;
        return index;
      });

      if (item.location.relative_to_item) {
        inventoryItemsParentChildIndex.update(function (index) {
          const existingChildren = index[item.location.relative_item_id] || [];
          existingChildren.push(item.id);
          index[item.location.relative_item_id] = existingChildren;

          return index;
        });
      }
    });
  }

  function removeInventory(items) {
    items.forEach((item) => {
      if (item.location.held_in_hand) {
        if (item.location.hand == "left") {
          itemInLeftHand.set({ ...ItemState });
          leftHandHasItem.set(false);
        } else if (item.location.hand == "right") {
          itemInRightHand.set({ ...ItemState });
          rightHandHasItem.set(false);
        }
      } else if (
        item.location.worn_on_character &&
        item.flags.container &&
        item.flags.wearable
      ) {
        wornContainers.update(function (containers) {
          containers.filter((container) => container.id != item.id);
          return containers;
        });
      }

      allInventoryItemsIndex.update(function (index) {
        delete index[item.id];
        return index;
      });

      if (item.location.relative_to_item) {
        inventoryItemsParentChildIndex.update(function (index) {
          const existingChildren = index[item.location.relative_item_id] || [];
          existingChildren.filter((child) => child.id != item.id);
          index[item.location.relative_item_id] = existingChildren;

          return index;
        });
      }
    });
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
      console.log(get(mapZoomMultiplierIndex));

      let areaId = get(selectedCharacter).areaId;
      let area = get(knownAreasForCharacterMapIndex)[areaId];
      let map = get(knownMapsIndex)[area.mapId];
      console.log(map);
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
      console.log(get(mapZoomMultiplierIndex));

      let areaId = get(selectedCharacter).areaId;
      let area = get(knownAreasForCharacterMapIndex)[areaId];
      let map = get(knownMapsIndex)[area.mapId];
      console.log(map);
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

      // double check that this update is for the selected character, as it should be
      if (get(selectedCharacter).id == msg.character.id) {
        console.log("character matches as expected");
        selectedCharacter.set(msg.character);
      } else {
        console.log("characters do not match");
      }
    });

    newChannel.on("update:area", async function (msg) {
      console.log("received an update for area");
      console.log(msg);

      if (msg.action == "look") {
        currentArea.set(msg.area);
        otherCharactersInArea.set(msg.otherCharacters);
        onGroundInArea.set(msg.onGround);
        toiInArea.set(msg.toi);
        exitsInArea.set(msg.exits);
      } else if (msg.action == "add") {
        otherCharactersInArea.set([
          ...get(otherCharactersInArea),
          ...msg.otherCharacters,
        ]);

        onGroundInArea.set([...get(onGroundInArea), ...msg.onGround]);

        toiInArea.set([...get(toiInArea), ...msg.toi]);
        exitsInArea.set([...get(exitsInArea), ...msg.exits]);
      } else if (msg.action == "remove") {
        const removeCharacterIds = msg.otherCharacters.map((char) => char.id);
        otherCharactersInArea.update(function (otherCharacters) {
          otherCharacters.filter(
            (character, i, a) => !removeCharacterIds.includes(character.id)
          );
          return otherCharacters;
        });

        const removeOnGroundIds = msg.onGround.map((item) => item.id);
        onGroundInArea.update(function (itemsOnGround) {
          itemsOnGround.filter(
            (item, i, a) => !removeOnGroundIds.includes(item.id)
          );
          return itemsOnGround;
        });

        const removeToiIds = msg.toi.map((item) => item.id);
        toiInArea.update(function (toi) {
          toi.filter((item, i, a) => !removeToiIds.includes(item.id));
          return toi;
        });

        const removeExitIds = msg.exits.map((exit) => exit.id);
        exitsInArea.update(function (exit) {
          exit.filter((exit, i, a) => !removeExitIds.includes(exit.id));
          return exit;
        });
      }
    });

    newChannel.on("update:inventory", async function (msg) {
      console.log("received an update for inventory");
      console.log(msg);

      if (msg.action == "update") {
        updateInventory(msg.items);
      } else if (msg.action == "add") {
        addInventory(msg.items);
      } else if (msg.action == "remove") {
        removeInventory(msg.items);
      }
    });

    newChannel.join();

    channel.set(newChannel);
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
    console.log(get(storyWindowView));
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
    zoomMapIn,
    zoomMapOut,
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
