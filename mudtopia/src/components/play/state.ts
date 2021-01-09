import * as _ from "lodash";
import { get, writable } from "svelte/store";
import {
  startGameSession as apiStartGameSession,
  saveCharacterSettings as saveCharSettings,
  initializeCharacterClientData,
} from "../../api/server";
import type { CharacterInterface } from "../../models/character";
import CharacterState from "../../models/character";
import CharacterSettingsState, {
  CharacterSettingsInterface,
} from "../../models/characterSettings";
import { Socket } from "phoenix";
import type { AreaInterface } from "../../models/area";
import type { LinkInterface } from "../../models/link";

function createState() {
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

  async function startGameSession(characterId: string) {
    initializingGameSession.set(true);
    try {
      const res = (await apiStartGameSession(characterId)).data;

      const newSocket = new Socket("wss://localhost:4000/socket", {
        params: { token: res.token },
      });

      newSocket.connect();

      const newChannel = newSocket.channel(`character:${characterId}`);

      newChannel.join();

      channel.set(newChannel);

      gameSessionInitialized.set(true);

      return true;
    } catch (e) {
      alert(e.message);

      return false;
    } finally {
      initializingGameSession.set(false);
    }
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

  function flushHistoryMessageBuffer() {
    historyWindowMessages.update(function (buffer) {
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

  async function showHistoryWindow() {
    flushHistoryMessageBuffer();
    storyWindowView.set("history");
  }

  async function hideHistoryWindow() {
    storyWindowView.set("current");
  }

  return {
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
    showHistoryWindow,
    hideHistoryWindow,
    storyWindowView,
    storyWindowMessages,
    maxStoryWindowMessagesCount,
    historyWindowMessageBuffer,
    historyWindowMessages,
    maxHistoryWindowMessagesCount,
  };
}

export const State = createState();
