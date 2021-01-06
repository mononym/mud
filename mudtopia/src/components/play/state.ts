import * as _ from "lodash";
import { get, writable } from "svelte/store";
import {
  startGameSession as apiStartGameSession,
  saveCharacterSettings as saveCharSettings,
} from "../../api/server";
import type { CharacterInterface } from "../../models/character";
import CharacterState from "../../models/character";
import CharacterSettingsState, {
  CharacterSettingsInterface,
} from "../../models/characterSettings";
import { Socket } from "phoenix";

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

  async function selectSettingsTextView() {
    if (get(settingsView) != "text") {
      const settings = get(selectedCharacter).settings;
      const newSettings = _.cloneDeep(settings);
      characterSettings.set(newSettings);

      settingsView.set("text");
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
  const settingsView = writable("text");
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

  async function initializeCharacter(character: CharacterInterface) {
    selectedCharacter.set(character);
    // load all data needed to set up the context for the character
    characterInitialized.set(true);
    characterInitializing.set(false);
  }

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
    selectSettingsTextView,
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
