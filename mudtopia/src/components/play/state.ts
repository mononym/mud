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

  async function selectSettingsColorsView() {
    if (get(settingsView) != "colors") {
      const settings = get(selectedCharacter).settings;
      const newSettings = _.cloneDeep(settings);
      characterSettings.set(newSettings);

      settingsView.set("colors");
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
  const settingsView = writable("colors");
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
  const wornItems = writable(<ItemInterface[]>[]);
  // all items index
  //    For referencing during all other actions, maybe even other lists are just ids which all reference this
  const allInventoryItemsIndex = writable(<Record<string, ItemInterface>>{});
  // parent child index
  //    keep track of what items belong to what containers for easy display
  const inventoryItemsParentChildIndex = writable(<Record<string, string>>{});

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

    const newWornItems = [];
    const newAllItemsIndex = {};
    const newParentChildIndex = {};

    res.inventory.forEach((item) => {
      if (item.holdableIsHeld) {
        if (item.holdableHand == "left") {
          itemInLeftHand.set(item);
          leftHandHasItem.set(true);
        } else if (item.holdableHand == "right") {
          itemInRightHand.set(item);
          rightHandHasItem.set(true);
        }
      } else if (item.wearableIsWorn) {
        newWornItems.push(item);
      }

      newAllItemsIndex[item.id] = item;

      if (item.containerId != "") {
        const existingChildren = newParentChildIndex[item.containerId] || [];
        existingChildren.push(item);
        newParentChildIndex[item.containerId] = existingChildren;
      }
    });

    wornItems.set(newWornItems);
    allInventoryItemsIndex.set(newAllItemsIndex);
    inventoryItemsParentChildIndex.set(newParentChildIndex);

    characterInitializing.set(false);
    characterInitialized.set(true);
  }

  //
  // Map Stuff
  //

  // Characters have a set of 'known' maps that they have visited before.
  // This is the client side canonical list of those maps
  const knownMapsList = writable([]);
  const knownMapsIndex = writable({});

  // Characters only know about areas they have visited, or those marked as automatically known, and this is that list
  // of areas for the map the player is currently present in
  const knownAreasForCharacterMap = writable(<AreaInterface[]>[]);
  const knownAreasForCharacterMapIndex = writable(<AreaInterface[]>[]);
  const knownLinksForCharacterMap = writable(<LinkInterface[]>[]);
  const knownLinksForCharacterIndex = writable(<LinkInterface[]>[]);

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
  // Story/History Window stuff
  //
  const storyWindowView = writable("current");
  const storyWindowMessages = writable([]);
  const maxStoryWindowMessagesCount = writable(100);
  const historyWindowMessageBuffer = writable([]);
  const historyWindowMessages = writable([]);
  const maxHistoryWindowMessagesCount = writable(10000);

  async function flushHistoryMessageBuffer() {
    await historyWindowMessages.update(function (buffer) {
      return [...buffer, ...get(historyWindowMessageBuffer)].slice(
        -get(maxHistoryWindowMessagesCount)
      );
    });

    await historyWindowMessageBuffer.set([]);
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
      await flushHistoryMessageBuffer();
      await storyWindowView.set("history");
    }
  }

  async function hideHistoryWindow() {
    storyWindowView.set("current");
  }

  async function resetAllDataToDefault() {
    await selectPlayView();
    await settingsView.set("colors");
    await resetCharacterSettings();
    await characterInitialized.set(false);
    await characterInitializing.set(false);
    await selectedCharacter.set({ ...CharacterState });
    await itemInLeftHand.set({ ...ItemState });
    await leftHandHasItem.set(false);
    await itemInRightHand.set({ ...ItemState });
    await rightHandHasItem.set(false);
    await wornItems.set([]);
    await allInventoryItemsIndex.set({});
    await inventoryItemsParentChildIndex.set({});
    await wornItems.set([]);
    await knownMapsList.set([]);
    await knownMapsIndex.set({});
    await knownAreasForCharacterMap.set([]);
    await knownAreasForCharacterMapIndex.set([]);
    await knownLinksForCharacterMap.set([]);
    await knownLinksForCharacterIndex.set([]);
    await initializingGameSession.set(false);
    await gameSessionInitialized.set(false);
    await channel.set({});
    await endingGameSession.set(false);
    await storyWindowView.set("current");
    await storyWindowMessages.set([]);
    await historyWindowMessageBuffer.set([]);
    await historyWindowMessages.set([]);
  }

  return {
    resetAllDataToDefault,
    //
    // Overall UI stuff, such as whether to show the play view or the other views
    //
    view,
    selectSettingsView,
    selectPlayView,
    //
    // Settings stuff
    //
    settingsView,
    characterSettings,
    resetCharacterSettings,
    saveCharacterSettings,
    selectSettingsHotkeysView,
    selectSettingsColorsView,
    //
    // Map stuff
    //
    knownMapsList,
    knownMapsIndex,
    knownAreasForCharacterMap,
    knownAreasForCharacterMapIndex,
    knownLinksForCharacterMap,
    knownLinksForCharacterIndex,
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
    wornItems,
    allInventoryItemsIndex,
    inventoryItemsParentChildIndex,
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
  };
}

export const State = createState();
