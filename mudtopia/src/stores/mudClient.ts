import { writable } from "svelte/store";
import { startGameSession as apiStartGameSession } from "../api/server";
import type { CharacterInterface } from "../models/character";
import CharacterState from "../models/character";
import { Socket } from "phoenix";

function createMudClientStore() {
  //
  // Character Stuff
  //

  const characterInitialized = writable(false);
  const characterInitializing = writable(false);
  const selectedCharacter = writable({ ...CharacterState });

  async function initializeCharacter(character: CharacterInterface) {
    selectedCharacter.set(character);
    characterInitialized.set(true);
    characterInitializing.set(false);
  }

  //
  // Connection Stuff
  //

  const initializingGameSession = writable(false);
  const gameSessionInitialized = writable(false);
  const channel = writable({});

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

  //
  // UI stuff Stuff
  //

  return {
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
    //
    // UI stuff
    //
  };
}

export const MudClientStore = createMudClientStore();
