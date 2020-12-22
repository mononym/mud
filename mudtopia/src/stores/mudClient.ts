import { derived, writable } from "svelte/store";
import {} from "../api/server";
import type { CharacterInterface } from "../models/character";
import CharacterState from "../models/character";

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

  const wsToken = writable("");

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
    wsToken,
    //
    // UI stuff
    //
  };
}

export const MudClientStore = createMudClientStore();
